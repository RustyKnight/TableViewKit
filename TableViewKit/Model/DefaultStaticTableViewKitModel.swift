//
//  DefaultStaticTableViewKitModel.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 23/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultStaticTableViewKitModel: DefaultTableViewKitModel, StaticTableViewKitModel {

	// This is used to map the active section index to the
	// position of the section in the story board
	internal var viewToModelMapping: [AnyHashable] = []
	
	public init(delegate: TableViewKitModelDelegate,
							allSections: [AnyHashable: AnyTableViewKitSection],
							preferredOrder: [AnyHashable],
							viewToModelMapping: [AnyHashable]) {
		self.viewToModelMapping = viewToModelMapping
		super.init(delegate: delegate, allSections: allSections, preferredOrder: preferredOrder)
	}

	override public init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate)
	}
	
	public func set(sections: [AnyHashable : AnyTableViewKitSection], preferredOrder: [AnyHashable], viewToModelMapping: [AnyHashable]) {
		self.viewToModelMapping = viewToModelMapping
		super.set(sections: sections, preferredOrder: preferredOrder)
	}

	open func toModelIndexPath(fromViewIndexPath path: IndexPath) -> IndexPath {
		let id = identifierForActiveSection(at: path.section)
		guard let section = allSections[id] as? StaticTableViewKitSection else {
			fatalError("Section [\(id)] not exist or is not a instance of StaticTableViewKitSection")
		}
		guard let sectionIndex = viewToModelMapping.index(of: id) else {
			fatalError("Section [\(id)] does not have a matching index")
		}
		let rowIndex = section.toModelIndex(fromViewIndex: path.row)
		let modelPath = IndexPath(row: rowIndex, section: sectionIndex)
		return modelPath
	}

}
