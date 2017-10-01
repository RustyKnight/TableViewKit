//
//  DefaultTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultTableViewKitSection<RowIdentifier: Hashable>: AnyTableViewKitSection {
	
	public var allRows: [RowIdentifier: AnyTableViewKitRow] = [:]
	public var preferredRowOrder: [RowIdentifier] = []
	public var activeRows: [RowIdentifier] = []
	
	public override var rowCount: Int {
		set {}
		
		get {
			return activeRows.count
		}
	}
	
	public override init(delegate: TableViewKitSectionDelegate) {
		super.init(delegate: delegate)
		commonInit()
	}
	
	open func commonInit() {
	}
	
	func row(withIdentifier identifier: RowIdentifier) -> TableViewKitRow {
		return allRows[identifier]!
	}
  
  func activeRow(at index: Int) -> TableViewKitRow {
    return row(withIdentifier: identifier(forActiveRowAt: index))
  }
	
	func identifier(forActiveRowAt index: Int) -> RowIdentifier {
		return activeRows[index]
	}
	
	open override func willBecomeActive() {
		for identifier in activeRows {
			row(withIdentifier: identifier).willBecomeActive()
		}
	}
	
	open override func didBecomeInactive() {
		for identifier in activeRows {
			row(withIdentifier: identifier).didBecomeInactive()
		}
	}
	
	open override func willDisplay(_ cell: UITableViewCell, forRowAt rowIndex: Int) {
    activeRow(at: rowIndex).willDisplay(cell)
	}
	
	open override func didEndDisplaying(_ cell: UITableViewCell, forRowAt rowIndex: Int) {
		activeRow(at: rowIndex).didEndDisplaying(cell)
	}
	
	open override func applyDesiredState() -> [Operation : [Int]] {
		let stateManager = StateManager(allItems: allRows,
		                                preferredOrder: preferredRowOrder)
    
    return stateManager.applyDesiredState(basedOn: activeRows)
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
  
  func identifier(for row: TableViewKitRow) -> RowIdentifier? {
    return allRows.filter { $1 == row }.first?.key
  }

  public func index(of value: TableViewKitRow) -> Int? {
    guard let id = identifier(for: value) else {
      return nil
    }
    return activeRows.index(of: id)
  }
	
	// MARK: TableViewRowDelegate
	
	open override func tableViewRowWasUpdated(_ row: TableViewKitRow) {
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereChangedAt: [index])
	}
	
	open override func tableViewRowWasRemoved(_ row: TableViewKitRow) {
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereRemovedAt: [index])
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
		performSegueWithIdentifier identifier: String,
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
