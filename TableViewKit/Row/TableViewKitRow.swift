//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewKitSegueController {
	func shouldPerformSegue(withIdentifier: String, sender: Any?) -> Bool
	func prepare(for segue: UIStoryboardSegue)
	func unwound(from segue: UIStoryboardSegue)
}

public protocol TableViewKitRowDelegate {

	func tableViewRowWasUpdated(_ row: TableViewKitRow)
	func tableViewRowWasRemoved(_ row: TableViewKitRow)

//	func remove(row: TableViewRow)

	func tableViewRow(_ row: TableViewKitRow, didFailWith error: Error)
	func tableViewRow(
			_ row: TableViewKitRow,
			showAlertTitled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewRow(_ row: TableViewKitRow, performSegueWithIdentifier identifier: String, controller: TableViewKitSegueController)

	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?

	func tableViewRow(
			_ row: TableViewKitRow,
			presentActionSheetWithTitle title: String?,
			message: String?,
			actions: [UIAlertAction])

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
	func cell(withIdentifier: String, at indexPath: IndexPath) -> UITableViewCell
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

public protocol TableViewKitRow: Statful {
	var delegate: TableViewKitRowDelegate { get }

	func didSelect() -> Bool
	func shouldSelectRow() -> Bool

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

