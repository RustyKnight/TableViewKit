//
//  StaticTableViewController.swift
//  Sample
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import UIKit
import TableViewKit

class StaticTableViewController: StaticTableViewKitTableViewController<StaticModel> {
	
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

	var cells: [StaticModel.CellIdentifiers: UITableViewCell]!

	override func viewDidLoad() {
		
		cells = [
			.section1Cell1: cell1,
			.section1Cell2: cell2,
			.section1Cell3: cell3,
			.section1Cell4: cell4,
			.section1Cell5: cell5,
			
			.section2Cell1: section02Cell01,
			.section2Cell2: section02Cell02,
			.section2Cell3: section02Cell03,
			.section2Cell4: section02Cell04,
			.section2Cell5: section02Cell05,
			.section2Cell6: section02Cell06,
		]
		
		model = StaticModel(delegate: self)
		
		super.viewDidLoad()
	}
	
	override func identifier(forCell cell: UITableViewCell) -> CellIdentifiable? {
		for (key, value) in cells {
			if value == cell {
				return key
			}
		}
		return nil
	}

	override func cell(withIdentifier identifier: CellIdentifiable) -> UITableViewCell {
		guard let id = identifier as? StaticModel.CellIdentifiers else {
			fatalError("Invalid identifier [\(identifier)]")
		}
		return cells[id]!		
	}
	
	override func performUpdate() {
		applyDesiredState()
	}

	@IBAction func unwindTo(segue: UIStoryboardSegue) {
		didUnwindFrom(segue)
	}

}
