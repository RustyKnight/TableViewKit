//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public enum TableViewRowDelegateError: Error {
	case noSectionDelegateAvailable
}

public protocol TableViewSegueController {
	func shouldPerformSegue(withIdentifier: String) -> Bool
	func prepare(for segue: UIStoryboardSegue)
	func unwound(from segue: UIStoryboardSegue)
}

public protocol TableViewRowDelegate {

	func rowWasUpdated(_ row: TableViewRow)
	func rowWasRemoved(_ row: TableViewRow)

//	func remove(row: TableViewRow)

	func row(_ row: TableViewRow, didFailWith error: Error)

	func performSegue(withIdentifier: String, controller: TableViewSegueController)

	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?

	func presentActionSheet(`for`: TableViewRow, title: String?, message: String?, actions: [UIAlertAction])

}

public protocol TableViewSectionRowContext {
	var tableViewRowDelegate: TableViewRowDelegate {get}
//	var tableViewController: UITableViewController {get}
	var indexPath: IndexPath {get}
}

public struct DefaultTableViewSectionRowContext: TableViewSectionRowContext {
	public let tableViewRowDelegate: TableViewRowDelegate
//	let tableViewController: UITableViewController
	public let indexPath: IndexPath
}

public protocol TableViewRow: Hidable {
	var delegate: TableViewRowDelegate? {get}

	func didSelect(withContext context: TableViewSectionRowContext)

	func cellFor(tableView: UITableView, at: IndexPath) -> UITableViewCell
	func willBecomeActive(_ delegate: TableViewRowDelegate)
	func didBecomeInactive(_ delegate: TableViewRowDelegate)

	func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?)
}

public func ==(lhs: TableViewRow, rhs: TableViewRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}

public func ==(lhs: AnyTableViewRow, rhs: AnyTableViewRow) -> Bool {
	let lhsAddress = Unmanaged.passUnretained(lhs as AnyObject).toOpaque()
	let rhsAddress = Unmanaged.passUnretained(rhs as AnyObject).toOpaque()
	return lhsAddress == rhsAddress
}


public class AnyTableViewRow: NSObject, TableViewRow {

	public var delegate: TableViewRowDelegate?

	public func didSelect(withContext context: TableViewSectionRowContext) {
	}

	public func cellFor(tableView: UITableView, at: IndexPath) -> UITableViewCell {
		fatalError("Not yet implemented")
	}

	public func willBecomeActive(_ delegate: TableViewRowDelegate) {
	}

	public func didBecomeInactive(_ delegate: TableViewRowDelegate) {
	}

	public var isHidden: Bool = false

	public func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?) {
	}

}

public class DefaultReusableTableViewRow<T: RawRepresentable>: AnyTableViewRow where T.RawValue == String {

	let cellIdentifier: T

	init(cellIdentifier: T, delegate: TableViewRowDelegate? = nil) {
		self.cellIdentifier = cellIdentifier
		super.init()
		self.delegate = delegate
	}

	public override func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue, for: indexPath)
		configure(cell)
		return cell
	}

	func configure(_ cell: UITableViewCell) {
		fatalError("Not yet implemented")
	}

}

public class DefaultSeguableTableViewRow<SegueIdentifier: RawRepresentable, CellIdentifier: RawRepresentable>: DefaultReusableTableViewRow<CellIdentifier>,
		Seguable,
		TableViewSegueController where SegueIdentifier.RawValue == String, CellIdentifier.RawValue == String {

	public let segueIdentifier: String

	init(segueIdentifier: SegueIdentifier,
	     cellIdentifier: CellIdentifier,
	     delegate: TableViewRowDelegate? = nil) {
		// I'd call self.init, but I want this initialise to be callable by child implementations,
		// it's kind of the point of providing the generic support
		self.segueIdentifier = segueIdentifier.rawValue
		super.init(cellIdentifier: cellIdentifier, delegate: delegate)
	}

	override func configure(_ cell: UITableViewCell) {
		cell.accessoryType = .disclosureIndicator
	}

	public override func didSelect(withContext context: TableViewSectionRowContext) {
		let delegate = context.tableViewRowDelegate
		delegate.performSegue(withIdentifier: segueIdentifier, controller: self)
	}

	public func shouldPerformSegue(withIdentifier: String) -> Bool {
		return true
	}

	public func prepare(for segue: UIStoryboardSegue) {
	}

	public func unwound(from segue: UIStoryboardSegue) {
	}
}


