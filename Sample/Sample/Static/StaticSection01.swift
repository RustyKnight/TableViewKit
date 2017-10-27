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
import LogWrapperKit

class StaticSection01: DefaultStaticTableViewKitSection<StaticModel.Sections> {
	
	init(identifier: StaticModel.Sections, delegate: TableViewKitSectionDelegate) {
		super.init(identifier: identifier,
		           title: "Section 02",
		           delegate: delegate,
		           allRows: [
								StaticModel.CellIdentifiers.section1Cell1: Section1StaticRow(cellIdentifier: .section1Cell1, delegate: self),
								StaticModel.CellIdentifiers.section1Cell2: Section1StaticRow(cellIdentifier: .section1Cell2, delegate: self),
								StaticModel.CellIdentifiers.section1Cell3: Section1StaticRow(cellIdentifier: .section1Cell3, delegate: self),
								StaticModel.CellIdentifiers.section1Cell4: Section1StaticRow(cellIdentifier: .section1Cell4, delegate: self),
								StaticModel.CellIdentifiers.section1Cell5: Section1StaticRow(cellIdentifier: .section1Cell5, delegate: self)],
		           preferredOrder: [
								StaticModel.CellIdentifiers.section1Cell1,
								StaticModel.CellIdentifiers.section1Cell2,
								StaticModel.CellIdentifiers.section1Cell3,
								StaticModel.CellIdentifiers.section1Cell4,
								StaticModel.CellIdentifiers.section1Cell5],
		           viewToModelMapping: [
								StaticModel.CellIdentifiers.section1Cell1,
								StaticModel.CellIdentifiers.section1Cell2,
								StaticModel.CellIdentifiers.section1Cell3,
								StaticModel.CellIdentifiers.section1Cell4,
								StaticModel.CellIdentifiers.section1Cell5])
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

class Section1StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.CellIdentifiers> {
	
	override func configure(_ cell: UITableViewCell) {
		cell.detailTextLabel?.text = "Check"
	}
	
	override func didEndDisplaying(_ cell: UITableViewCell) {
		log(debug: "\(cellIdentifier)")
	}

}
