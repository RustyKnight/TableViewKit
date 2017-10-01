//
//  StaticSection.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class StaticSection: DefaultTableViewKitSection<StaticModel.CellIdentifiers> {
	
	override func commonInit() {
		super.commonInit()
		
		allRows = [
			.section1Cell1: StaticRow(cellIdentifier: .section1Cell1, delegate: self),
			.section1Cell2: StaticRow(cellIdentifier: .section1Cell2, delegate: self),
			.section1Cell3: StaticRow(cellIdentifier: .section1Cell3, delegate: self),
			.section1Cell4: StaticRow(cellIdentifier: .section1Cell4, delegate: self),
			.section1Cell5: StaticRow(cellIdentifier: .section1Cell5, delegate: self)
		]
		
		preferredRowOrder = [
			.section1Cell1,
			.section1Cell2,
			.section1Cell3,
			.section1Cell4,
			.section1Cell5
		]
	}
	
}

class StaticRow: DefaultIdentifiableTableViewKitRow<StaticModel.CellIdentifiers> {
	
}
