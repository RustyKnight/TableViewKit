//
// Created by Shane Whitehead on 13/6/17.
// Copyright (c) 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

open class TableViewKitTableViewController<Model: TableViewKitModel>: UITableViewController, TableViewKitModelDelegate, UITableViewDataSourcePrefetching {
  
  public var model: Model!
  
  public var segueController: TableViewKitSegueController?
  
  public var deleteRowAnimation: UITableViewRowAnimation = .automatic
  public var insertRowAnimation: UITableViewRowAnimation = .automatic
  public var reloadRowAnimation: UITableViewRowAnimation = .automatic
  
  public var deleteSectionAnimation: UITableViewRowAnimation = .automatic
  public var insertSectionAnimation: UITableViewRowAnimation = .automatic
  public var reloadSectionAnimation: UITableViewRowAnimation = .automatic
  
  //	internal var estimatedCellRowHeight: [IndexPath: CGFloat] = [:]
  //	internal var estimatedSectionHeaderHeight: [Int: CGFloat] = [:]
  //	internal var estimatedSectionFooterHeight: [Int: CGFloat] = [:]
  
//  public var preferredCellRowHeight: CGFloat = 22
//  public var preferredSectionHeaderHeight: CGFloat = 18
//  public var preferredSectionFooterHeight: CGFloat = 18
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 10, *) {
      tableView.prefetchDataSource = self
    }
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadModel()
  }
  
  open func loadModel() {
    // Promise here would make it easier to
    // inject the loading process
    //    _ = model.applyDesiredState()
    applyDesiredState(reloadOnly: true)
    model.willBecomeActive()
    //		tableView.reloadData()
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    model.didBecomeInactive()
  }
  
  open override func numberOfSections(in tableView: UITableView) -> Int {
    ////log(debug: "numberOfSections = \(model.sectionCount)")
    return model.sectionCount
  }
  
  // MARK: UITableViewDataSource
  
  open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return model.shouldSelectRow(at: indexPath)
  }
  
  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ////log(debug: "indexPath = \(indexPath)")
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
    ////log(debug: "numberOfRowsInSection(\(section)) = \(model.section(at: section).rowCount)")
    return model.section(at: section).rowCount
  }
  
  open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  open override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //		defer {
    //			model.cellSelection(didChangeTo: indexPath)
    //		}
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
    
    //		let height = cell.frame.size.height
    //		estimatedCellRowHeight[indexPath] = height
    
    model.section(at: indexPath.section).willDisplay(cell, forRowAt: indexPath.row)
  }
  
  open override func tableView(
    _ tableView: UITableView,
    didEndDisplaying cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    
    //		let height = cell.frame.size.height
    //		estimatedCellRowHeight[indexPath] = height
    
    guard let identifier = identifier(forCell: cell) else {
      //			log(warning: "Could not find identifier for cell \(cell)")
      return
    }
    
    model.didEndDisplaying(cell: cell, withIdentifier: identifier, at: indexPath)
    
    ////log(debug: "...indexPath = \(indexPath)")
    //		model.section(at: indexPath.section).didEndDisplaying(cell, forRowAt: indexPath.row)
  }
  
  open override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return model.sectionIndexTitles
  }
  
  open override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return model.section(forIndexTitle: title, at: index)
  }
  
  //	open override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
  //		guard let height = estimatedCellRowHeight[indexPath] else {
  //			return preferredCellRowHeight
  //		}
  //		//log(debug: "Estimated height = \(height)")
  //		return height
  //	}
  
  //	open override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
  //		guard let height = estimatedSectionHeaderHeight[section] else {
  //			return preferredSectionHeaderHeight
  //		}
  //		//log(debug: "Estimated section header height = \(height)")
  //		return height
  //	}
  //
  //	open override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
  //		guard let height = estimatedSectionFooterHeight[section] else {
  //			return preferredSectionFooterHeight
  //		}
  //		//log(debug: "Estimated section fotter height = \(height)")
  //		return height
  //	}
  
  //	open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  //
  //	}
  
  //	open override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
  //		let height = view.frame.size.height
  //		estimatedSectionHeaderHeight[section] = height
  //	}
  //
  //	open override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
  //		let height = view.frame.size.height
  //		estimatedSectionFooterHeight[section] = height
  //	}
  
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
  
  open func perform(action: Any, value: Any?, section: Int, row: Int) {
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
  
  open func segueWasRejected(withReason reason: String) {
  }
  
  open func tableViewModel(
    _ model: TableViewKitModel,
    performSegueWithIdentifier identifier: SegueIdentifiable,
    controller: TableViewKitSegueController) {
    
    ////log(debug: "performSegue with \(identifier)")
    segueController = controller
    
    guard shouldPerformSegue(withIdentifier: identifier, sender: self) else {
      guard let reason = segueController!.segueRejectedReason(forIdentifier: identifier, sender: self) else {
        return
      }
      segueWasRejected(withReason: reason)
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
    // to a future time, allowing the changes to be batched
  }
  
  /**
   Called by applyDesiredState before it performs its functionality
   This is an oppurtunity to perform any kind of "pre-state" modifications
   setup, like turning of view animations for example
   */
  open func beforeApplyingDesiredState() {
    
  }
  
  /**
   Called by applyDesiredState after it has performed its functionality
   */
  open func afterApplyingDesiredState() {
    // This seems to be interfering with the animations
    //		tableView.reloadData()
    //		tableView.layoutIfNeeded()
  }
  
  open func applyDesiredState(reloadOnly: Bool = false) {
    beforeApplyingDesiredState()
    //		let operation = model.applyDesiredState()
    //		guard !operation.isEmpty else {
    //			return
    //		}
    
    log(debug: "reloadOnly = \(reloadOnly)")
    if reloadOnly {
      log(debug: "Reload: Apply modification states")
      _ = model.applyModificationStates()
      log(debug: "Reload: Apply insert states")
      _ = model.applyInsertStates()
      log(debug: "Reload: reloadData")
      tableView.reloadData()
      tableView.layoutSubviews()
      afterApplyingDesiredState()
      return
    } else {
      inAnimationBlock({
        log(debug: "performBatchModification")
        self.performBatchModification()
      }) { (completed) in
        self.inAnimationBlock({
          log(debug: "performInsertOperations")
          self.performInsertOperations()
        }, complition: { (completed) in
          self.tableView.layoutSubviews()
          self.afterApplyingDesiredState()
        })
      }
    }
    
  }
  
  func inAnimationBlock(_ perform: @escaping () -> Void, complition:  @escaping (Bool) -> Void) {
    if #available(iOS 11, *) {
      tableView.performBatchUpdates({
        perform()
      }) { (completed) in
        complition(completed)
      }
    } else {
      CATransaction.begin()
      tableView.beginUpdates()
      CATransaction.setCompletionBlock {
        complition(true)
      }
      
      perform()
      
      tableView.endUpdates()
      CATransaction.commit()
    }
  }
  
  internal func performBatchModification() {
    if #available(iOS 11, *) {
      tableView.performBatchUpdates({
        self.performModifyOperations()
      }) { (completed) in
        //				self.afterApplyingDesiredState()
      }
    } else {
      CATransaction.begin()
      tableView.beginUpdates()
      CATransaction.setCompletionBlock {
        //				self.afterApplyingDesiredState()
      }
      
      self.performModifyOperations()
      
      tableView.endUpdates()
      CATransaction.commit()
    }
  }
  
  internal func performBatchInserts() {
    if #available(iOS 11, *) {
      tableView.performBatchUpdates({
        self.performInsertOperations()
      }) { (completed) in
        //				self.afterApplyingDesiredState()
      }
    } else {
      CATransaction.begin()
      tableView.beginUpdates()
      CATransaction.setCompletionBlock {
        //				self.afterApplyingDesiredState()
      }
      
      self.performInsertOperations()
      
      tableView.endUpdates()
      CATransaction.commit()
    }
  }
  
  internal func performModifyOperations() {
    let modifyOperations = model.applyModificationStates()
    
    if let ops = modifyOperations.sections[.delete], ops.count > 0 {
      //log(debug: "Delete \(ops.count) sections")
      tableView.deleteSections(ops, with: deleteSectionAnimation)
    }
    if let ops = modifyOperations.sections[.update], ops.count > 0 {
      //log(debug: "Update \(ops.count) sections")
      tableView.reloadSections(ops, with: reloadSectionAnimation)
    }
    
    if let ops = modifyOperations.rows[.delete], ops.count > 0 {
      //log(debug: "Delete \(ops.count) rows")
      tableView.deleteRows(at: ops, with: deleteRowAnimation)
    }
    if let ops = modifyOperations.rows[.update], ops.count > 0 {
      //log(debug: "Update \(ops.count) rows")
      tableView.reloadRows(at: ops, with: reloadRowAnimation)
    }
  }
  
  internal func performInsertOperations() {
    let insertOperations = model.applyInsertStates()
    
    if let ops = insertOperations.sections[.insert], ops.count > 0 {
      //log(debug: "Insert \(ops.count) sections")
      tableView.insertSections(ops, with: insertSectionAnimation)
    }
    if let ops = insertOperations.rows[.insert], ops.count > 0 {
      //log(debug: "Insert \(ops.count) rows")
      tableView.insertRows(at: ops, with: insertRowAnimation)
    }
  }
  
  
  open func shouldPerformSegue(withIdentifier identifier: SegueIdentifiable, sender: Any?) -> Bool {
    ////log(debug: "shouldPerformSegue with \(identifier)")
    guard let controller = segueController else {
      return false
    }
    
    return controller.shouldPerformSegue(withIdentifier: identifier, sender: sender)
  }
  
  open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier != nil else {
      return
    }
    ////log(debug: "prepare with \(segue.identifier!)")
    
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
  
  // MARK: UITableViewDataSourcePrefetching
  
  @objc open func tableView(_ view: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      _ = tableView(view, cellForRowAt: indexPath)
    }
  }
  
}
