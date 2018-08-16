//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewKitSegueController {
	func shouldPerformSegue(withIdentifier: SegueIdentifiable, sender: Any?) -> Bool
	func segueRejectedReason(forIdentifier: SegueIdentifiable, sender: Any?) -> String?
	func prepare(for segue: UIStoryboardSegue)
	func unwound(from segue: UIStoryboardSegue)
}

public protocol TableViewKitRowDelegate {

	func stateDidChange(for row: TableViewKitRow)
	
	// This is a "command" or "action" chain which allows a row
	// to request that the UITableViewController perform some
	// operation
	func perform(_ row: TableViewKitRow, action: Any, value: Any?)

	func tableViewRow(_ row: TableViewKitRow, didFailWith error: Error)
	func tableViewRow(
			_ row: TableViewKitRow,
			showAlertTitled title: String?,
			message: String?,
			actions: [UIAlertAction])

	func tableViewRow(_ row: TableViewKitRow, performSegueWithIdentifier identifier: SegueIdentifiable, controller: TableViewKitSegueController)

	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?

	func tableViewRow(
			_ row: TableViewKitRow,
			presentActionSheetWithTitle title: String?,
			message: String?,
			actions: [UIAlertAction])
	
	// Returns the active row index of the specified row, or nil. This could mean that the row
	// is hidden
	func rowIndex(for: TableViewKitRow) -> Int?

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
//	func cell(withIdentifier: CellIdentifiable, at indexPath: IndexPath) -> UITableViewCell

	// This is a compromise.  It's not unforseeable that a API will need to get a reference
	// to a cell to perform some pre/post conditions on it.  The implementation is capable
	// of retruning nil if the it's implementation can't support this kind of interaction
	func cell(withIdentifier: CellIdentifiable) -> UITableViewCell
}

//public protocol TableViewKitSectionRowContext {
//  var tableViewRowDelegate: TableViewKitRowDelegate { get }
//  var tableViewController: UITableViewController { get }
//  var indexPath: IndexPath { get }
//}
//
//public struct DefaultTableViewKitSectionRowContext: TableViewKitSectionRowContext {
//  public let tableViewRowDelegate: TableViewKitRowDelegate
//  public let tableViewController: UITableViewController
//  public let indexPath: IndexPath
//}

public protocol TableViewKitRow: Stateful {
	var delegate: TableViewKitRowDelegate { get }

	var isHidden: Bool { get }

	func didSelect() -> Bool
	func shouldSelectRow() -> Bool

	// This was a hack around a problem which was not particularly pleasent and required the row
	// to become coupled with the implmentation and draw assumptions about the the configuration
	// it shouldn't need or have to
//	func cellSelection(didChangeTo path: IndexPath)

	func cell(forRowAt indexPath: IndexPath) -> UITableViewCell
	func willBecomeActive()
	func didBecomeInactive()

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)
  
  func willDisplay(_ cell: UITableViewCell)
  func didEndDisplaying(_ cell: UITableViewCell)
}

public func ==(lhs: TableViewKitRow, rhs: TableViewKitRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public func ==(lhs: AnyTableViewKitRow, rhs: AnyTableViewKitRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

