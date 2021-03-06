//
//  DefaultSeguableTableViewKitRow.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

public typealias SegueIdentifiable = Identifiable

open class DefaultSeguableTableViewKitRow<SegueIdentifier:SegueIdentifiable, CellIdentifier: CellIdentifiable>: DefaultIdentifiableTableViewKitRow<CellIdentifier>, TableViewKitSegueController {
	
//	open private(set) var segueIdentifier: SegueIdentifier
	open var segueIdentifier: SegueIdentifier

	public init(segueIdentifier: SegueIdentifier,
	            cellIdentifier: CellIdentifier,
	            delegate: TableViewKitRowDelegate) {
		// I'd call self.init, but I want this initialise to be callable by child implementations,
		// it's kind of the point of providing the generic support
		self.segueIdentifier = segueIdentifier
		super.init(cellIdentifier: cellIdentifier, delegate: delegate)
	}
	
	override open func configure(_ cell: UITableViewCell) {
		cell.accessoryType = .disclosureIndicator
	}
	
	override open func didSelect() -> Bool {
//		let identifier = segueIdentifier
		////log(debug: "identifier = \(identifier)")
		delegate.tableViewRow(self, performSegueWithIdentifier: segueIdentifier, controller: self)
    return false
	}
	
	open func shouldPerformSegue(withIdentifier: SegueIdentifiable, sender: Any?) -> Bool {
		return true
	}

	open func segueRejectedReason(forIdentifier: SegueIdentifiable, sender: Any?) -> String? {
		return nil
	}

	open func prepare(for segue: UIStoryboardSegue) {
	}
	
	open func unwound(from segue: UIStoryboardSegue) {
	}
	
}
