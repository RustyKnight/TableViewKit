//
//  DynamicModel.swift
//  Sample
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit
import LogWrapperKit

class DynamicModel: DefaultMutableTableViewKitModel {
	
	enum Sections: String, SectionIdentifiable {
		case section1 = "section1"
		var value: String { return self.rawValue }
	}
	
	enum CellIdentifier: String, CellIdentifiable {
		case basic = "basic"
		var value: String { return self.rawValue }
	}
	
	override init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate,
							 allSections: [
								Sections.section1: DynamicSection(identifier: Sections.section1, delegate: self)],
							 preferredOrder: [
								Sections.section1])
	}
	
	func addRow() {
		guard let section = self.section(withIdentifier: Sections.section1) as? DynamicSection else {
			log(error: "Section [\(Sections.section1)] is not mutable")
			return
		}
		section.appendRow()
	}
	
}
