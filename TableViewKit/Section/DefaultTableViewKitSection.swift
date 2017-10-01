//
//  DefaultTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultTableViewKitSectionSection<RowIdentifier: Hashable>: AnyTableViewKitSection {
	
	public var allRows: [RowIdentifier: TableViewKitRow] = [:]
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
		row(withIdentifier: identifier(forActiveRowAt: rowIndex)).willDisplay(cell)
	}
	
	open override func didEndDisplaying(_ cell: UITableViewCell, forRowAt rowIndex: Int) {
		row(withIdentifier: identifier(forActiveRowAt: rowIndex)).didEndDisplaying(cell)
	}
	
	open func applyDesiredState() -> [Operation : [Int]] {
		let stateManager = StateManager(allItems: allRows,
		                                preferredOrder: preferredRowOrder)
	}
	
	open func updateToDesiredState() {
		actualState = desiredState
	}
	
	open override func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		return rows[indexPath.section].cell(forRowAt: indexPath)
	}
	
	override open func sharedContext(for key: AnyHashable, didChangeTo to: Any?) {
		for row in rows {
			row.sharedContext(for: key, didChangeTo: to)
		}
	}
	
	override open func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool {
		let context = TVKDefaultSectionRowContext(tableViewRowDelegate: self,
		                                          tableViewController: controller,
		                                          indexPath: path)
		let rowValue = rows[path.row]
		rowValue.didSelect(withContext: context)
		return true
	}
	
	override open func shouldSelectRow(at path: IndexPath) -> Bool {
		let rowValue = rows[path.row]
		return rowValue.shouldSelectRow()
	}
	
	public func index(of value: AnyTableViewKitRow) -> Int? {
		return index(of: value, in: rows) {
			$0 == $1
		}
	}
	
	public func index(of value: TableViewKitRow) -> Int? {
		return index(of: value, in: rows) {
			$0 == $1
		}
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
