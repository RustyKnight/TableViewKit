//
//  AnyTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

public typealias SectionIdentifiable = Identifiable

open class AnyTableViewKitSection: TableViewKitSection, TableViewKitRowDelegate {
	
	public var rowCount: Int = 0
	
	open var title: String?
	open var footer: String?

	public var isHidden: Bool {
		return actualState == .hide
	}
	
	public var isHiddenWhenEmpty: Bool = true
	
	var preferredDesiredState: State = .show
	open var desiredState: State {
		set {
			preferredDesiredState = newValue
		}
		
		get {
			guard isHiddenWhenEmpty else {
				return preferredDesiredState
			}
			return rowCount == 0 ? .hide : preferredDesiredState
		}
	}
  public internal (set) var actualState: State = .show
	
	public var delegate: TableViewKitSectionDelegate
	
	internal var stateManager: StateManager<AnyTableViewKitRow>!
	
	public let identifier: SectionIdentifiable

	public var activeGroup: AnyGroupManager<TableViewKitRow> = AnyGroupManager<TableViewKitRow>()
	public var configuredGroup: AnyGroupManager<TableViewKitRow> = AnyGroupManager<TableViewKitRow>()

	public init(identifier: SectionIdentifiable, title: String? = nil, footer: String?, delegate: TableViewKitSectionDelegate) {
		self.identifier = identifier
		self.title = title
		self.footer = footer
		self.delegate = delegate
	}

	public func rowIndex(for: TableViewKitRow) -> Int? {
		fatalError("Not yet implemented")
	}
	
	func prepareStateManagerWith(allRows: [AnyHashable: AnyTableViewKitRow], preferredOrder: [AnyHashable]) {
		stateManager = StateManager(allItems: allRows, preferredOrder: preferredOrder)
	}
	
	public func updateToDesiredState() {
		actualState = actualState.newStateBasedOn(desiredState: desiredState)
	}
	
	public func applyInsertStates() -> [Operation : [Int]] {
		fatalError("Not yet implemeted")
	}
	
	public func applyModificationStates() -> [Operation : [Int]] {
		fatalError("Not yet implemeted")
	}
	
//	public func applyDesiredState() -> [Operation:[Int]] {
//		//		return stateManager.applyDesiredState(basedOn: activeItems)
//		fatalError("Not yet implemeted")
//	}
//	
//	public func cell(withIdentifier identifier: CellIdentifiable, at indexPath: IndexPath) -> UITableViewCell {
//		return delegate.cell(withIdentifier: identifier, at: indexPath)
//	}

	public func cell(withIdentifier identifier: CellIdentifiable) -> UITableViewCell {
		return delegate.cell(withIdentifier: identifier)
	}

	open func notifyIfStateChanged() {
		guard desiredState != actualState else {
			return
		}
		delegate.stateDidChange(for: self)
	}

	open func row(at: Int) -> TableViewKitRow {
		fatalError("Not yet implemented")
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

//	open func cellSelection(didChangeTo path: IndexPath) {
//		fatalError("Not yet implemented")
//	}

	open func shouldSelectRow(at path: IndexPath) -> Bool {
		fatalError("Not yet implemented")
	}
	
	open func setContext(`for` key: AnyHashable, to value: Any?) {
		fatalError("Not yet implemented")
	}
	
	open func context(`for` key: AnyHashable) -> Any? {
		fatalError("Not yet implemented")
	}
	
	open func stateDidChange(for row: TableViewKitRow) {
		fatalError("Not yet implemented")
	}

	open func tableViewRow(_ row: TableViewKitRow, didFailWith error: Error) {
		fatalError("Not yet implemented")
	}
	
	open func perform(_ row: TableViewKitRow, action: Any, value: Any?) {
		fatalError("Not yet implemented")
//		delegate.perform(action: action, value: value)
	}

	open func tableViewRow(
		_ row: TableViewKitRow,
		showAlertTitled title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ row: TableViewKitRow,
		performSegueWithIdentifier identifier: SegueIdentifiable,
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
	
	open func didEndDisplaying(cell: UITableViewCell, withIdentifier identifier: CellIdentifiable, at indexPath: IndexPath) {
		fatalError("Not yet implemented")
	}
	
	open func tableViewRow(
		_ model: TableViewKitModel,
		showAlertAtRow: Int,
		titled title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		fatalError("Not yet implemented")
	}
}
