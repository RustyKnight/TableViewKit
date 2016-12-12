//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewSection: class, Hidable, Contextual {

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
	func tableViewSectionDidChange(_ section: TableViewSection)

	func tableViewSection(_ section: TableViewSection, didFailWith: Error)

	func tableViewSectionDidStartLoading(_ section: TableViewSection)
	func tableViewSectionDidCompleteLoading(_ section: TableViewSection)

	func tableViewSection(_ tableViewSection: TableViewSection, performSegueWithIdentifier: String, controller: TableViewSegueController)

	func tableViewSection(_ tableViewSection: TableViewSection,
	                      presentActionSheetAtRow: Int,
	                      title: String?,
	                      message: String?,
	                      actions: [UIAlertAction])

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

	public func setContext(`for` key: AnyHashable, to value: Any?) {
		fatalError("Not yet implemented")
	}

	public func context(`for` key: AnyHashable) -> Any? {
		fatalError("Not yet implemented")
	}

	public func tableViewRowWasUpdated(_ row: TableViewRow) {
		fatalError("Not yet implemented")
	}
	
	public func tableViewRowWasRemoved(_ row: TableViewRow) {
		fatalError("Not yet implemented")
	}
	
	public func tableViewRow(_ row: TableViewRow, didFailWith error: Error) {
		fatalError("Not yet implemented")
	}
	
	public func tableViewRow(_ row: TableViewRow, performSegueWithIdentifier identifier: String, controller: TableViewSegueController) {
		fatalError("Not yet implemented")
	}
	
	public func tableViewRow(_ row: TableViewRow, presentActionSheetWithTitle title: String?, message: String?, actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}

}

public class DefaultTableViewSection: AnyTableViewSection {

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

	override public func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		return rows[indexPath.row].cellFor(tableView: tableView, at: indexPath)
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

	// MARK: TableViewRowDelegate
	
	public override func tableViewRowWasUpdated(_ row: TableViewRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereChangedAt: [index])
	}
	
	public override func tableViewRowWasRemoved(_ row: TableViewRow) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: row) else {
			return
		}
		delegate.tableViewSection(self, rowsWereRemovedAt: [index])
	}
	
	public override func tableViewRow(_ row: TableViewRow, didFailWith error: Error) {
		delegate?.tableViewSection(self, didFailWith: error)
	}
	
	public override func tableViewRow(_ row: TableViewRow, performSegueWithIdentifier identifier: String, controller: TableViewSegueController) {
		delegate?.tableViewSection(self, performSegueWithIdentifier: identifier, controller: controller)
	}
	
	public override func tableViewRow(_ row: TableViewRow, presentActionSheetWithTitle title: String?, message: String?, actions: [UIAlertAction]) {
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
