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
								StaticModel.Sections.Section2.cell1: Section2StaticRow(cellIdentifier: .cell1, delegate: self),
								StaticModel.Sections.Section2.cell2: Section2StaticRow(cellIdentifier: .cell2, delegate: self),
								StaticModel.Sections.Section2.cell3: Section2StaticRow(cellIdentifier: .cell3, delegate: self),
								StaticModel.Sections.Section2.cell4: Section2StaticRow(cellIdentifier: .cell4, delegate: self),
								StaticModel.Sections.Section2.cell5: Section2StaticRow(cellIdentifier: .cell5, delegate: self),
								StaticModel.Sections.Section2.cell6: SegueRow(cellIdentifier: .cell6, delegate: self)],
		           preferredOrder: [
								StaticModel.Sections.Section2.cell1,
								StaticModel.Sections.Section2.cell2,
								StaticModel.Sections.Section2.cell3,
								StaticModel.Sections.Section2.cell4,
								StaticModel.Sections.Section2.cell5,
								StaticModel.Sections.Section2.cell6],
		           viewToModelMapping:[
								StaticModel.Sections.Section2.cell1,
								StaticModel.Sections.Section2.cell2,
								StaticModel.Sections.Section2.cell3,
								StaticModel.Sections.Section2.cell4,
								StaticModel.Sections.Section2.cell5,
								StaticModel.Sections.Section2.cell6])
	}
	
}

class Section2StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.Sections.Section2> {
	
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

class SegueRow: DefaultSeguableTableViewKitRow<StaticTableViewController.SegueIdenitifer, StaticModel.Sections.Section2> {
	init(cellIdentifier: StaticModel.Sections.Section2,
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
