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

class StaticSection02: DefaultTableViewKitSection {
	
	override init<T: RawRepresentable>(title: T? = nil, footer: T? = nil, delegate: TableViewKitSectionDelegate) where T.RawValue == String {
		super.init(title: title, footer: footer, delegate: delegate)
	}
	
	override func commonInit() {
		super.commonInit()
		
		allRows = [
			StaticModel.Section2.cell1: Section2StaticRow(cellIdentifier: .cell1, delegate: self),
			StaticModel.Section2.cell2: Section2StaticRow(cellIdentifier: .cell2, delegate: self),
			StaticModel.Section2.cell3: Section2StaticRow(cellIdentifier: .cell3, delegate: self),
			StaticModel.Section2.cell4: Section2StaticRow(cellIdentifier: .cell4, delegate: self),
			StaticModel.Section2.cell5: Section2StaticRow(cellIdentifier: .cell5, delegate: self)
		]
		
		preferredRowOrder = [
			StaticModel.Section2.cell1,
			StaticModel.Section2.cell2,
			StaticModel.Section2.cell3,
			StaticModel.Section2.cell4,
			StaticModel.Section2.cell5
		]
	}
	
}

class Section2StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.Section2> {
	
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
