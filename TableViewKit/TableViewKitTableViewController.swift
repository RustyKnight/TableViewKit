//
// Created by Shane Whitehead on 13/6/17.
// Copyright (c) 2017 Beam Communications. All rights reserved.
//

import Foundation

open class TableViewKitTableViewController: UITableViewController, TableViewKitModelDelegate {

	public var model: TableViewKitModel!

	public var seguePreparer: TableViewKitSegueController?

	public var deleteRowAnimation: UITableViewRowAnimation = .automatic
	public var insertRowAnimation: UITableViewRowAnimation = .automatic
	public var reloadRowAnimation: UITableViewRowAnimation = .automatic
  
  public var deleteSectionAnimation: UITableViewRowAnimation = .automatic
  public var insertSectionAnimation: UITableViewRowAnimation = .automatic
  public var reloadSectionAnimation: UITableViewRowAnimation = .automatic

	open override func viewDidLoad() {
		super.viewDidLoad()
	}

	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadModel()
	}

	open func loadModel() {
		// Promise here would make it easier to
		// inject the loading process
    _ = model.applyDesiredState()
		model.willBecomeActive()
		tableView.reloadData()
	}
	
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		model.didBecomeInactive()
	}

	open override func numberOfSections(in tableView: UITableView) -> Int {
		print("numberOfSections = \(model.sectionCount)")
		return model.sectionCount
	}

	// MARK: UITableViewDataSource
	
	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return model.cell(forRowAt: indexPath)
	}

	open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let title = model.section(at: section).title
		print("titleForHeaderInSection = \(String(describing: title))")
		return title
	}
	
	open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let title = model.section(at: section).footer
		print("titleForFooterInSection = \(String(describing: title))")
		return title
	}

	open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print("numberOfRowsInSection = \(section)")
		return model.section(at: section).rowCount
	}

	open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	open override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if !model.didSelectRow(at: indexPath) {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	open override func tableView(
			_ tableView: UITableView,
			willDisplay cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		model.section(at: indexPath.section).willDisplay(cell, forRowAt: indexPath.row)
	}

	open override func tableView(
			_ tableView: UITableView,
			didEndDisplaying cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		model.section(at: indexPath.section).didEndDisplaying(cell, forRowAt: indexPath.row)
	}

	// MARK: TVKModel

	open func cell<Identifier>(withIdentifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier : RawRepresentable, Identifier.RawValue == String {
		fatalError("Not yet implemented")
		// Typically, this will use reusable cell with identifer, but I'll leave that up
		// to the implementor
	}
	
	public func sectionsWereRemovedFrom(_ model: TableViewKitModel) {
		performUpdate()
	}
	
	public func sectionsWereAddedTo(_ model: TableViewKitModel) {
		performUpdate()
	}
	
	public func sectionsWereChangedIn(_ model: TableViewKitModel) {
		performUpdate()
	}
	
	public func tableViewModel(_ model: TableViewKitModel, sectionStateDidChange section: TableViewKitSection) {
		performUpdate()
	}
	
	public func tableViewModel(_ model: TableViewKitModel, rowsWereAddedTo section: TableViewKitSection) {
		performUpdate()
	}
	
	public func tableViewModel(_ model: TableViewKitModel, rowsWereRemovedFrom section: TableViewKitSection) {
		performUpdate()
	}
	
	public func tableViewModel(_ model: TableViewKitModel, rowsWereUpdatedIn section: TableViewKitSection) {
		performUpdate()
	}

//
//	open func sectionsWereRemovedFrom(_ model: TableViewKitModel, sectionsWereRemovedAt sections: [Int]) {
//		performUpdate()
////		tableView.deleteSections(IndexSet(sections), with: preferredDeleteAnimation)
//	}
//
//	open func tableViewModel(_ model: TableViewKitModel, sectionsWereAddedAt sections: [Int]) {
//		performUpdate()
////		tableView.insertSections(IndexSet(sections), with: preferredAddAnimation)
//	}
//
//	open func tableViewModel(_ model: TableViewKitModel, sectionsWereChangedAt sections: [Int]) {
//		performUpdate()
////		tableView.reloadSections(IndexSet(sections), with: preferredRefreshAnimation)
//	}
//
//	open func tableViewModel(_ model: TableViewKitModel, rowsWereAddedAt rows: [IndexPath]) {
//		performUpdate()
////		tableView.insertRows(at: rows, with: preferredAddAnimation)
//	}
//
//	open func tableViewModel(_ model: TableViewKitModel, rowsWereRemovedAt rows: [IndexPath]) {
//		performUpdate()
////		tableView.reloadRows(at: rows, with: preferredRefreshAnimation)
//	}
//
//	open func tableViewModel(_ model: TableViewKitModel, rowsWereChangedAt rows: [IndexPath]) {
//		performUpdate()
////		tableView.deleteRows(at: rows, with: preferredDeleteAnimation)
//	}

	open func tableViewModel(_ model: TableViewKitModel, section: TableViewKitSection, didFailWith: Error) {
	}

	open func tableViewModel(
			_ model: TableViewKitModel,
			showAlertAtSection section: Int,
			row: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction]) {

//		let indexPath = IndexPath(row: row, section: section)
//		let bounds = tableView.rectForRow(at: indexPath)
		
		let alertController = UIAlertController(
				title: title,
				message: message,
				preferredStyle: .alert)
		
		for action in actions {
			alertController.addAction(action)
		}
		self.present(alertController,
				animated: true,
				completion: nil)
	}

	open func tableViewModel(_ model: TableViewKitModel, sectionsDidStartLoading: [Int]) {
	}

	open func tableViewModel(_ model: TableViewKitModel, sectionsDidCompleteLoading: [Int]) {
	}

	open override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		guard let controller = seguePreparer else {
			return false
		}
		
		return controller.shouldPerformSegue(withIdentifier: identifier, sender: sender)
	}
	
	open func tableViewModel(
		_ model: TableViewKitModel,
		performSegueWithIdentifier identifier: String,
		controller: TableViewKitSegueController) {
		performSegue(withIdentifier: identifier, sender: controller)
	}
	
	open func tableViewModel(
		_ model: TableViewKitModel,
		presentActionSheetAtSection section: Int,
		row: Int,
		title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		let indexPath = IndexPath(row: row, section: section)
		let bounds = tableView.rectForRow(at: indexPath)
		
		let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		for action in actions {
			controller.addAction(action)
		}
		controller.popoverPresentationController?.sourceView = self.tableView
		controller.popoverPresentationController?.sourceRect = bounds
		self.present(controller, animated: true)
	}

	// MARK: Extended functionality

	open func performUpdate() {
		// This is here to allow the off loading of the actualy application of the changes
		// to a future time, allowing the changes to be bayched
	}
	
	open func applyDesiredState() {
		let operation = model.applyDesiredState()
		tableView.beginUpdates()
		
		tableView.deleteSections(operation.sections[.delete]!, with: deleteSectionAnimation)
		tableView.insertSections(operation.sections[.insert]!, with: insertSectionAnimation)
		tableView.reloadSections(operation.sections[.update]!, with: reloadSectionAnimation)
		
		tableView.deleteRows(at: operation.rows[.delete]!, with: deleteRowAnimation)
		tableView.insertRows(at: operation.rows[.insert]!, with: insertRowAnimation)
		tableView.reloadRows(at: operation.rows[.update]!, with: reloadRowAnimation)
		
		tableView.endUpdates()
		
		tableView.reloadData()
	}

	open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier != nil else {
			return
		}

		if let preparer = sender as? TableViewKitSegueController {
			seguePreparer = preparer
			preparer.prepare(for: segue)
		}
	}

	open func didUnwindFrom(_ segue: UIStoryboardSegue) {
		defer {
			seguePreparer = nil
		}
		guard let seguePreparer = seguePreparer else {
			return
		}

		seguePreparer.unwound(from: segue)
	}

}
