//
//  StaticTableViewController.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import UIKit
import TableViewKit

class StaticTableViewController: TableViewKitTableViewController {
	
	@IBOutlet weak var section1Cell1: UITableViewCell!
	@IBOutlet weak var section1Cell2: UITableViewCell!
	@IBOutlet weak var section1Cell3: UITableViewCell!
	@IBOutlet weak var section1Cell4: UITableViewCell!
	@IBOutlet weak var section1Cell5: UITableViewCell!
	
	var cells: [StaticModel.CellIdentifiers: UITableViewCell]!

	override func viewDidLoad() {
		
		cells = [
			StaticModel.CellIdentifiers.section1Cell1: section1Cell1,
			StaticModel.CellIdentifiers.section1Cell2: section1Cell2,
			StaticModel.CellIdentifiers.section1Cell3: section1Cell3,
			StaticModel.CellIdentifiers.section1Cell4: section1Cell4,
			StaticModel.CellIdentifiers.section1Cell5: section1Cell5
		]
		
		super.viewDidLoad()
	}

	override func cell<Identifier>(withIdentifier identifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier : RawRepresentable, Identifier.RawValue == String {
		guard let id = StaticModel.CellIdentifiers(rawValue: identifier.rawValue) else {
			fatalError("Unknown cell identifier \(identifier)")
		}
		return cells[id]!
	}
	
}
