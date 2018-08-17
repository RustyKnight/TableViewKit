//
//  FlippedTableViewKitTableViewController.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 17/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

open class InvertedTableViewKitTableViewController<Model: TableViewKitModel>: TableViewKitTableViewController<Model> {
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
	}

	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
		return cell
	}


	open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		guard let view = super.tableView(tableView, viewForFooterInSection: section) else {
			return nil
		}
		view.transform = CGAffineTransform(scaleX: 1, y: -1)
		return view
	}

	open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let view = super.tableView(tableView, viewForHeaderInSection: section) else {
			return nil
		}
		view.transform = CGAffineTransform(scaleX: 1, y: -1)
		return view
	}

}
