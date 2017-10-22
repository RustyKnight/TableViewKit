//
//  DefaultStaticTableViewKitSection.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 23/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultStaticTableViewKitSection<Identifier: SectionIdentifiable>: DefaultTableViewKitSection<Identifier> {

	internal var viewToModelMapping: [AnyHashable] = []
	
	public init(identifier: Identifier,
							title: String? = nil,
							footer: String? = nil,
							delegate: TableViewKitSectionDelegate,
							allRows: [AnyHashable: AnyTableViewKitRow],
							preferredOrder: [AnyHashable],
							viewToModelMapping: [AnyHashable]) {
		self.viewToModelMapping = viewToModelMapping
		super.init(identifier: identifier, title: title, footer: footer, delegate: delegate, allRows: allRows, preferredOrder: preferredOrder)
	}
	
	//  public func prepare(allRows: [AnyHashable: AnyTableViewKitRow],
	//                      preferredOrder: [AnyHashable],
	//                      viewToModelMapping: [AnyHashable]) {
	//    self.allRows = allRows
	//    self.preferredRowOrder = preferredOrder
	//    self.viewToModelMapping = viewToModelMapping
	//  }
	
	public func toModelIndex(fromViewIndex index: Int) -> Int {
		let id = identifierForActiveRow(at: index)
		guard let rowIndex = viewToModelMapping.index(of: id) else {
			fatalError("Row [\(id)] does not have a matching index")
		}
		return rowIndex
	}

}
