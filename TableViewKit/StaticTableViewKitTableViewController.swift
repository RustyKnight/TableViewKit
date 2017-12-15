//
//  StaticTableViewKitTableViewController.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 23/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

open class StaticTableViewKitTableViewController<Model: StaticTableViewKitModel>: TableViewKitTableViewController<Model> {
	
	// MARK: Index mapping
	
	open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let modelIndexPath = model.toModelIndexPath(fromViewIndexPath: indexPath)
		log(debug: "viewIndex = \(indexPath); modelIndex = \(modelIndexPath)")
		return super.tableView(tableView, heightForRowAt: modelIndexPath)
	}
	
	open override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		let modelIndexPath = model.toModelIndexPath(fromViewIndexPath: indexPath)
		log(debug: "viewIndex = \(indexPath); modelIndex = \(modelIndexPath)")
		return super.tableView(tableView, indentationLevelForRowAt: modelIndexPath)
	}

}
