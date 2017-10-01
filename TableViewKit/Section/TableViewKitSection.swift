//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewKitSectionDelegate {
	func tableViewSection(_ section: TableViewKitSection, rowsWereRemovedAt rows: [Int])
	func tableViewSection(_ section: TableViewKitSection, rowsWereAddedAt rows: [Int])
	func tableViewSection(_ section: TableViewKitSection, rowsWereChangedAt rows: [Int])

	// The change is so significant, that's just easier to reload the
	// section
	func tableViewSectionDidChange(_ section: TableViewKitSection)

	func tableViewSection(_ section: TableViewKitSection, didFailWith: Error)
	func tableViewSection(
			_ section: TableViewKitSection,
			showAlertAtRow: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewSectionDidStartLoading(_ section: TableViewKitSection)
	func tableViewSectionDidCompleteLoading(_ section: TableViewKitSection)

	func tableViewSection(
			_ tableViewSection: TableViewKitSection,
			performSegueWithIdentifier: String,
			controller: TableViewKitSegueController)

	func tableViewSection(_ tableViewSection: TableViewKitSection,
	                      presentActionSheetAtRow: Int,
	                      title: String?,
	                      message: String?,
	                      actions: [UIAlertAction])

	func setContext(`for`: AnyHashable, to: Any?)
	func context(`for`: AnyHashable) -> Any?

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
	func cell(withIdentifier: String, at indexPath: IndexPath) -> UITableViewCell
}

public protocol TableViewKitSection: class, Statful, Contextual {

	var name: String? { get }
	var rowCount: Int { get }

	// This can only be true if the desired and actual states are hidden
	var isHidden: Bool { get }
	var desiredState: State { get }
	var actualState: State { get }

	var delegate: TableViewKitSectionDelegate { get }

//	func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
//	func segueIdentifierFor(tableView: UITableView, at indexPath: IndexPath) -> String?

	func willBecomeActive()
	func didBecomeInactive()

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)

	func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool
	func shouldSelectRow(at path: IndexPath) -> Bool

	func willDisplay(_ cell: UITableViewCell, forRowAt: Int)
	func didEndDisplaying(_ cell: UITableViewCell, forRowAt: Int)
	
	func cell(forRowAt indexPath: IndexPath) -> UITableViewCell
	
	func applyDesiredState() -> [Operation:[Int]]
}

public func ==(lhs: TableViewKitSection, rhs: TableViewKitSection) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public extension TableViewKitSection {

	public func index(of cell: TableViewKitRow, `in` values: [TableViewKitRow]) -> Int? {
		return index(of: cell, in: values, where: { (value: TableViewKitRow, entry: TableViewKitRow) -> Bool in
			value == entry
		})
	}

	public func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}

}

