//
//  DynamicSection.swift
//  Sample
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class DynamicRow: DefaultIdentifiableTableViewKitRow<DynamicModel.CellIdentifier> {
	
	let title: String
	
	public init(title: String, cellIdentifier: DynamicModel.CellIdentifier = .basic, delegate: TableViewKitRowDelegate) {
		self.title = title
		super.init(cellIdentifier: cellIdentifier, delegate: delegate)
	}
	
	override func configure(_ cell: UITableViewCell) {
		cell.textLabel?.text = title
	}
	
}

class DynamicMutableRow: DynamicRow, MutableTableViewKitRow {
	
	var isDeletable: Bool = true

	public override init(title: String = UUID().uuidString, cellIdentifier: DynamicModel.CellIdentifier = .basic, delegate: TableViewKitRowDelegate) {
		super.init(title: title, cellIdentifier: cellIdentifier, delegate: delegate)
	}

	func delete() {
		desiredState = .delete
		updateIfChanged()
	}
}
