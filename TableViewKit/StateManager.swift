//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

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
}

public protocol Statful {
	var actualState: State {get}
	var desiredState: State {get}
	
	// Move desiredState to actualState
	func updateToDesiredState()
}

public func ==(lhs: Statful, rhs: Statful) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public typealias Evaluator<T> = (T, T) -> Bool

public class StateManager<ItemType: Statful> {

	let allItems: [AnyHashable: ItemType]
	let preferredOrder: [AnyHashable]

	public init(
//		activeItems: [ItemType],
		allItems: [AnyHashable: ItemType],
		preferredOrder: [AnyHashable]) {
//		self.activeItems = activeItems
		self.allItems = allItems
		self.preferredOrder = preferredOrder
	}
	
	func wantsToBeHidden(_ item: ItemType) -> Bool {
		return item.desiredState == .hide && item.actualState != .hide
	}
	
	func wantsToBeShown(_ item: ItemType) -> Bool {
		return item.desiredState == .show && item.actualState == .hide
	}
	
	func applyDesiredState(basedOn activeItems: [ItemType]) -> [Operation: [Int]] {
		var operations: [Operation: [Int]] = [:]
		
		var items: [ItemType] = []
		items.append(contentsOf: activeItems)
		
		// Items to be removed
		let toDelete = hideItems(in: items)
		for entry in toDelete {
			items.remove(at: entry.index)
		}
		// Items to be inserted
		let toInsert = showItems(in: items)
		for entry in toDelete {
			items.insert(entry.value, at: entry.index)
		}
		
		operations[.delete] = toDelete.map { $0.index }
		operations[.insert] = toInsert.map { $0.index }
		operations[.update] = updateItems(in: items)

		return operations
	}
	
	func updateItems(in activeItems: [ItemType]) -> [Int] {
		let items = activeItems.filter { $0.desiredState == .reload }
		let rowIndicies = indices(of: items, in: activeItems)

		for item in items {
			item.updateToDesiredState()
		}

		return rowIndicies
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
	
	internal func map(_ items: [ItemType], with indicies: [Int]) -> [(value: ItemType, index: Int)] {
		var results: [(value: ItemType, index: Int)] = []
		for index in 0..<items.count {
			results.append((items[index], indicies[index]))
		}
		return results
	}

	internal func hideItems(in activeItems: [ItemType]) -> [(value: ItemType, index: Int)] {
		let itemsToBeRemoved = activeItems.filter {	return wantsToBeHidden($0) }
		let rowIndicies = indices(of: itemsToBeRemoved, in: activeItems)
		
		for item in itemsToBeRemoved {
			item.updateToDesiredState()
		}
		
		return map(itemsToBeRemoved, with: rowIndicies)
	}

	internal func indices(of from: [ItemType], `in` source: [ItemType]) -> [Int] {
		let values: [Int] = from.map { (item: ItemType) -> Int in
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
		let sortedNames = items.sorted(by: {(lhs: AnyHashable, rhs: AnyHashable) -> Bool in
			// Then we can figure out the preferred index
			let lhsIndex = index(of: lhs, in: preferredOrder, where: { $0 == $1 })!
			let rhsIndex = index(of: rhs, in: preferredOrder, where: { $0 == $1 })!
			
			// And we can sort them
			return lhsIndex < rhsIndex
		})
		
		return sortedNames.map { allItems[$0]! }
	}
	
	internal func showItems(in activeItems: [ItemType]) -> [(value: ItemType, index: Int)] {
		
		var itemsToBeAdded: [ItemType] = []
		
		for name in preferredOrder {
			guard let item = allItems[name] else {
				continue
			}
			
			guard wantsToBeShown(item) else {
				continue
			}
			
			guard index(of: name, in: preferredOrder, where: { $0 == $1 }) != nil else {
				continue
			}
			
			guard !isActive(section: item, in: activeItems) else {
				continue
			}
			
			itemsToBeAdded.append(item)
		}
		
		var updateActivity: [ItemType] = []
		updateActivity.append(contentsOf: activeItems)
		updateActivity.append(contentsOf: itemsToBeAdded)
		
		// This sorts the active based on the order of the specified
		// sectionOrder array
		updateActivity.sort { (item1: ItemType, item2: ItemType) -> Bool in
			// Got to get the SectionHeader for the view
			let name1 = name(of: item1, in: allItems)!
			let name2 = name(of: item2, in: allItems)!

			// Then we can figure out the preferred index
			let index1 = index(of: name1, in: preferredOrder, where: { $0 == $1 })!
			let index2 = index(of: name2, in: preferredOrder, where: { $0 == $1 })!

			// And we can sort them
			return index1 < index2
		}
		
		var indicies: [Int] = []
		for item in itemsToBeAdded {
			guard let index = index(of: item, in: updateActivity) else {
				continue
			}
			indicies.append(index)
		}
		
		for item in itemsToBeAdded {
			item.updateToDesiredState()
		}
		
		return map(itemsToBeAdded, with: indicies)
	}
	
	internal func name(of item: ItemType, in items: [AnyHashable: ItemType]) -> AnyHashable? {
		for (name, view) in items {
			if view == item {
				return name
			}
		}
		return nil
	}

	internal func isActive(section: ItemType, in items: [ItemType]) -> Bool {
		return index(of: section, in: items) != nil
	}

	internal func index(of section: ItemType, `in` sections: [ItemType]) -> Int? {
		return sections.index(where: { (entry: ItemType) -> Bool in
			section == entry
		})
	}

	internal func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}

}
