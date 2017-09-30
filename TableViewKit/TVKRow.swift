//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public enum TableViewRowDelegateError: Error {
	case noSectionDelegateAvailable
}

public protocol TVKSegueController {
	func shouldPerformSegue(withIdentifier: String, sender: Any?) -> Bool
	func prepare(for segue: UIStoryboardSegue)
	func unwound(from segue: UIStoryboardSegue)
}

public protocol TVKRowDelegate {

	func tableViewRowWasUpdated(_ row: TVKRow)
	func tableViewRowWasRemoved(_ row: TVKRow)

//	func remove(row: TableViewRow)

	func tableViewRow(_ row: TVKRow, didFailWith error: Error)
	func tableViewRow(
			_ row: TVKRow,
			showAlertTitled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewRow(_ row: TVKRow, performSegueWithIdentifier identifier: String, controller: TVKSegueController)

	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?

	func tableViewRow(
			_ row: TVKRow,
			presentActionSheetWithTitle title: String?,
			message: String?,
			actions: [UIAlertAction])

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
	func cell(withIdentifier: String, at indexPath: IndexPath) -> UITableViewCell
}

public protocol TVKSectionRowContext {
	var tableViewRowDelegate: TVKRowDelegate { get }
	var tableViewController: UITableViewController { get }
	var indexPath: IndexPath { get }
}

public struct TVKDefaultSectionRowContext: TVKSectionRowContext {
	public let tableViewRowDelegate: TVKRowDelegate
	public let tableViewController: UITableViewController
	public let indexPath: IndexPath
}

public protocol TVKRow: Hidable {
	var delegate: TVKRowDelegate { get }

	func didSelect(withContext context: TVKSectionRowContext)
	func shouldSelectRow() -> Bool

	func cell(forRowAt indexPath: IndexPath) -> UITableViewCell
	func willBecomeActive(_ delegate: TVKRowDelegate)
	func didBecomeInactive(_ delegate: TVKRowDelegate)

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)
}

public func ==(lhs: TVKRow, rhs: TVKRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public func ==(lhs: TVKAnyRow, rhs: TVKAnyRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

open class TVKAnyRow: NSObject, TVKRow {

	public var delegate: TVKRowDelegate
	
	public init(delegate: TVKRowDelegate) {
		self.delegate = delegate
	}

	open func didSelect(withContext context: TVKSectionRowContext) {
	}

	open func shouldSelectRow() -> Bool {
		return true
	}

	open func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		fatalError("Not yet implemented")
	}

	open func willBecomeActive(_ delegate: TVKRowDelegate) {
	}

	open func didBecomeInactive(_ delegate: TVKRowDelegate) {
	}

	open var isHidden: Bool = false

	open func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?) {
	}

}

open class TVKDefaultReusableRow<T:RawRepresentable>: TVKAnyRow where T.RawValue == String {

	public let cellIdentifier: T

	public init(cellIdentifier: T, delegate: TVKRowDelegate) {
		self.cellIdentifier = cellIdentifier
		super.init(delegate: delegate)
	}

	open override func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = delegate.cell(withIdentifier: cellIdentifier.rawValue, at: indexPath)
		configure(cell)
		return cell
	}

	open func configure(_ cell: UITableViewCell) {
		fatalError("Not yet implemented")
	}

}

open class TVKDefaultSeguableRow<SegueIdentifier:RawRepresentable, CellIdentifier:RawRepresentable>: TVKDefaultReusableRow<CellIdentifier>,
		Seguable,
		TVKSegueController where SegueIdentifier.RawValue == String, CellIdentifier.RawValue == String {

	public let segueIdentifier: String

	public init(segueIdentifier: SegueIdentifier,
	          cellIdentifier: CellIdentifier,
	          delegate: TVKRowDelegate) {
		// I'd call self.init, but I want this initialise to be callable by child implementations,
		// it's kind of the point of providing the generic support
		self.segueIdentifier = segueIdentifier.rawValue
		super.init(cellIdentifier: cellIdentifier, delegate: delegate)
	}

	override open func configure(_ cell: UITableViewCell) {
		cell.accessoryType = .disclosureIndicator
	}

	override open func didSelect(withContext context: TVKSectionRowContext) {
		let delegate = context.tableViewRowDelegate
		delegate.tableViewRow(self, performSegueWithIdentifier: segueIdentifier, controller: self)
	}

	open func shouldPerformSegue(withIdentifier: String, sender: Any?) -> Bool {
		return true
	}

	open func prepare(for segue: UIStoryboardSegue) {
	}

	open func unwound(from segue: UIStoryboardSegue) {
	}

}
