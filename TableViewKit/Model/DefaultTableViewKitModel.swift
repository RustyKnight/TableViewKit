//
//  DefaultTableViewKitModel.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation
import LogWrapperKit

open class DefaultTableViewKitModel: TableViewKitModel, TableViewKitSectionDelegate {
	
	public var sharedContext: [AnyHashable: Any] = [:]
	
	public var allSections: [AnyHashable: AnyTableViewKitSection] = [:]
	public var preferredSectionOrder: [AnyHashable] = []
	internal var activeSections: [AnyHashable] = []
	
	public var delegate: TableViewKitModelDelegate
	
	public init(delegate: TableViewKitModelDelegate) {
		self.delegate = delegate
	}
	
	public func applyDesiredState() -> TableViewKitModelOperation {
		
		// This is done here because it could effect the desired state
		// of a section
		var sectionOperations: [AnyHashable: [Operation:[Int]]] = [:]
		for entry in allSections {
			sectionOperations[entry.key] = entry.value.applyDesiredState()
		}
		
		var unmodifiedSections: [AnyHashable] = []
		unmodifiedSections.append(contentsOf: activeSections)
		
		let stateManager = StateManager(allItems: allSections, preferredOrder: preferredSectionOrder)
		let operations = stateManager.operationsForDesiredState(basedOn: activeSections)
		activeSections = stateManager.apply(operations: operations, to: activeSections, sortBy: preferredSectionOrder)
		
		// Sections which have been removed, we don't care about
		// Sections which have been inserted, we don't care about - will initialise their default state
		// Sections which have been updated, we don't care about - they will update their entire contents
		
		let sectionsToBeInserted = operations.insert
		let sectionsToBeRemoved = operations.delete
		let sectionsToBeReloaded = operations.update
		
		var deletePaths: [IndexPath] = []
		var updatePaths: [IndexPath] = []
		var insertPaths: [IndexPath] = []
		
		for target in operations.operations(for: .update) {
			let section = self.section(withIdentifier: target.identifier)
			guard let operations = sectionOperations[target.identifier] else {
				fatalError("Can not find section operations for section with identifier \(target.identifier)")
			}
			guard let sectionIndex = index(of: section) else {
				// What happended here?
				continue
			}
			
			deletePaths.append(contentsOf: operations[.delete]!.map { IndexPath(row: $0, section: sectionIndex) })
			insertPaths.append(contentsOf: operations[.insert]!.map { IndexPath(row: $0, section: sectionIndex) })
			updatePaths.append(contentsOf: operations[.update]!.map { IndexPath(row: $0, section: sectionIndex) })
		}

		// Remove all sections which might have been removed
		for property in operations.operations(for: .delete) {
			let id = property.identifier
			guard let index = unmodifiedSections.index(of: id) else {
				// What happended here??
				continue
			}
			unmodifiedSections.remove(at: index)
		}
		
		// Update the state of the rows in all the
		// sections that were inserted to ensure that the
		// rows are at their desired states
		for op in operations.operations(for: .insert) {
			let identifier = op.identifier
			let section = self.section(withIdentifier: identifier)
			_ = section.applyDesiredState()
		}
		
//		for sectionIndex in 0..<unmodifiedSections.count {
//			let identifier: AnyHashable = unmodifiedSections[sectionIndex]
//			let section = self.section(withIdentifier: identifier)
////			let sectionOperations = section.applyDesiredState()
//			guard let operations = sectionOperations[identifier] else {
//				fatalError("Can not find section operations for section with identifier \(identifier)")
//			}
//			guard let sectionIndex = originalIndex(of: section) else {
//				// What happended here?
//				continue
//			}
//
//			deletePaths.append(contentsOf: operations[.delete]!.map { IndexPath(row: $0, section: sectionIndex) })
//			insertPaths.append(contentsOf: operations[.insert]!.map { IndexPath(row: $0, section: sectionIndex) })
//			updatePaths.append(contentsOf: operations[.update]!.map { IndexPath(row: $0, section: sectionIndex) })
//		}
		
		var rowOperations: [Operation: [IndexPath]] = [:]
		rowOperations[.delete] = deletePaths
		rowOperations[.insert] = insertPaths
		rowOperations[.update] = updatePaths

		log(debug: "rows delete: \(deletePaths)")
		log(debug: "rows insert: \(insertPaths)")
		log(debug: "rows update: \(updatePaths)")

		log(debug: "sections delete: \(sectionsToBeRemoved)")
		log(debug: "sections insert: \(sectionsToBeInserted)")
		log(debug: "sections update: \(sectionsToBeReloaded)")

		var finalSectionOperations: [Operation: IndexSet] = [:]
		finalSectionOperations[.delete] = IndexSet(sectionsToBeRemoved.map { $0.index })
		finalSectionOperations[.insert] = IndexSet(sectionsToBeInserted.map { $0.index })
		finalSectionOperations[.update] = IndexSet(sectionsToBeReloaded.map { $0.index })

		return DefaultTableViewKitModelOperation(sections: finalSectionOperations,
		                                         rows: rowOperations)
	}
	
	func section(withIdentifier identifier: AnyHashable) -> TableViewKitSection {
		return allSections[identifier]!
	}
	
	public func cell(withIdentifier identifier: CellIdentifiable, at indexPath: IndexPath) -> UITableViewCell {
		return delegate.cell(withIdentifier: identifier, at: indexPath)
	}

	public func cell(withIdentifier identifier: CellIdentifiable) -> UITableViewCell? {
		return delegate.cell(withIdentifier: identifier)
	}

	public func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		let aSection = section(at: indexPath.section)
		return aSection.cell(forRowAt: indexPath)
	}
	
	public var sectionCount: Int {
		return activeSections.count
	}
	
	public func section(at: Int) -> TableViewKitSection {
		return allSections[activeSections[at]]!
	}
	
	public func didSelectRow(at path: IndexPath) -> Bool {
		let section = self.section(at: path.section)
		return section.didSelectRow(at: path)
	}
	
	public func setContext(`for` key: AnyHashable, to value: Any?) {
		sharedContext[key] = value
		
		for section in allSections.values {
			section.sharedContext(for: key, didChangeTo: value)
		}
	}
	
	public func context(`for` key: AnyHashable) -> Any? {
		return sharedContext[key]
	}
	
	func index(of section: TableViewKitSection) -> Int? {
		return index(of: section, in: activeSections)
	}

	func originalIndex(of section: TableViewKitSection) -> Int? {
		return index(of: section, in: allSections.keys.map { $0 })
	}

	func index(of section: TableViewKitSection, `in` sections: [AnyHashable]) -> Int? {
		return sections.index(where: { (entry: AnyHashable) -> Bool in
			guard let element = allSections[entry] else {
				return false
			}
			return section == element
		})
	}
	
	internal func indexPaths(forRows rows: [Int], from section: TableViewKitSection) -> [IndexPath]? {
		guard rows.count > 0 else {
			return nil
		}
		
		guard let sectionIndex = index(of: section) else {
			return nil
		}
		var paths: [IndexPath] = []
		for row in rows {
			paths.append(IndexPath(row: row, section: sectionIndex))
		}
		return paths
	}
	
	open func stateDidChange(for section: TableViewKitSection) {
		delegate.stateDidChange(for: self)
	}

	public func tableViewSection(
		_ section: TableViewKitSection,
		performSegueWithIdentifier identifier: SegueIdentifiable,
		controller: TableViewKitSegueController) {
		delegate.tableViewModel(self, performSegueWithIdentifier: identifier, controller: controller)
	}
	
	public func tableViewSection(
		_ tableViewSection: TableViewKitSection,
		presentActionSheetAtRow row: Int,
		title: String?,
		message: String?,
		actions: [UIAlertAction]) {
		guard let sectionIndex = index(of: tableViewSection) else {
			return
		}
		delegate.tableViewModel(self,
		                        presentActionSheetAtSection: sectionIndex,
		                        row: row,
		                        title: title,
		                        message: message,
		                        actions: actions)
	}
	
	public func tableViewSection(_ section: TableViewKitSection, didFailWith error: Error) {
		delegate.tableViewModel(self, section: section, didFailWith: error)
	}
	
	public func tableViewSection(
		_ section: TableViewKitSection,
		showAlertAtRow row: Int,
		titled title: String?,
		message: String?,
		preferredStyle: UIAlertControllerStyle,
		actions: [UIAlertAction]) {
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(
			self,
			showAlertAtSection: index,
			row: row,
			titled: title,
			message: message,
			preferredStyle: preferredStyle,
			actions: actions)
	}
	
	public func willBecomeActive() {
		// It's important to notify ALL sections, as some
		// may be hidden, but will need to know when the model
		// becomes active so that they monitor for state
		// changes which might make them visible
		for section in allSections.values {
			section.willBecomeActive()
		}
	}
	
	public func didBecomeInactive() {
		for section in allSections.values {
			section.didBecomeInactive()
		}
	}
	
}
