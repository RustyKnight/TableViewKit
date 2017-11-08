//
// Created by Shane Whitehead on 13/6/17.
// Copyright (c) 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

open class TableViewKitTableViewController<Model: TableViewKitModel>: UITableViewController, TableViewKitModelDelegate {

	public var model: Model!

	public var segueController: TableViewKitSegueController?

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
		//log(debug: "numberOfSections = \(model.sectionCount)")
		return model.sectionCount
	}

	// MARK: UITableViewDataSource
	
	open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return model.shouldSelectRow(at: indexPath)
	}
	
	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//log(debug: "indexPath = \(indexPath)")
		return model.cell(forRowAt: indexPath)
	}

	open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let title = model.section(at: section).title
		return title
	}
	
	open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let footer = model.section(at: section).footer
		return footer
	}
	
	open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return nil
	}

	open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return nil
	}
	
	open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//log(debug: "numberOfRowsInSection(\(section)) = \(model.section(at: section).rowCount)")
		return model.section(at: section).rowCount
	}

	open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	open override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard model.shouldSelectRow(at: indexPath) else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		if !model.didSelectRow(at: indexPath) {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	open override func tableView(
			_ tableView: UITableView,
			willDisplay cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		//log(debug: "...indexPath = \(indexPath)")
		model.section(at: indexPath.section).willDisplay(cell, forRowAt: indexPath.row)
	}

	open override func tableView(
			_ tableView: UITableView,
			didEndDisplaying cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		
		guard let identifier = identifier(forCell: cell) else {
			log(warning: "Could not find identifier for cell \(cell)")
			return
		}
		
		model.didEndDisplaying(cell: cell, withIdentifier: identifier, at: indexPath)
		
		//log(debug: "...indexPath = \(indexPath)")
//		model.section(at: indexPath.section).didEndDisplaying(cell, forRowAt: indexPath.row)
	}

	// MARK: TVKModel
	
	open func identifier(forCell cell: UITableViewCell) -> CellIdentifiable? {
		return nil
	}

//	open func cell(withIdentifier: CellIdentifiable, at indexPath: IndexPath) -> UITableViewCell {
//		fatalError("Not yet implemented")
//		// Typically, this will use reusable cell with identifer, but I'll leave that up
//		// to the implementor
//	}

	open func cell(withIdentifier: CellIdentifiable) -> UITableViewCell {
		fatalError("Not yet implemented")
	}

	public func stateDidChange(for model: TableViewKitModel) {
		performUpdate()
	}

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
	
	open func tableViewModel(
		_ model: TableViewKitModel,
		performSegueWithIdentifier identifier: SegueIdentifiable,
		controller: TableViewKitSegueController) {
		
		//log(debug: "performSegue with \(identifier)")
		segueController = controller
    
    guard shouldPerformSegue(withIdentifier: identifier, sender: self) else {
      return
    }
    self.performSegue(withIdentifier: identifier.value, sender: segueController)
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
		guard !operation.isEmpty else {
			return
		}
		tableView.beginUpdates()
		
		var areUpdatesVisible = false
		if let visibleRows: [IndexPath] = tableView.indexPathsForVisibleRows {
			
			for indexPath in visibleRows {
				log(debug: "VisibleRow = \(indexPath.section).\(indexPath.row)")
			}
			
			for sections in operation.sections.values {
				for section in sections {
					log(debug: "sections to update = \(section)")
				}
			}
			for paths in operation.rows.values {
				for path in paths {
					log(debug: "Rows to be updated = \(path.section).\(path.row)")
				}
			}

			areUpdatesVisible = operation.sections.values.filter({ (indexSet) -> Bool in
				return indexSet.filter({ (index) -> Bool in
					return visibleRows.contains { $0.section == index }
				}).count > 0
			}).count > 0

			if !areUpdatesVisible {
				areUpdatesVisible = operation.rows.values.filter({ (indexPaths) -> Bool in
					return indexPaths.filter { visibleRows.contains($0) }.count > 0
				}).count > 0
			}
		}
		
		log(debug: "areUpdatesVisible = \(areUpdatesVisible)")
		if !areUpdatesVisible {
			defer {
				UIView.setAnimationsEnabled(true)
			}
			UIView.setAnimationsEnabled(false)
		}
		
    for path in operation.rows[.delete]! {
      if let cell = tableView.cellForRow(at: path) {
        cell.layer.zPosition = -2
      }
      
      if let header = tableView.headerView(forSection: path.section) {
        header.layer.zPosition = -1
      }
    }
		
		if let ops = operation.sections[.delete], ops.count > 0 {
			tableView.deleteSections(ops, with: deleteSectionAnimation)
		}
		if let ops = operation.sections[.update], ops.count > 0 {
			tableView.reloadSections(ops, with: reloadSectionAnimation)
		}
		if let ops = operation.sections[.insert], ops.count > 0 {
			tableView.insertSections(ops, with: insertSectionAnimation)
		}

		if let ops = operation.rows[.delete], ops.count > 0 {
			tableView.deleteRows(at: ops, with: deleteRowAnimation)
		}
		if let ops = operation.rows[.update], ops.count > 0 {
			tableView.reloadRows(at: ops, with: reloadRowAnimation)
		}
		if let ops = operation.rows[.insert], ops.count > 0 {
			tableView.insertRows(at: ops, with: insertRowAnimation)
		}

		tableView.endUpdates()

		tableView.reloadData()
		tableView.layoutIfNeeded()
	}

	open func shouldPerformSegue(withIdentifier identifier: SegueIdentifiable, sender: Any?) -> Bool {
		//log(debug: "shouldPerformSegue with \(identifier)")
		guard let controller = segueController else {
			return false
		}
		
		return controller.shouldPerformSegue(withIdentifier: identifier, sender: sender)
	}

	open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier != nil else {
			return
		}
		//log(debug: "prepare with \(segue.identifier!)")

		if let preparer = sender as? TableViewKitSegueController {
			segueController = preparer
			preparer.prepare(for: segue)
		}
	}

	open func didUnwindFrom(_ segue: UIStoryboardSegue) {
		defer {
			segueController = nil
		}
		guard let seguePreparer = segueController else {
			return
		}

		seguePreparer.unwound(from: segue)
	}

}
