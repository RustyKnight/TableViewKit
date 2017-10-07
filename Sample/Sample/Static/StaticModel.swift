//
//  StaticModel.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class StaticModel: DefaultTableViewKitModel {

	enum StaticSectionIdentifier: String {
		case section1 = "section1"
		case section2 = "section2"
	}
	
	enum Section1: String, CustomStringConvertible {
		case cell1 = "1001"
		case cell2 = "1002"
		case cell3 = "1003"
		case cell4 = "1004"
		case cell5 = "1005"
		
		var description: String { return self.rawValue }
	}

	enum Section2: String, CustomStringConvertible {
		case cell1 = "2001"
		case cell2 = "2002"
		case cell3 = "2003"
		case cell4 = "2004"
		case cell5 = "2005"
		
		var description: String { return self.rawValue }
	}

//	enum CellIdentifiers: String {
//		case section1Cell1 = "1001"
//		case section1Cell2 = "1002"
//		case section1Cell3 = "1003"
//		case section1Cell4 = "1004"
//		case section1Cell5 = "1005"
//
//		case section2Cell1 = "2001"
//		case section2Cell2 = "2002"
//		case section2Cell3 = "2003"
//		case section2Cell4 = "2004"
//		case section2Cell5 = "2005"
//
//		var intValue: Int {
//			return Int(rawValue)!
//		}
//	}
	
	override init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate)
		
		allSections = [
			StaticSectionIdentifier.section1: StaticSection01(title: StaticSectionIdentifier.section1, delegate: self),
			StaticSectionIdentifier.section2: StaticSection02(title: StaticSectionIdentifier.section2, delegate: self)
		]
		
		preferredSectionOrder = [
			StaticSectionIdentifier.section1,
			StaticSectionIdentifier.section2
		]
	}
	
}
