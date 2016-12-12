//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewSection: class, Hidable {

	var name: String? {get}
	var rowCount: Int {get}

	var isHidden: Bool {get}

	var delegate: TableViewSectionDelegate? {get set}

	func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
//	func segueIdentifierFor(tableView: UITableView, at indexPath: IndexPath) -> String?

	func willBecomeActive()
	func didBecomeInactive()

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)

	func didSelectRow(at path: IndexPath) -> Bool
}

public func ==(lhs: TableViewSection, rhs: TableViewSection) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public protocol TableViewSectionDelegate {
	func tableViewSection(_ section: TableViewSection, rowsWereRemovedAt rows: [Int])
	func tableViewSection(_ section: TableViewSection, rowsWereAddedAt rows: [Int])
	func tableViewSection(_ section: TableViewSection, rowsWereChangedAt rows: [Int])

	// The change is so significant, that's just easier to reload the
	// section
	func sectionDidChange(_ section: TableViewSection)

	func section(_ section: TableViewSection, didFailWith: Error)

	func didStartLoading(section: TableViewSection)
	func didCompleteLoading(section: TableViewSection)

	func performSegue(withIdentifier: String, controller: TableViewSegueController)

	func presentActionSheet(`for` tableViewSection: TableViewSection, row: Int, title: String?, message: String?, actions: [UIAlertAction])

	func setContext(`for`: AnyHashable, to: Any?)
	func context(`for`: AnyHashable) -> Any?

}

public extension TableViewSection {

	func index(of cell: TableViewRow, `in` values: [TableViewRow]) -> Int? {
		return index(of: cell, in: values, where: { (value: TableViewRow, entry: TableViewRow) -> Bool in
			value == entry
		})
	}

	func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}

}

//public extension ReusableTableViewCellHandler where Self: TableViewSection, CellIdentifierType.RawValue == String {
//
//	func dequeueReusableCell(from tableView: UITableView, withIdentifier identifier: CellIdentifierType) -> UITableViewCell? {
//		return tableView.dequeueReusableCell(withIdentifier: identifier.rawValue)
//	}
//
//	func dequeueReusableCell(from tableView: UITableView, withIdentifier identifier: CellIdentifierType, for indexPath: IndexPath) -> UITableViewCell {
//		return tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
//	}
//
//	func dequeueReusableCell(from controller: UITableViewController, withIdentifier identifier: CellIdentifierType) -> UITableViewCell? {
//		return dequeueReusableCell(from: controller.tableView, withIdentifier: identifier)
//	}
//
//	func dequeueReusableCell(from controller: UITableViewController, withIdentifier identifier: CellIdentifierType, for indexPath: IndexPath) -> UITableViewCell {
//		return dequeueReusableCell(from: controller.tableView, withIdentifier: identifier, for: indexPath)
//	}
//}

public class AnyTableViewSection: TableViewSection, TableViewRowDelegate {

	public var name: String? = nil
	public var rowCount: Int = 0
	public var isHidden: Bool = true

	public var delegate: TableViewSectionDelegate? = nil

	public func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		fatalError("Not yet implemented")
	}

	public func willBecomeActive() {
		fatalError("Not yet implemented")
	}

	public func didBecomeInactive() {
		fatalError("Not yet implemented")
	}

	public func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?) {
		fatalError("Not yet implemented")
	}

	public func didSelectRow(at path: IndexPath) -> Bool {
		fatalError("Not yet implemented")
	}

	public func rowWasUpdated(_ row: TableViewRow) {
		fatalError("Not yet implemented")
	}

	public func rowWasRemoved(_ row: TableViewRow) {
		fatalError("Not yet implemented")
	}

	public func row(_ row: TableViewRow, didFailWith error: Error) {
		fatalError("Not yet implemented")
	}

	public func performSegue(withIdentifier: String, controller: TableViewSegueController) {
		fatalError("Not yet implemented")
	}

	public func setContext(`for` key: AnyHashable, to value: Any?) {
		fatalError("Not yet implemented")
	}

	public func context(`for` key: AnyHashable) -> Any? {
		fatalError("Not yet implemented")
	}

	public func presentActionSheet(`for`: TableViewRow, title: String?, message: String?, actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}

}

public class DefaultTableViewSection: AnyTableViewSection {

	internal var hidableItemsManager: HidableItemsManager<AnyTableViewRow>!
	internal var rows: [AnyTableViewRow] = []

	override public var rowCount: Int {
		get {
			return rows.count
		}

		set {}
	}

	override public init() {
		super.init()
	}

	public init(delegate: TableViewSectionDelegate) {
		super.init()
		self.delegate = delegate
		setup()
	}

	internal func setup() {
	}

	override public func sharedContext(for key: AnyHashable, didChangeTo to: Any?) {
		for row in rows {
			row.sharedContext(for: key, didChangeTo: to)
		}
	}

	internal func prepareHidableItemsManagerWith(_ rows: [AnyTableViewRow], allRows: [AnyHashable: AnyTableViewRow], preferredOrder: [AnyHashable]) {
		hidableItemsManager = HidableItemsManager(activeItems: rows, allItems: allRows, preferredOrder: preferredOrder)
		updateContents()
	}

	internal func updateContents() {
		rows = updateContents(with: hidableItemsManager)
	}

	internal func updateContents(with manager: HidableItemsManager<AnyTableViewRow>) -> [AnyTableViewRow] {
		let rows = manager.update(wereRemoved: { indices, result in
			self.rowsWereRemoved(from: indices, withRowsAfter: result)
		}, wereAdded: { indices, result in
			self.rowsWereAdded(at: indices, withRowsAfter: result)
		})
		return rows
	}

	override public func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return rows[indexPath.row].cellFor(tableView: tableView, at: indexPath)
	}

	override public func willBecomeActive() {
		for row in rows {
			guard !row.isHidden else {
				continue
			}
			row.willBecomeActive(self)
		}
	}

	override public func didBecomeInactive() {
		for row in rows {
			guard !row.isHidden else {
				continue
			}
			row.didBecomeInactive(self)
		}
	}

	override public func didSelectRow(at path: IndexPath) -> Bool {
		let context = DefaultTableViewSectionRowContext(tableViewRowDelegate: self,
				indexPath: path)
		let rowValue = rows[path.row]
		rowValue.didSelect(withContext: context)
		return true
	}

	internal func index(of value: AnyTableViewRow) -> Int? {
		return index(of: value, in: rows) { $0 == $1  }
	}

	internal func index(of value: TableViewRow) -> Int? {
		return index(of: value, in: rows) { $0 == $1  }
	}

	internal func rowsWereRemoved(from indices: [Int], withRowsAfter result: [AnyTableViewRow]) {
		// Want a reference to the rows which are going to be removed, so we can
		// deactivate them, but only AFTER we notify the delegate, as the deactivation
		// might cause updates to be triggered
		var oldRows: [AnyTableViewRow] = rows.filter { row in indices.contains(index(of: row) ?? -1) }

		self.rows = result
		self.delegate?.tableViewSection(self, rowsWereRemovedAt: indices)

		for row in oldRows {
			row.didBecomeInactive(self)
		}
	}

	internal func rowsWereAdded(at indices: [Int], withRowsAfter result: [AnyTableViewRow]) {
		self.rows = result
		self.delegate?.tableViewSection(self, rowsWereAddedAt: indices)
		for index in indices {
			self.rows[index].willBecomeActive(self)
		}
	}

	// MARK: TableViewRowDelegate

	override public func rowWasUpdated(_ row: TableViewRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		self.delegate?.tableViewSection(self, rowsWereChangedAt: [index])
	}

	override public func rowWasRemoved(_ row: TableViewRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		self.delegate?.tableViewSection(self, rowsWereRemovedAt: [index])
	}

//	public func remove(row: TableViewRow) {
//		guard let index = index(of: row, in: rows, where: { $0 == $1 }) else {
//			log(warning: "Failed to find a matching index for \(row)")
//			return
//		}
//
//		rows.remove(at: index)
//		guard let delegate = delegate else {
//			return
//		}
//		delegate.rows(wereRemoved: [index], from: self)
//	}

	override public func row(_ row: TableViewRow, didFailWith error: Error) {
		delegate?.section(self, didFailWith: error)
	}

	override public func performSegue(withIdentifier identifier: String, controller: TableViewSegueController) {
		delegate?.performSegue(withIdentifier: identifier, controller: controller)
	}

	override public func presentActionSheet(`for` tableViewRow: TableViewRow, title: String?, message: String?, actions: [UIAlertAction]) {
		guard let rowIndex = index(of: tableViewRow) else {
			return
		}
		delegate?.presentActionSheet(for: self, row: rowIndex, title: title, message: message, actions: actions)
	}

	override public func setContext(`for` key: AnyHashable, to value: Any?) {
		delegate?.setContext(for: key, to: value)
	}

	override public func context(`for` key: AnyHashable) -> Any? {
		return delegate?.context(for: key)
	}
}
