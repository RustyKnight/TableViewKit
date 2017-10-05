//
//  AnyTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class AnyTableViewKitSection: TableViewKitSection, TableViewKitRowDelegate {
	
	public var title: String? = nil
	public var footer: String? = nil
	public var rowCount: Int = 0
	
	public var isHidden: Bool {
		return actualState == .hide
	}
	
	open var desiredState: State = .show
  public internal (set) var actualState: State = .show
	
	public var delegate: TableViewKitSectionDelegate
	
	internal var stateManager: StateManager<AnyTableViewKitRow>!
	
	public init<T: RawRepresentable>(title: T? = nil, footer: T? = nil, delegate: TableViewKitSectionDelegate) where T.RawValue == String {
		self.delegate = delegate
		self.title = title?.rawValue
		self.footer = footer?.rawValue
	}
	
	func prepareStateManagerWith(allRows: [AnyHashable: AnyTableViewKitRow], preferredOrder: [AnyHashable]) {
		stateManager = StateManager(allItems: allRows, preferredOrder: preferredOrder)
	}
	
	public func updateToDesiredState() {
		// What does it mean for a section to be hidden/shown?
		actualState = desiredState == .reload ? .show : desiredState
	}
	
	public func applyDesiredState() -> [Operation:[Int]] {
		//		return stateManager.applyDesiredState(basedOn: activeItems)
		fatalError("Not yet implemeted")
	}
	
	public func cell<Identifier>(withIdentifier identifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier : RawRepresentable, Identifier.RawValue == String {
		return delegate.cell(withIdentifier: identifier, at: indexPath)
	}
	
	open func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		fatalError("Not yet implemented")
	}
	
	open func willBecomeActive() {
		fatalError("Not yet implemented")
	}
	
	open func didBecomeInactive() {
		fatalError("Not yet implemented")
	}
	
	open func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?) {
		fatalError("Not yet implemented")
	}
	
	open func didSelectRow(at path: IndexPath) -> Bool {
		fatalError("Not yet implemented")
	}
	
	open func shouldSelectRow(at path: IndexPath) -> Bool {
		fatalError("Not yet implemented")
	}
	
	open func setContext(`for` key: AnyHashable, to value: Any?) {
		fatalError("Not yet implemented")
	}
	
	open func context(`for` key: AnyHashable) -> Any? {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRowWasUpdated(_ row: TableViewKitRow) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRowWasRemoved(_ row: TableViewKitRow) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(_ row: TableViewKitRow, didFailWith error: Error) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ row: TableViewKitRow,
		showAlertTitled title: String?,
		message: String?,
		preferredStyle: UIAlertControllerStyle,
		actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ row: TableViewKitRow,
		performSegueWithIdentifier identifier: String,
		controller: TableViewKitSegueController) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ row: TableViewKitRow,
		presentActionSheetWithTitle title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
	
	open func willDisplay(_ cell: UITableViewCell, forRowAt: Int) {
		fatalError("Not yet implemented")
	}
	
	open func didEndDisplaying(_ cell: UITableViewCell, forRowAt: Int) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ model: TableViewKitModel,
		showAlertAtRow: Int,
		titled title: String?,
		message: String?,
		preferredStyle: UIAlertControllerStyle,
		actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
}
