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

class StaticSection: DefaultTableViewKitSection {
	
	override init<T: RawRepresentable>(title: T? = nil, footer: T? = nil, delegate: TableViewKitSectionDelegate) where T.RawValue == String {
		super.init(title: title, footer: footer, delegate: delegate)
	}

	override func commonInit() {
		super.commonInit()
		
		allRows = [
			StaticModel.CellIdentifiers.section1Cell1: StaticRow(cellIdentifier: .section1Cell1, delegate: self),
			StaticModel.CellIdentifiers.section1Cell2: StaticRow(cellIdentifier: .section1Cell2, delegate: self),
			StaticModel.CellIdentifiers.section1Cell3: StaticRow(cellIdentifier: .section1Cell3, delegate: self),
			StaticModel.CellIdentifiers.section1Cell4: StaticRow(cellIdentifier: .section1Cell4, delegate: self),
			StaticModel.CellIdentifiers.section1Cell5: StaticRow(cellIdentifier: .section1Cell5, delegate: self)
		]
		
		preferredRowOrder = [
			StaticModel.CellIdentifiers.section1Cell1,
			StaticModel.CellIdentifiers.section1Cell2,
			StaticModel.CellIdentifiers.section1Cell3,
			StaticModel.CellIdentifiers.section1Cell4,
			StaticModel.CellIdentifiers.section1Cell5
		]
	}
	
}

class StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.CellIdentifiers> {
	
	override func configure(_ cell: UITableViewCell) {
		cell.detailTextLabel?.text = "Check"
	}

}
