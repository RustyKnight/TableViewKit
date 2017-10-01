//
//  DefaultTableViewKitModel.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation


open class DefaultTableViewKitModel<SectionIdentifier: Hashable>: TableViewKitModel, TableViewKitSectionDelegate {
	
	public var sharedContext: [AnyHashable: Any] = [:]
	
	public var allSections: [SectionIdentifier: AnyTableViewKitSection] = [:]
	public var preferredSectionOrder: [SectionIdentifier] = []
	internal var activeSections: [SectionIdentifier] = []
	
	public var delegate: TableViewKitModelDelegate
	
	public init(delegate: TableViewKitModelDelegate) {
		self.delegate = delegate
	}
	
	public func applyDesiredState() -> TableViewKitModelOperation {
		
		var newSectionState: [SectionIdentifier] = []
		newSectionState.append(contentsOf: activeSections)
		
		let stateManager = StateManager(allItems: allSections, preferredOrder: preferredSectionOrder)
		let operations = stateManager.applyDesiredState(basedOn: activeSections)
		
		// Sections which have been removed, we don't care about
		// Sections which have been inserted, only really need to update the rows
		// to their desired state.
		// It's sections that havn't changed (or want to be reloaded) which are of
		// interest
		
		// Inserted sections only need to generate notifications for the section
		// This just makes sure that the rows in the sections are updated to their
		// desired state
		let sectionsToBeInserted = operations[.insert]!
		let sectionsToBeRemoved = operations[.delete]!
		let sectionsToBeReloaded = operations[.update]!
		
		for property in sectionsToBeRemoved {
			let id = property.identifier as! SectionIdentifier
			guard let index = newSectionState.index(of: id) else {
				// What happended here??
				continue
			}
			newSectionState.remove(at: index)
		}
		for property in sectionsToBeInserted {
			let id = property.identifier as! SectionIdentifier
			newSectionState.insert(id, at: property.index)
		}
		
		var deletePaths: [IndexPath] = []
		var insertPaths: [IndexPath] = []
		var updatePaths: [IndexPath] = []
		
		for sectionIndex in 0..<newSectionState.count {
			let identifier: SectionIdentifier = newSectionState[sectionIndex]
			let section = self.section(withIdentifier: identifier)
			let sectionOperations = section.applyDesiredState()
			deletePaths.append(contentsOf: sectionOperations[.delete]!.map { IndexPath(row: $0.index, section: sectionIndex) })
			insertPaths.append(contentsOf: sectionOperations[.insert]!.map { IndexPath(row: $0.index, section: sectionIndex) })
			updatePaths.append(contentsOf: sectionOperations[.update]!.map { IndexPath(row: $0.index, section: sectionIndex) })
		}
		
		var rowOperations: [Operation: [IndexPath]] = [:]
		rowOperations[.delete] = deletePaths
		rowOperations[.insert] = insertPaths
		rowOperations[.update] = updatePaths
		
		var sectionOperations: [Operation: IndexSet] = [:]
		sectionOperations[.delete] = IndexSet(sectionsToBeRemoved.map { $0.index })
		sectionOperations[.insert] = IndexSet(sectionsToBeInserted.map { $0.index })
		sectionOperations[.update] = IndexSet(sectionsToBeReloaded.map { $0.index })
		
		return DefaultTableViewKitModelOperation(sections: sectionOperations,
		                                         rows: rowOperations)
	}
	
	func section(withIdentifier identifier: SectionIdentifier) -> TableViewKitSection {
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
	
	func index(of section: TableViewKitSection, `in` sections: [SectionIdentifier]) -> Int? {
		return sections.index(where: { (entry: SectionIdentifier) -> Bool in
			guard let element = allSections[entry] else {
				return false
			}
			return section == element
		})
	}
	
	public func tableViewSectionDidStartLoading(_ section: TableViewKitSection) {
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidStartLoading: [index])
	}
	
	public func tableViewSectionDidCompleteLoading(_ section: TableViewKitSection) {
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidCompleteLoading: [index])
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
	
	public func tableViewSection(_ section: TableViewKitSection, rowsWereRemovedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereRemovedAt: paths)
	}
	
	public func tableViewSection(_ section: TableViewKitSection, rowsWereAddedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereAddedAt: paths)
	}
	
	public func tableViewSection(_ section: TableViewKitSection, rowsWereChangedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereChangedAt: paths)
	}
	
	public func tableViewSectionDidChange(_ section: TableViewKitSection) {
		guard !section.isHidden else {
			return
		}
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsWereChangedAt: [index])
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
