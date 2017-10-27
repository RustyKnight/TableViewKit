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

extension Notification.Name {
	static let changeCellState = Notification.Name(rawValue: "ChangeCellState")
}

class StaticSection02: DefaultStaticTableViewKitSection<StaticModel.Sections> {
	
	init(identifier: StaticModel.Sections, delegate: TableViewKitSectionDelegate) {
		super.init(identifier: identifier,
		           title: "Section 02",
		           delegate: delegate,
		           allRows: [
								StaticModel.CellIdentifiers.section2Cell1: Section2StaticRow(cellIdentifier: .section2Cell1, delegate: self),
								StaticModel.CellIdentifiers.section2Cell2: Section2StaticRow(cellIdentifier: .section2Cell2, delegate: self),
								StaticModel.CellIdentifiers.section2Cell3: Section2StaticRow(cellIdentifier: .section2Cell3, delegate: self),
								StaticModel.CellIdentifiers.section2Cell4: Section2StaticRow(cellIdentifier: .section2Cell4, delegate: self),
								StaticModel.CellIdentifiers.section2Cell5: Section2StaticRow(cellIdentifier: .section2Cell5, delegate: self),
								StaticModel.CellIdentifiers.section2Cell6: SegueRow(cellIdentifier: .section2Cell6, delegate: self)],
		           preferredOrder: [
								StaticModel.CellIdentifiers.section2Cell1,
								StaticModel.CellIdentifiers.section2Cell2,
								StaticModel.CellIdentifiers.section2Cell3,
								StaticModel.CellIdentifiers.section2Cell4,
								StaticModel.CellIdentifiers.section2Cell5,
								StaticModel.CellIdentifiers.section2Cell6],
		           viewToModelMapping:[
								StaticModel.CellIdentifiers.section2Cell1,
								StaticModel.CellIdentifiers.section2Cell2,
								StaticModel.CellIdentifiers.section2Cell3,
								StaticModel.CellIdentifiers.section2Cell4,
								StaticModel.CellIdentifiers.section2Cell5,
								StaticModel.CellIdentifiers.section2Cell6])
	}
	
}

class Section2StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.CellIdentifiers> {
	
	override func configure(_ cell: UITableViewCell) {
		cell.detailTextLabel?.text = "Check"
	}
	
	override func didSelect() -> Bool {
		guard let index = delegate.rowIndex(for: self) else {
			return false
		}
		let userInfo: [AnyHashable: Any] = ["rowIndex":index]
		let notification = Notification(name: .changeCellState, object: nil, userInfo: userInfo)
		NotificationCenter.default.post(notification)
		return false
	}
	
}

class SegueRow: DefaultSeguableTableViewKitRow<StaticTableViewController.SegueIdenitifer, StaticModel.CellIdentifiers> {
	init(cellIdentifier: StaticModel.CellIdentifiers,
	     delegate: TableViewKitRowDelegate) {
		super.init(segueIdentifier: StaticTableViewController.SegueIdenitifer.hello,
		           cellIdentifier: cellIdentifier,
		           delegate: delegate)
	}
	
	override func shouldPerformSegue(withIdentifier: SegueIdentifiable, sender: Any?) -> Bool {
		print("shouldPerformSegue with \(withIdentifier)")
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue) {
		print("prepareForSeqgue")
	}
	
	override func unwound(from segue: UIStoryboardSegue) {
		print("unwoundForSeqgue")
	}
}
