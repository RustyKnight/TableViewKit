//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public enum Operation {
	case insert
	case delete
	case update //?
}

public protocol Contextual {
	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?
}

public protocol TableViewKitModel: Contextual {
	
	var delegate: TableViewKitModelDelegate { get set }
	var sectionCount: Int { get }

	func section(at: Int) -> TableViewKitSection

	func didSelectRow(at path: IndexPath) -> Bool

	func willBecomeActive()
	func didBecomeInactive()
	
	// This is responsible for applying the changes which have been made
	// since the last update pass, so that the "view" mode matches the
	// "desired" state of the model
	func applyDesiredState() -> TableViewKitModelOperation
	
	func cell(forRowAt indexPath: IndexPath) -> UITableViewCell
}

// A set of operations which need to be carried out
// when moving desired state to the actvie state
public protocol TableViewKitModelOperation {
	var sections: [Operation: IndexSet] {get}
	var rows: [Operation: [IndexPath]] {get}
}

struct DefaultTableViewKitModelOperation: TableViewKitModelOperation {
  let sections: [Operation : IndexSet]
  let rows: [Operation : [IndexPath]]
}

public protocol TableViewKitModelDelegate {

	func tableViewModel(_ model: TableViewKitModel, sectionsWereRemovedAt sections: [Int])
	func tableViewModel(_ model: TableViewKitModel, sectionsWereAddedAt sections: [Int])
	func tableViewModel(_ model: TableViewKitModel, sectionsWereChangedAt sections: [Int])

	func tableViewModel(_ model: TableViewKitModel, rowsWereAddedAt rows: [IndexPath])
	func tableViewModel(_ model: TableViewKitModel, rowsWereRemovedAt rows: [IndexPath])
	func tableViewModel(_ model: TableViewKitModel, rowsWereChangedAt rows: [IndexPath])

	func tableViewModel(_ model: TableViewKitModel, section: TableViewKitSection, didFailWith: Error)
	func tableViewModel(
			_ model: TableViewKitModel,
			showAlertAtSection section: Int,
			row: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewModel(
			_ model: TableViewKitModel,
			performSegueWithIdentifier identifier: String,
			controller: TableViewKitSegueController)

	func tableViewModel(
			_ model: TableViewKitModel,
			presentActionSheetAtSection section: Int,
			row: Int,
			title: String?,
			message: String?,
			actions: [UIAlertAction])

	func tableViewModel(_ model: TableViewKitModel, sectionsDidStartLoading: [Int])
	func tableViewModel(_ model: TableViewKitModel, sectionsDidCompleteLoading: [Int])

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
	func cell<Identifier: RawRepresentable>(withIdentifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier.RawValue == String
}
