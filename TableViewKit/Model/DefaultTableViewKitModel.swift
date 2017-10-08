//
//  DefaultTableViewKitModel.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation


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

		// Remove all sections which might have changed
		for key in [Operation.update, Operation.delete] {
			for property in operations.operations(for: key) {
				let id = property.identifier
				guard let index = unmodifiedSections.index(of: id) else {
					// What happended here??
					continue
				}
				unmodifiedSections.remove(at: index)
			}
		}
		
		// Update the state of the rows in all the
		// sections that were inserted to ensure that the
		// rows are at their desired states
		for op in operations.operations(for: .insert) {
			let identifier = op.identifier
			let section = self.section(withIdentifier: identifier)
			_ = section.applyDesiredState()
		}
		
		var deletePaths: [IndexPath] = []
		var insertPaths: [IndexPath] = []
		var updatePaths: [IndexPath] = []
		
		for sectionIndex in 0..<unmodifiedSections.count {
			let identifier: AnyHashable = unmodifiedSections[sectionIndex]
			let section = self.section(withIdentifier: identifier)
//			let sectionOperations = section.applyDesiredState()
			guard let operations = sectionOperations[identifier] else {
				fatalError("Can not find section operations for section with identifier \(identifier)")
			}
			guard let sectionIndex = index(of: section) else {
				// What happended here?
				continue
			}
			
			deletePaths.append(contentsOf: operations[.delete]!.map { IndexPath(row: $0, section: sectionIndex) })
			insertPaths.append(contentsOf: operations[.insert]!.map { IndexPath(row: $0, section: sectionIndex) })
			updatePaths.append(contentsOf: operations[.update]!.map { IndexPath(row: $0, section: sectionIndex) })
		}
		
		var rowOperations: [Operation: [IndexPath]] = [:]
		rowOperations[.delete] = deletePaths
		rowOperations[.insert] = insertPaths
		rowOperations[.update] = updatePaths
		
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
	
	public func cell<Identifier>(withIdentifier identifier: Identifier, at indexPath: IndexPath) -> UITableViewCell where Identifier : RawRepresentable, Identifier.RawValue == String {
		return delegate.cell(withIdentifier: identifier, at: indexPath)
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
		performSegueWithIdentifier identifier: String,
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
		for index in 0..<sectionCount {
			section(at: index).willBecomeActive()
		}
	}
	
	public func didBecomeInactive() {
		for index in 0..<sectionCount {
			section(at: index).didBecomeInactive()
		}
	}
	
}
