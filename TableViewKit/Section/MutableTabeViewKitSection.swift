//
//  MutableTabeViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

public protocol MutableTabeViewKitSection: TableViewKitSection {
	
	func can(deleteRowAt index: Int) -> Bool
	
	/**
	Deletes the row from the section with the specified identifier.  This affects both visible and hidden rows
	*/
	func delete(rowWithIdentifier identifier: AnyHashable)
	
	/**
	Deletes the row from the section at the specified visible index
	*/
	func delete(rowAt index: Int)

	func append(row: AnyTableViewKitRow, withIdentifier: AnyHashable)
//	func insert(row: TableViewKitRow, withIdentifier: AnyHashable, afterRowWithIdentifier: AnyHashable)
//	func insert(row: TableViewKitRow, withIdentifier: AnyHashable, beforeRowWithIdentifier: AnyHashable)

}

open class DefaultMutableTabeViewKitSection<Identifier: SectionIdentifiable>: DefaultTableViewKitSection<Identifier>, MutableTabeViewKitSection{
	
	public override init(identifier: Identifier,
							title: String? = nil,
							footer: String? = nil,
							delegate: TableViewKitSectionDelegate) {
		super.init(identifier: identifier, title: title, footer: footer, delegate: delegate)
	}
	
	public override init(identifier: Identifier,
							title: String? = nil,
							footer: String? = nil,
							delegate: TableViewKitSectionDelegate,
							allRows: [AnyHashable: AnyTableViewKitRow],
							preferredOrder: [AnyHashable]) {
		super.init(identifier: identifier, title: title, footer: footer, delegate: delegate, allRows: allRows, preferredOrder: preferredOrder)
	}
	
	open func insert(row: AnyTableViewKitRow, withIdentifier id: AnyHashable, at index: Int) {
		guard index < preferredRowOrder.count else {
			append(row: row, withIdentifier: id)
			return
		}
		
		allRows[id] = row
		preferredRowOrder.insert(id, at: index)
		
		desiredState = actualState.showOrReload()
		notifyIfStateChanged()
	}
	
	open func append(row: AnyTableViewKitRow, withIdentifier id: AnyHashable) {
		allRows[id] = row
		preferredRowOrder.append(id)

		desiredState = actualState.showOrReload()
		notifyIfStateChanged()
	}
	
	open func can(deleteRowAt index: Int) -> Bool {
		let id = identifier(forRowAt: index)
		guard let row = self.row(withIdentifier: id) as? MutableTableViewKitRow else {
			return false
		}
		return row.isDeletable
	}
	
	/**
	Deletes the row from the section with the specified identifier.  This affects both visible and hidden rows
	*/
	open func delete(rowWithIdentifier identifier: AnyHashable) {
		guard let row = self.row(withIdentifier: identifier) as? MutableTableViewKitRow else {
			return
		}
		row.delete()
	}

	/**
		Deletes the row from the section at the specified visible index
	*/
	open func delete(rowAt index: Int) {
		self.delete(rowWithIdentifier: self.identifier(forRowAt: index))
	}
	
	public override func applyModificationStates() -> [Operation : [Int]] {
		let desiredState = super.applyModificationStates()
		
		var deleteIDs: [AnyHashable] = []

		for row in allRows {
			guard row.value.desiredState == .delete else {
				continue
			}
			deleteIDs.append(row.key)
		}

		for id in deleteIDs {
			if let index = indexOfActiveItem(forIdentifier: id) {
				log(warning: "Active row with identifier [\(id)] wants to be deleted - should aleady have been removed")
				activeRows.remove(at: index)
			}
			allRows[id] = nil
			if let index = preferredRowOrder.index(of: id) {
				preferredRowOrder.remove(at: index)
			}
		}

		return desiredState
	}
	
//	open override func applyDesiredState() -> [Operation : [Int]] {
//		let desiredState = super.applyDesiredState()
//
//		var deleteIDs: [AnyHashable] = []
//
//		for row in allRows {
//			guard row.value.desiredState == .delete else {
//				continue
//			}
//			deleteIDs.append(row.key)
//		}
//
//		for id in deleteIDs {
//			if let index = indexOfActiveItem(forIdentifier: id) {
//				log(warning: "Active row with identifier [\(id)] wants to be deleted - should aleady have been removed")
//				activeRows.remove(at: index)
//			}
//			allRows[id] = nil
//			if let index = preferredRowOrder.index(of: id) {
//				preferredRowOrder.remove(at: index)
//			}
//		}
//
//		return desiredState
//	}
	
	func indexOfActiveItem(forIdentifier id: AnyHashable) -> Int? {
		return activeRows.index(of: id)
	}

}
