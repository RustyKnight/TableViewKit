//
//  StaticSection.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import UIKit
import TableViewKit

class StaticSection01: DefaultTableViewKitSection<StaticModel.Sections> {
	
	init(identifier: StaticModel.Sections, delegate: TableViewKitSectionDelegate) {
		super.init(identifier: identifier, title: "Section 02", delegate: delegate)
	}

	override func commonInit() {
		super.commonInit()
		
		allRows = [
			StaticModel.Sections.Section1.cell1: Section1StaticRow(cellIdentifier: .cell1, delegate: self),
			StaticModel.Sections.Section1.cell2: Section1StaticRow(cellIdentifier: .cell2, delegate: self),
			StaticModel.Sections.Section1.cell3: Section1StaticRow(cellIdentifier: .cell3, delegate: self),
			StaticModel.Sections.Section1.cell4: Section1StaticRow(cellIdentifier: .cell4, delegate: self),
			StaticModel.Sections.Section1.cell5: Section1StaticRow(cellIdentifier: .cell5, delegate: self)
		]
		
		preferredRowOrder = [
			StaticModel.Sections.Section1.cell1,
			StaticModel.Sections.Section1.cell2,
			StaticModel.Sections.Section1.cell3,
			StaticModel.Sections.Section1.cell4,
			StaticModel.Sections.Section1.cell5
		]
	}
	
	override func willBecomeActive() {
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(changeCellState),
		                                       name: .changeCellState,
		                                       object: nil)
	}
	
	override func didBecomeInactive() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc
	func changeCellState(_ notification: Notification!) {
		guard let userInfo = notification.userInfo else {
			return
		}
		guard let rowIndex = userInfo["rowIndex"] as? Int else {
			return
		}
		
		guard let cell = allRows[preferredRowOrder[rowIndex]] else {
			return
		}
		switch cell.desiredState {
		case .hide:
			cell.desiredState = .show
			delegate.stateDidChange(for: self)
		case .show:
			cell.desiredState = .hide
			delegate.stateDidChange(for: self)
		default: break;
		}
	}
	
}

class Section1StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.Sections.Section1> {
	
	override func configure(_ cell: UITableViewCell) {
		cell.detailTextLabel?.text = "Check"
	}

}
