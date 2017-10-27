//
//  StaticModel.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class StaticModel: DefaultStaticTableViewKitModel {

	enum Sections: String, SectionIdentifiable {
		case section1 = "section1"
		case section2 = "section2"

		var value: String { return self.rawValue }
	}
	
	enum CellIdentifiers: String, CellIdentifiable, CustomStringConvertible {
		case section1Cell1 = "1001"
		case section1Cell2 = "1002"
		case section1Cell3 = "1003"
		case section1Cell4 = "1004"
		case section1Cell5 = "1005"

		case section2Cell1 = "2001"
		case section2Cell2 = "2002"
		case section2Cell3 = "2003"
		case section2Cell4 = "2004"
		case section2Cell5 = "2005"
		case section2Cell6 = "2006"

		var description: String { return self.rawValue }
		
		var value: String { return self.rawValue }
	}
	
	init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate,
		           allSections: [
								Sections.section1: StaticSection01(identifier: Sections.section1, delegate: self),
								Sections.section2: StaticSection02(identifier: Sections.section2, delegate: self)],
		           preferredOrder: [
								Sections.section1,
								Sections.section2],
		           viewToModelMapping: [
								Sections.section1,
								Sections.section2])
	}
	
}
