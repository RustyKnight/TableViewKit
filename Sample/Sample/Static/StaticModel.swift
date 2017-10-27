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
		
		enum Section1: String, CellIdentifiable, CustomStringConvertible {
			case cell1 = "1001"
			case cell2 = "1002"
			case cell3 = "1003"
			case cell4 = "1004"
			case cell5 = "1005"
			
			var description: String { return self.rawValue }
			
			var value: String { return self.rawValue }
		}
		
		enum Section2: String, CellIdentifiable, CustomStringConvertible {
			case cell1 = "2001"
			case cell2 = "2002"
			case cell3 = "2003"
			case cell4 = "2004"
			case cell5 = "2005"
			case cell6 = "2006"
			
			var description: String { return self.rawValue }
			
			var value: String { return self.rawValue }
		}
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
