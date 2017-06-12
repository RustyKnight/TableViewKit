//
// Created by Shane Whitehead on 13/6/17.
// Copyright (c) 2017 Beam Communications. All rights reserved.
//

import Foundation

class TVKDefaultTableViewController: UITableViewController, TVKModelDelegate {

	var model: TVKModel!

	var seguePreparer: TVKSegueController?

	public var preferredAddAnimation: UITableViewRowAnimation = .automatic
	public var preferredDeleteAnimation: UITableViewRowAnimation = .automatic
	public var preferredRefreshAnimation: UITableViewRowAnimation = .automatic

	override func viewDidLoad() {
		super.viewDidLoad()

		model.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadModel()
	}

	func loadModel(disableDelegate: Bool = true) {
		if disableDelegate {
			model.delegate = nil
		}
		model.willBecomeActive()
		model.delegate = self
		tableView.reloadData()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		model.didBecomeInactive()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return model.sectionCount
	}

	// MARK: UITableViewDataSource

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let title = model.section(at: section).name
		return title
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.section(at: section).rowCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return model.section(at: indexPath.section).cellFor(tableView: tableView, at: indexPath)
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if model.didSelectRow(at: indexPath, from: self) {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}

	public override func tableView(
			_ tableView: UITableView,
			willDisplay cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		model.section(at: indexPath.section).willDisplay(cell, forRowAt: indexPath.row)
	}

	public override func tableView(
			_ tableView: UITableView,
			didEndDisplaying cell: UITableViewCell,
			forRowAt indexPath: IndexPath) {
		model.section(at: indexPath.section).didEndDisplaying(cell, forRowAt: indexPath.row)
	}

	// MARK: TVKModel

	func tableViewModel(_ model: TVKModel, sectionsWereRemovedAt sections: [Int]) {
		tableView.deleteSections(IndexSet(sections), with: preferredDeleteAnimation)
	}

	func tableViewModel(_ model: TVKModel, sectionsWereAddedAt sections: [Int]) {
		tableView.insertSections(IndexSet(sections), with: preferredAddAnimation)
	}

	func tableViewModel(_ model: TVKModel, sectionsWereChangedAt sections: [Int]) {
		tableView.reloadSections(IndexSet(sections), with: preferredRefreshAnimation)
	}

	func tableViewModel(_ model: TVKModel, rowsWereAddedAt rows: [IndexPath]) {
		tableView.insertRows(at: rows, with: preferredAddAnimation)
	}

	func tableViewModel(_ model: TVKModel, rowsWereRemovedAt rows: [IndexPath]) {
		tableView.reloadRows(at: rows, with: preferredRefreshAnimation)
	}

	func tableViewModel(_ model: TVKModel, rowsWereChangedAt rows: [IndexPath]) {
		tableView.deleteRows(at: rows, with: preferredDeleteAnimation)
	}

	func tableViewModel(_ model: TVKModel, section: TVKSection, didFailWith: Error) {
	}

	func tableViewModel(
			_ model: TVKModel,
			showAlertAtSection section: Int,
			row: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction]) {
		let indexPath = IndexPath(row: row, section: section)
		let bounds = tableView.rectForRow(at: indexPath)

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

	func tableViewModel(_ model: TVKModel, sectionsDidStartLoading: [Int]) {
	}

	func tableViewModel(_ model: TVKModel, sectionsDidCompleteLoading: [Int]) {
	}

	func tableViewModel(
			_ model: TVKModel,
			performSegueWithIdentifier identifier: String,
			controller: TVKSegueController) {
		performSegue(withIdentifier: identifier, sender: controller)
	}

	func tableViewModel(
			_ model: TVKModel,
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
}

extension TVKDefaultTableViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier != nil else {
			return
		}

		if let preparer = sender as? TVKSegueController {
			seguePreparer = preparer
			preparer.prepare(for: segue)
		}
	}

	func didUnwindFrom(_ segue: UIStoryboardSegue) {
		defer {
			seguePreparer = nil
		}
		guard let seguePreparer = seguePreparer else {
			return
		}

		seguePreparer.unwound(from: segue)
	}

}
