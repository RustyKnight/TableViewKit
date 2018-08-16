//
//  DynamicTableViewController.swift
//  Sample
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import TableViewKit

class DynamicTableViewController: TableViewKitTableViewController<DynamicModel> {
	
	@IBOutlet var addItemButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		model = DynamicModel(delegate: self)
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = addItemButton
	}
	
	override func performUpdate() {
		applyDesiredState()
	}
	
	override func cell(withIdentifier: CellIdentifiable) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: withIdentifier.value)!
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return model.can(deleteRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else {
			return
		}
		guard model.can(deleteRowAt: indexPath) else {
			return
		}
		
		model.delete(rowAt: indexPath)
	}
	
	@IBAction func addItemTapped(_ sender: Any) {
		model.addRow()
	}
}
