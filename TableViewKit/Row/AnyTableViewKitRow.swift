//
//  AnyTableViewKitRow.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class AnyTableViewKitRow: NSObject, TableViewKitRow {
	
	open var isHidden: Bool {
		return actualState == .hide
	}
	
	open var desiredState: State = .show
	public private (set) var actualState: State = .show
	
	public var delegate: TableViewKitRowDelegate
	
	public init(delegate: TableViewKitRowDelegate) {
		self.delegate = delegate
	}
	
	public func updateToDesiredState() {
		actualState = actualState.newStateBasedOn(desiredState: desiredState)
	}
	
	open func didSelect() -> Bool {
    return false
	}
	
	open func shouldSelectRow() -> Bool {
		return true
	}
	
	open func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		fatalError("Not yet implemented")
	}
	
	open func willBecomeActive() {
	}
	
	open func didBecomeInactive() {
	}
	
	open func sharedContext(`for` key: AnyHashable, didChangeTo value: Any?) {
	}
  
  public func willDisplay(_ cell: UITableViewCell) {
  }
  
  public func didEndDisplaying(_ cell: UITableViewCell) {
  }

	
}
