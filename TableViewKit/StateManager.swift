//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

/*
The intention of this utility is to provide a mechanism for managing a data set
which can have some elements hidden over time, but which is a definable order
for those items

The API provides call backs for when items are removed or added, providing
the indices of the items which were changed and the new list of items

The API will finally return the new list of items after it's been fully processed
*/


public enum State {
	case hide
	case show
	// Change is only valid where an item's actual state is show...
	case reload
	// This is used to force a rows state to be updated when it's first loaded
	case undefined
	
	// Physically delete the row
	case delete
	
	public func newStateBasedOn(desiredState: State) -> State {
		guard desiredState != .reload else {
			return self;
		}
		
		return desiredState;
	}
}

public extension State {
	// If hidden, show, otherwise reload
	func showOrReload() -> State {
		return (self == .hide || self == .undefined) ? .show : .reload
	}
}

public protocol Stateful {
	var actualState: State {get}
	var desiredState: State {get}
	
	// Move desiredState to actualState
	func updateToDesiredState()
}

public func ==(lhs: Stateful, rhs: Stateful) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public protocol OperationTarget {
  var identifier: AnyHashable {get}
  var index: Int {get}
}

struct DefaultOperationTarget: OperationTarget, CustomStringConvertible {
  let identifier: AnyHashable
  let index: Int
	
	var description: String {
		return "DefaultOperationTarget: \(identifier) @ \(index)"
	}
}

public protocol StatefulOperations {
	var insert: [OperationTarget] {get}
	var update: [OperationTarget] {get}
	var delete: [OperationTarget] {get}

	func operations(for operation: Operation) -> [OperationTarget]
}

struct DefaultStatefulOperations: StatefulOperations {
	let insert: [OperationTarget]
	let update: [OperationTarget]
	let delete: [OperationTarget]
	
	func operations(for operation: Operation) -> [OperationTarget] {
		switch operation {
		case .insert: return insert
		case .update: return update
		case .delete: return delete
		}
	}
}

public typealias Evaluator<T> = (T, T) -> Bool

// The indicies for the items don't need to change based on the outcome state
// They should refelect the changes which need to be made???

public class StateManager<ItemType: Stateful> {

	let allItems: [AnyHashable: ItemType]
	let preferredOrder: [AnyHashable]

	public init(
		allItems: [AnyHashable: ItemType],
		preferredOrder: [AnyHashable]) {
		self.allItems = allItems
		self.preferredOrder = preferredOrder
	}
  
  func item(forIdentifier identifier: AnyHashable) -> ItemType {
    return allItems[identifier]!
  }
	
	// This includes those items which want to be deleted!
	func wantsToBeHidden(_ identifier: AnyHashable) -> Bool {
    let value = item(forIdentifier: identifier)
		return (value.desiredState == .hide && value.actualState != .hide)
			|| (value.desiredState == .delete && value.actualState != .delete)
	}
	
	func wantsToBeShown(_ identifier: AnyHashable) -> Bool {
    let value = item(forIdentifier: identifier)
		return value.desiredState == .show && value.actualState != .show
	}

  func wantsToBeReloaded(_ identifier: AnyHashable) -> Bool {
    let value = item(forIdentifier: identifier)
    return value.desiredState == .reload
  }

  func isShown(_ identifier: AnyHashable) -> Bool {
    let value = item(forIdentifier: identifier)
    return value.actualState == .show
  }

  func isShowingButNotActive(_ identifier: AnyHashable, in activeItems: [AnyHashable]) -> Bool {
    guard isShown(identifier) else {
      return false
    }
    guard !wantsToBeHidden(identifier) else {
      return false
    }
    return !activeItems.contains(identifier)
  }
	
	func apply(operations: StatefulOperations, to activeItems: [AnyHashable], sortBy preferredSortOrder: [AnyHashable]) -> [AnyHashable] {
		var items: [AnyHashable] = []
		items.append(contentsOf: activeItems)
		for op in operations.insert {
			items.append(op.identifier)
		}
		for op in operations.delete {
			guard let index = items.index(of: op.identifier) else {
				continue
			}
			items.remove(at: index)
		}
		return sort(items, byPreferredOrder: preferredSortOrder)
	}
	
	func modifyOperations(basedOn activeItems: [AnyHashable]) -> StatefulOperations {
		var items: [AnyHashable] = []
		items.append(contentsOf: activeItems)
		
		let toUpdate = updateItems(in: items)
		
		// Items to be removed
		let toDelete = hideItems(in: items)
		for entry in toDelete {
			guard let index = items.index(of: entry.identifier) else {
				////log(debug: "!! Could not find index of item with identifier = \(entry.identifier)")
				continue
			}
			items.remove(at: index)
		}
		
		let operations = DefaultStatefulOperations(insert: [], update: toUpdate, delete: toDelete)
		
		for item in toDelete {
			allItems[item.identifier]?.updateToDesiredState()
		}
		for item in toUpdate {
			allItems[item.identifier]?.updateToDesiredState()
		}

		return operations
	}
	
	func insertOperations(basedOn activeItems: [AnyHashable]) -> StatefulOperations {
		var items: [AnyHashable] = []
		items.append(contentsOf: activeItems)
		
		// Items to be inserted
		let toInsert = showItems(in: items).sorted(by: { $0.index < $1.index })
		for entry in toInsert {
			items.insert(entry.identifier, at: entry.index)
		}
		
		let operations = DefaultStatefulOperations(insert: toInsert, update: [], delete: [])
		
		// Move all items to their desired state, this ensures
		// that any items not handled by the hide/show/update
		// functions are updated
		for item in toInsert {
			allItems[item.identifier]?.updateToDesiredState()
		}
		
		return operations
	}

	
//	func operationsForDesiredState(basedOn activeItems: [AnyHashable]) -> StatefulOperations {
//		var items: [AnyHashable] = []
//		items.append(contentsOf: activeItems)
//
//		let toUpdate = updateItems(in: items)
//
//		// Items to be removed
//		let toDelete = hideItems(in: items)
//		for entry in toDelete {
//			guard let index = items.index(of: entry.identifier) else {
//				////log(debug: "!! Could not find index of item with identifier = \(entry.identifier)")
//				continue
//			}
//			items.remove(at: index)
//		}
//
//		// Items to be inserted
//		let toInsert = showItems(in: items).sorted(by: { $0.index < $1.index })
//		for entry in toInsert {
//			//			////log(debug: "\(entry)")
//			items.insert(entry.identifier, at: entry.index)
//		}
//
//		let operations = DefaultStatefulOperations(insert: toInsert, update: toUpdate, delete: toDelete)
//
//    // Move all items to their desired state, this ensures
//    // that any items not handled by the hide/show/update
//    // functions are updated
//    for item in allItems {
//      item.value.updateToDesiredState()
//    }
//
//		return operations
//	}
	
	func updateItems(in activeItems: [AnyHashable]) -> [OperationTarget] {
		let items = activeItems.filter { wantsToBeReloaded($0) }
		let rowIndicies = indices(of: items, in: activeItems)
//    ////log(debug: "Reload \(items)")

		for identifier in items {
      item(forIdentifier: identifier).updateToDesiredState()
		}
    
    var targets: [OperationTarget] = []
    for index in rowIndicies {
      targets.append(DefaultOperationTarget(identifier: activeItems[index], index: index))
    }

		return targets
	}

//	public func update(wereRemoved: WereRemoved? = nil,
//	            wereAdded: WereAdded? = nil) -> [ItemType] {
//		// The remove and add process are separated to reduce the code complexity of this method
//		// as well as to allow them to focus on their individual requirements in isolation, so
//		// there modifications don't effect the generation of the required events
//
//		// Remove content which is no longer required
//		activeItems = downgrade(wereRemoved: wereRemoved)
//		//        activate(sections: active)
//		// Add new content which is now required
//		activeItems = upgrade(wereAdded: wereAdded)
//
//		return activeItems
//	}

	// Need to return...
	// The new active list
	// and the items that were removed
//	internal func downgrade(wereRemoved: WereRemoved? = nil) -> [ItemType] {
//		let itemsToBeRemoved = activeItems.filter {	return wantsToBeHidden($0) }
//
//		// We need to do this BEFORE we physically remove the sections from the active
//		// array, otherwise we can't calculate the indices
//		var indicesToBeRemoved: [Int] = []
//		indicesToBeRemoved.append(contentsOf: indices(of: itemsToBeRemoved, in: activeItems))
//
//		// Remove all the optional sections
//		let results = remove(itemsToBeRemoved, from: activeItems)
//
//		guard let wereRemoved = wereRemoved else {
//			return results
//		}
//		guard indicesToBeRemoved.count > 0 else {
//			return results
//		}
//		wereRemoved(indicesToBeRemoved, results)
//
//		return results
//	}
	
	internal func map(_ items: [AnyHashable], with indicies: [Int]) -> [OperationTarget] {
		var results: [OperationTarget] = []
		for index in 0..<items.count {
			let op = DefaultOperationTarget(identifier: items[index], index: indicies[index])
			results.append(op)
		}
		return results
	}

	internal func hideItems(in activeItems: [AnyHashable]) -> [OperationTarget] {
		let itemsToBeRemoved = activeItems.filter {	return wantsToBeHidden($0) }
		let rowIndicies = indices(of: itemsToBeRemoved, in: activeItems)
		
		for identifier in itemsToBeRemoved {
      item(forIdentifier: identifier).updateToDesiredState()
		}
		
		return map(itemsToBeRemoved, with: rowIndicies)
	}

	internal func indices(of from: [AnyHashable], `in` source: [AnyHashable]) -> [Int] {
		let values: [Int] = from.map { (item: AnyHashable) -> Int in
			self.index(of: item, in: source)!
		}

		return values
	}

//	internal func remove(_ sections: [ItemType], from: [ItemType]) -> [ItemType] {
//		var copy: [ItemType] = []
//		copy.append(contentsOf: from)
//		for section in sections {
//			if let index = index(of: section, in: copy) {
//				copy.remove(at: index)
//			}
//		}
//		return copy
//	}

	// Need to return...
	// The new "active" list, in order
	// and the items that were added
//	internal func upgrade(wereAdded: WereAdded? = nil) -> [ItemType] {
//
//		var itemsToBeAdded: [ItemType] = []
//
//		var updatedActivity: [ItemType] = []
//		updatedActivity.append(contentsOf: activeItems)
//		for name in preferredOrder {
//			guard let item = allItems[name] else {
//				continue
//			}
//
//			guard wantsToBeShown(item) else {
//				continue
//			}
//
//			guard index(of: name, in: preferredOrder, where: { $0 == $1 }) != nil else {
//				continue
//			}
//
//			guard !isActive(section: item, in: activeItems) else {
//				continue
//			}
//
//			itemsToBeAdded.append(item)
//			updatedActivity.append(item)
//		}
//
//		// This sorts the active based on the order of the specified
//		// sectionOrder array
//		updatedActivity.sort { (item1: ItemType, item2: ItemType) -> Bool in
//			// Got to get the SectionHeader for the view
//			let name1 = name(of: item1, in: allItems)!
//			let name2 = name(of: item2, in: allItems)!
//
//			// Then we can figure out the preferred index
//			let index1 = index(of: name1, in: preferredOrder, where: { $0 == $1 })!
//			let index2 = index(of: name2, in: preferredOrder, where: { $0 == $1 })!
//
//			// And we can sort them
//			return index1 < index2
//		}
//
//		guard let wereAdded = wereAdded else {
//			return updatedActivity
//		}
//		guard itemsToBeAdded.count > 0 else {
//			return updatedActivity
//		}
//
//		var indicesToBeAdded: [Int] = []
//		indicesToBeAdded.append(contentsOf: indices(of: itemsToBeAdded, in: updatedActivity))
//		wereAdded(indicesToBeAdded, updatedActivity)
//
//		return updatedActivity
//	}
	
	func sortByPreferredOrder(_ items: [AnyHashable]) -> [ItemType] {
//		let sortedNames = items.sorted(by: {(lhs: AnyHashable, rhs: AnyHashable) -> Bool in
//			// Then we can figure out the preferred index
//			let lhsIndex = index(of: lhs, in: preferredOrder, where: { $0 == $1 })!
//			let rhsIndex = index(of: rhs, in: preferredOrder, where: { $0 == $1 })!
//
//			// And we can sort them
//			return lhsIndex < rhsIndex
//		})
		
		let sortedNames = sort(items, byPreferredOrder: preferredOrder)
		return sortedNames.map { allItems[$0]! }
	}
	
	internal func showItems(in activeItems: [AnyHashable]) -> [OperationTarget] {
		
		var itemsToBeAdded: Set<AnyHashable> = Set<AnyHashable>()
		
    // What happens if an item's active state is "show"
    // but is not in the active items list    
		for name in preferredOrder {
      guard wantsToBeShown(name) || isShowingButNotActive(name, in: activeItems) else {
				continue
			}
			
			guard index(of: name, in: preferredOrder, where: { $0 == $1 }) != nil else {
				continue
			}

      // If the item is already active, we don't want to insert it again
      guard !isActive(name, in: activeItems) else {
        continue
      }
			
      itemsToBeAdded.insert(name)
		}
		
		var updateActivity: Set<AnyHashable> = Set<AnyHashable>()
    updateActivity = updateActivity.union(activeItems)
    updateActivity = updateActivity.union(itemsToBeAdded)
		
		// This sorts the active based on the order of the specified
		// sectionOrder array
    let sorted = updateActivity.sorted(by: { (lhs: AnyHashable, rhs: AnyHashable) -> Bool in

			// Then we can figure out the preferred index
			let lhsIndex = index(of: lhs, in: preferredOrder, where: { $0 == $1 })!
			let rhsIndex = index(of: rhs, in: preferredOrder, where: { $0 == $1 })!

			// And we can sort them
			return lhsIndex < rhsIndex
		})
		
		var indicies: [Int] = []
		for item in itemsToBeAdded {
			guard let index = index(of: item, in: sorted) else {
				continue
			}
			indicies.append(index)
		}
		
		for identifier in itemsToBeAdded {
      item(forIdentifier: identifier).updateToDesiredState()
		}
		
//    ////log(debug: "To be added = \(itemsToBeAdded)")
		return map(Array(itemsToBeAdded), with: indicies)
	}
	
	internal func name(of item: ItemType, in items: [AnyHashable: ItemType]) -> AnyHashable? {
		for (name, view) in items {
			if view == item {
				return name
			}
		}
		return nil
	}

	internal func isActive(_ item: AnyHashable, in items: [AnyHashable]) -> Bool {
		return index(of: item, in: items) != nil
	}

	internal func index(of section: AnyHashable, `in` sections: [AnyHashable]) -> Int? {
		return sections.index(where: { (entry: AnyHashable) -> Bool in
			section == entry
		})
	}

	internal func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}
	

	func sort(_ items: [AnyHashable], byPreferredOrder preferredOrder: [AnyHashable]) -> [AnyHashable] {
		let sortedNames = items.sorted(by: {(lhs: AnyHashable, rhs: AnyHashable) -> Bool in
			// Then we can figure out the preferred index
			let lhsIndex = index(of: lhs, in: preferredOrder, where: { $0 == $1 })!
			let rhsIndex = index(of: rhs, in: preferredOrder, where: { $0 == $1 })!
			
			// And we can sort them
			return lhsIndex < rhsIndex
		})
		
		return sortedNames
	}

}
