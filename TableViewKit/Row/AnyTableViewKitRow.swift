//
//  AnyTableViewKitRow.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

public typealias CellIdentifiable = Identifiable

open class AnyTableViewKitRow: NSObject, TableViewKitRow {
	
	open var isHidden: Bool {
		return actualState == .hide
	}
	
  open var desiredState: State = .show {
    didSet {
      desiredStateDidChange()
    }
  }
  public private (set) var actualState: State = .undefined {
    didSet {
      actualStateDidChange()
    }
  }
	
	public var delegate: TableViewKitRowDelegate
	
	public init(delegate: TableViewKitRowDelegate) {
		self.delegate = delegate
	}
  
  open func desiredStateDidChange() {
  }

  open func actualStateDidChange() {
  }

	open func updateToDesiredState() {
		let previous = actualState
		let desired = desiredState
		let newState = previous.newStateBasedOn(desiredState: desired)
		////log(debug: "desiredState = \(desiredState); actualState = \(actualState); newState = \(newState)")
		actualState = newState
		guard previous != newState else {
			return
		}
		switch newState {
		case .show: rowWillShow()
		case .hide: rowWillHide()
		default: break
		}
	}
	
	open func rowWillHide() {
	}
	
	open func rowWillShow() {
	}

	open func didSelect() -> Bool {
    return false
	}

//	open func cellSelection(didChangeTo path: IndexPath) {
//	}

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
  
  open func willDisplay(_ cell: UITableViewCell) {
  }
  
  open func didEndDisplaying(_ cell: UITableViewCell) {
  }

	open func updateIfChanged() {
		guard desiredState != actualState else {
			return
		}
		delegate.stateDidChange(for: self)
	}
	
}
