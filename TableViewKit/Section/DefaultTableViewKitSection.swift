//
//  DefaultTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultTableViewKitSection<Identifier: SectionIdentifiable>: AnyTableViewKitSection {
	
	public var allRows: [AnyHashable: AnyTableViewKitRow] = [:]
	public var preferredRowOrder: [AnyHashable] = []
	public var activeRows: [AnyHashable] = []
	
	public override var rowCount: Int {
		set {}
		
		get {
			return activeRows.count
		}
	}
	
	public init(identifier: Identifier,
							title: String? = nil,
							footer: String? = nil,
							delegate: TableViewKitSectionDelegate,
							allRows: [AnyHashable: AnyTableViewKitRow],
							preferredOrder: [AnyHashable]) {
		self.allRows = allRows
		self.preferredRowOrder = preferredOrder
		super.init(identifier: identifier, title: title, footer: footer, delegate: delegate)
	}
  
  public func identifierForActiveRow(at: Int) -> AnyHashable {
    return activeRows[at]
  }

	public override func rowIndex(for row: TableViewKitRow) -> Int? {
		guard let identifier = identifier(for: row) else {
			return nil
		}
		
		return activeRows.index(where: { $0 == identifier })
	}
	
	func row(withIdentifier identifier: AnyHashable) -> TableViewKitRow {
		return allRows[identifier]!
	}

	func row(at index: Int) -> TableViewKitRow {
		return row(withIdentifier: identifier(forRowAt: index))
	}

  func activeRow(at index: Int) -> TableViewKitRow {
    return row(withIdentifier: identifier(forActiveRowAt: index))
  }
	
	func identifier(forActiveRowAt index: Int) -> AnyHashable {
		return activeRows[index]
	}

	func identifier(forRowAt index: Int) -> AnyHashable {
		return preferredRowOrder[index]
	}

	open override func willBecomeActive() {
		for row in allRows.values {
			row.willBecomeActive()
		}
	}
	
	open override func didBecomeInactive() {
		for row in allRows.values {
			row.didBecomeInactive()
		}
	}
	
	open override func willDisplay(_ cell: UITableViewCell, forRowAt rowIndex: Int) {
    activeRow(at: rowIndex).willDisplay(cell)
	}

	open override func didEndDisplaying(cell: UITableViewCell, withIdentifier identifier: CellIdentifiable) {
		guard let id = identifier as? AnyHashable else {
			return
		}
		guard let row = allRows[id] else {
			return
		}
		row.didEndDisplaying(cell)
	}
	
	open override func applyDesiredState() -> [Operation : [Int]] {
		let stateManager = StateManager(allItems: allRows,
		                                preferredOrder: preferredRowOrder)
    
    let operations = stateManager.operationsForDesiredState(basedOn: activeRows)
		activeRows = stateManager.apply(operations: operations, to: activeRows, sortBy: preferredRowOrder)
		
		var operationPaths: [Operation: [Int]] = [:]
		operationPaths[.insert] = operations.insert.map { $0.index }
		operationPaths[.update] = operations.update.map { $0.index }
		operationPaths[.delete] = operations.delete.map { $0.index }
		
		return operationPaths
	}
	
	open override func updateToDesiredState() {
    actualState = desiredState == .reload ? .show : actualState
	}
	
	open override func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
    return activeRow(at: indexPath.row).cell(forRowAt: indexPath)
	}
	
	override open func sharedContext(for key: AnyHashable, didChangeTo to: Any?) {
    for row in allRows.values {
      row.sharedContext(for: key, didChangeTo: to)
    }
	}
	
	override open func didSelectRow(at path: IndexPath) -> Bool {
    return activeRow(at: path.row).didSelect()
	}
	
	override open func shouldSelectRow(at path: IndexPath) -> Bool {
    return activeRow(at: path.row).shouldSelectRow()
	}
  
  func identifier(for row: TableViewKitRow) -> AnyHashable? {
    return allRows.filter { $1 == row }.first?.key
  }

  public func index(of value: TableViewKitRow) -> Int? {
    guard let id = identifier(for: value) else {
      return nil
    }
    return activeRows.index(of: id)
  }
	
	// MARK: TableViewRowDelegate
	
	open override func stateDidChange(for row: TableViewKitRow) {
		delegate.stateDidChange(for: self)
	}

	open override func tableViewRow(_ row: TableViewKitRow, didFailWith error: Error) {
		delegate.tableViewSection(self, didFailWith: error)
	}
	
	override open func tableViewRow(
		_ row: TableViewKitRow,
		showAlertTitled title: String?,
		message: String?,
		preferredStyle: UIAlertControllerStyle,
		actions: [UIAlertAction]) {
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(
			self,
			showAlertAtRow: index,
			titled: title,
			message: message,
			preferredStyle: preferredStyle,
			actions: actions)
	}
	
	open override func tableViewRow(
		_ row: TableViewKitRow,
		performSegueWithIdentifier identifier: SegueIdentifiable,
		controller: TableViewKitSegueController) {
		delegate.tableViewSection(self, performSegueWithIdentifier: identifier, controller: controller)
	}
	
	open override func tableViewRow(
		_ row: TableViewKitRow,
		presentActionSheetWithTitle title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		guard let rowIndex = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, presentActionSheetAtRow: rowIndex, title: title, message: message, actions: actions)
	}
	
	override open func setContext(`for` key: AnyHashable, to value: Any?) {
		delegate.setContext(for: key, to: value)
	}
	
	override open func context(`for` key: AnyHashable) -> Any? {
		return delegate.context(for: key)
	}
}
