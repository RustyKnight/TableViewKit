//
//  MutableTableViewKitModel.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

public protocol MutableTableViewKitModel: TableViewKitModel {
	func can(deleteRowAt: IndexPath) -> Bool
	func delete(rowAt: IndexPath)
}

open class DefaultMutableTableViewKitModel: DefaultTableViewKitModel, MutableTableViewKitModel {
	
	override public init(delegate: TableViewKitModelDelegate) {
		super.init(delegate: delegate)
	}
	
	override public init(delegate: TableViewKitModelDelegate,
											 allSections: [AnyHashable: AnyTableViewKitSection], preferredOrder: [AnyHashable]) {
		super.init(delegate: delegate, allSections: allSections, preferredOrder: preferredOrder)
	}
	
	open func can(deleteRowAt path: IndexPath) -> Bool {
		guard let section = self.section(at: path.section) as? MutableTabeViewKitSection else {
			return false
		}
		return section.can(deleteRowAt: path.row)
	}
	
	open func delete(rowAt path: IndexPath) {
		guard let section = self.section(at: path.section) as? MutableTabeViewKitSection else {
			return
		}
		return section.delete(rowAt: path.row)
	}
}
