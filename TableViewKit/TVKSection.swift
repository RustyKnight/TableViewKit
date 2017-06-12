//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TVKSection: class, Hidable, Contextual {

	var name: String? { get }
	var rowCount: Int { get }

	var isHidden: Bool { get }

	var delegate: TVKSectionDelegate? { get set }

	func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
//	func segueIdentifierFor(tableView: UITableView, at indexPath: IndexPath) -> String?

	func willBecomeActive()
	func didBecomeInactive()

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)

	func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool
	func shouldSelectRow(at path: IndexPath) -> Bool

	func willDisplay(_ cell: UITableViewCell, forRowAt: Int)
	func didEndDisplaying(_ cell: UITableViewCell, forRowAt: Int)
}

public func ==(lhs: TVKSection, rhs: TVKSection) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public protocol TVKSectionDelegate {
	func tableViewSection(_ section: TVKSection, rowsWereRemovedAt rows: [Int])
	func tableViewSection(_ section: TVKSection, rowsWereAddedAt rows: [Int])
	func tableViewSection(_ section: TVKSection, rowsWereChangedAt rows: [Int])

	// The change is so significant, that's just easier to reload the
	// section
	func tableViewSectionDidChange(_ section: TVKSection)

	func tableViewSection(_ section: TVKSection, didFailWith: Error)
	func tableViewSection(
			_ section: TVKSection,
			showAlertAtRow: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewSectionDidStartLoading(_ section: TVKSection)
	func tableViewSectionDidCompleteLoading(_ section: TVKSection)

	func tableViewSection(
			_ tableViewSection: TVKSection,
			performSegueWithIdentifier: String,
			controller: TVKSegueController)

	func tableViewSection(_ tableViewSection: TVKSection,
	                      presentActionSheetAtRow: Int,
	                      title: String?,
	                      message: String?,
	                      actions: [UIAlertAction])

	func setContext(`for`: AnyHashable, to: Any?)
	func context(`for`: AnyHashable) -> Any?

}

public extension TVKSection {

	public func index(of cell: TVKRow, `in` values: [TVKRow]) -> Int? {
		return index(of: cell, in: values, where: { (value: TVKRow, entry: TVKRow) -> Bool in
			value == entry
		})
	}

	public func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}

}

public class TVKAnySection: TVKSection, TVKRowDelegate {

	public var name: String? = nil
	public var rowCount: Int = 0
	public var isHidden: Bool = true

	public var delegate: TVKSectionDelegate? = nil

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

	public func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool {
		fatalError("Not yet implemented")
	}

	public func shouldSelectRow(at path: IndexPath) -> Bool {
		fatalError("Not yet implemented")
	}

	public func setContext(`for` key: AnyHashable, to value: Any?) {
		fatalError("Not yet implemented")
	}

	public func context(`for` key: AnyHashable) -> Any? {
		fatalError("Not yet implemented")
	}

	public func tableViewRowWasUpdated(_ row: TVKRow) {
		fatalError("Not yet implemented")
	}

	public func tableViewRowWasRemoved(_ row: TVKRow) {
		fatalError("Not yet implemented")
	}

	public func tableViewRow(_ row: TVKRow, didFailWith error: Error) {
		fatalError("Not yet implemented")
	}

	public func tableViewRow(
			_ row: TVKRow,
			showAlertTitled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}

	public func tableViewRow(
			_ row: TVKRow,
			performSegueWithIdentifier identifier: String,
			controller: TVKSegueController) {
		fatalError("Not yet implemented")
	}

	public func tableViewRow(
			_ row: TVKRow,
			presentActionSheetWithTitle title: String?,
			message: String?,
			actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}

	public func willDisplay(_ cell: UITableViewCell, forRowAt: Int) {
		fatalError("Not yet implemented")
	}

	public func didEndDisplaying(_ cell: UITableViewCell, forRowAt: Int) {
		fatalError("Not yet implemented")
	}

	public func tableViewRow(
			_ model: TVKModel,
			showAlertAtRow: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
}

public class TVKDefaultSection: TVKAnySection {

	internal var rows: [TVKAnyRow] = []

	override public var rowCount: Int {
		get {
			return rows.count
		}

		set {
		}
	}

	override public init() {
		super.init()
	}

	public init(delegate: TVKSectionDelegate) {
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

	override public func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return rows[indexPath.row].cellFor(tableView: tableView, at: indexPath)
	}

	override public func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool {
		let context = TVKDefaultSectionRowContext(tableViewRowDelegate: self,
				tableViewController: controller,
				indexPath: path)
		let rowValue = rows[path.row]
		rowValue.didSelect(withContext: context)
		return true
	}

	override public func shouldSelectRow(at path: IndexPath) -> Bool {
		let rowValue = rows[path.row]
		return rowValue.shouldSelectRow()
	}

	internal func index(of value: TVKAnyRow) -> Int? {
		return index(of: value, in: rows) {
			$0 == $1
		}
	}

	internal func index(of value: TVKRow) -> Int? {
		return index(of: value, in: rows) {
			$0 == $1
		}
	}

	// MARK: TableViewRowDelegate

	public override func tableViewRowWasUpdated(_ row: TVKRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereChangedAt: [index])
	}

	public override func tableViewRowWasRemoved(_ row: TVKRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereRemovedAt: [index])
	}

	public override func tableViewRow(_ row: TVKRow, didFailWith error: Error) {
		delegate?.tableViewSection(self, didFailWith: error)
	}

	override public func tableViewRow(
			_ row: TVKRow,
			showAlertTitled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction]) {
		guard let index = index(of: row) else {
			return
		}
		delegate?.tableViewSection(
				self,
				showAlertAtRow: index,
				titled: title,
				message: message,
				preferredStyle: preferredStyle,
				actions: actions)
	}

	public override func tableViewRow(
			_ row: TVKRow,
			performSegueWithIdentifier identifier: String,
			controller: TVKSegueController) {
		delegate?.tableViewSection(self, performSegueWithIdentifier: identifier, controller: controller)
	}

	public override func tableViewRow(
			_ row: TVKRow,
			presentActionSheetWithTitle title: String?,
			message: String?,
			actions: [UIAlertAction]) {
		guard let delegate = delegate else {
			return
		}
		guard let rowIndex = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, presentActionSheetAtRow: rowIndex, title: title, message: message, actions: actions)
	}

	override public func setContext(`for` key: AnyHashable, to value: Any?) {
		guard let delegate = delegate else {
			return
		}
		delegate.setContext(for: key, to: value)
	}

	override public func context(`for` key: AnyHashable) -> Any? {
		guard let delegate = delegate else {
			return nil
		}
		return delegate.context(for: key)
	}
}
