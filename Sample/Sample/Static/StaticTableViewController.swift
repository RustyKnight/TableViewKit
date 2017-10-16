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
	
	enum SegueIdenitifer: String, Identifiable {
		case hello = "Hello"
		
		var value: String { return self.rawValue }
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
			StaticModel.Sections.Section1.cell1.rawValue: cell1,
			StaticModel.Sections.Section1.cell2.rawValue: cell2,
			StaticModel.Sections.Section1.cell3.rawValue: cell3,
			StaticModel.Sections.Section1.cell4.rawValue: cell4,
			StaticModel.Sections.Section1.cell5.rawValue: cell5,
			
			StaticModel.Sections.Section2.cell1.rawValue: section02Cell01,
			StaticModel.Sections.Section2.cell2.rawValue: section02Cell02,
			StaticModel.Sections.Section2.cell3.rawValue: section02Cell03,
			StaticModel.Sections.Section2.cell4.rawValue: section02Cell04,
			StaticModel.Sections.Section2.cell5.rawValue: section02Cell05,
			StaticModel.Sections.Section2.cell6.rawValue: section02Cell06,
		]
		
		model = StaticModel(delegate: self)
		
		super.viewDidLoad()
	}
	
	override func cell(withIdentifier identifier: CellIdentifiable, at indexPath: IndexPath) -> UITableViewCell {
		let id = identifier.value
		return cells[id]!
	}
	
	override func performUpdate() {
		applyDesiredState()
	}

	@IBAction func unwindTo(segue: UIStoryboardSegue) {
		didUnwindFrom(segue)
	}

}
