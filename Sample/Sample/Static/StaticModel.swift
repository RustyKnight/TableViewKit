//
//  StaticModel.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

enum StaticSectionIdentifier: String {
	case section1 = "section1"
}

class StaticModel: DefaultTableViewKitModel<StaticSectionIdentifier> {
	
	enum CellIdentifiers: String {
		case section1Cell1 = "S1C1"
		case section1Cell2 = "S1C2"
		case section1Cell3 = "S1C3"
		case section1Cell4 = "S1C4"
		case section1Cell5 = "S1C5"
	}
	
	override init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate)
		
		allSections = [
			.section1: StaticSection(delegate: self)
		]
		
		preferredSectionOrder = [
			.section1
		]
	}
	
}
