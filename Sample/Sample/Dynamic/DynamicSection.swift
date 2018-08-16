//
//  DynamicSection.swift
//  Sample
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class DynamicSection: DefaultMutableTabeViewKitSection<DynamicModel.Sections> {
	
	override init(identifier: DynamicModel.Sections, title: String? = nil, footer: String? = nil, delegate: TableViewKitSectionDelegate) {
		super.init(identifier: identifier,
							 title: title,
							 footer: footer,
							 delegate: delegate,
							 allRows: [
								"cantdelete": DynamicRow(title: "Can't delete this", delegate: self)
			],
							 preferredOrder: [
								"cantdelete"
			])
	}
	
	func appendRow() {
		append(row: DynamicMutableRow(delegate: self), withIdentifier: UUID().uuidString)
//		let id = UUID().uuidString
//		allRows[id] = DynamicMutableRow(delegate: self)
//		preferredRowOrder.append(id)
//
//		desiredState = actualState.showOrReload()
//		notifyIfStateChanged()
	}
	
//	func append(row: TableViewKitRow, withIdentifier: AnyHashable) {
//
//	}
//
//	func insert(row: TableViewKitRow, withIdentifier: AnyHashable, afterRowWithIdentifier: AnyHashable) {
//
//	}
//
//	func insert(row: TableViewKitRow, withIdentifier: AnyHashable, beforeRowWithIdentifier: AnyHashable) {
//
//	}
}
