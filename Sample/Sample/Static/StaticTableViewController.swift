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
	
	enum SegueIdenitifer: String {
		case hello = "Hello"
	}
	
	@IBOutlet weak var cell1: UITableViewCell!
	@IBOutlet weak var cell2: UITableViewCell!
	@IBOutlet weak var cell3: UITableViewCell!
	@IBOutlet weak var cell4: UITableViewCell!
	@IBOutlet weak var cell5: UITableViewCell!
	
	@IBOutlet weak var section02Cell01: UITableViewCell!
	@IBOutlet weak var section02Cell02: UITableViewCell!
	@IBOutlet weak var section02Cell03: UITableViewCell!
	@IBOutlet weak var section02Cell04: UITableViewCell!
	@IBOutlet weak var section02Cell05: UITableViewCell!
	@IBOutlet weak var section02Cell06: UITableViewCell!

	var cells: [String: UITableViewCell]!

	override func viewDidLoad() {
		
		cells = [
			StaticModel.Section1.cell1.rawValue: cell1,
			StaticModel.Section1.cell2.rawValue: cell2,
			StaticModel.Section1.cell3.rawValue: cell3,
			StaticModel.Section1.cell4.rawValue: cell4,
			StaticModel.Section1.cell5.rawValue: cell5,
			
			StaticModel.Section2.cell1.rawValue: section02Cell01,
			StaticModel.Section2.cell2.rawValue: section02Cell02,
			StaticModel.Section2.cell3.rawValue: section02Cell03,
			StaticModel.Section2.cell4.rawValue: section02Cell04,
			StaticModel.Section2.cell5.rawValue: section02Cell05,
			StaticModel.Section2.cell6.rawValue: section02Cell06,
		]
		
		model = StaticModel(delegate: self)
		
		super.viewDidLoad()
	}

	override func cell<Identifier>(withIdentifier identifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier : RawRepresentable, Identifier.RawValue == String {
		let id = identifier.rawValue
		return cells[id]!
	}
	
	override func performUpdate() {
		applyDesiredState()
	}

	@IBAction func unwindTo(segue: UIStoryboardSegue) {
		didUnwindFrom(segue)
	}

}
