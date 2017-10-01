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

	func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool

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
	func cell(withIdentifier: String, at indexPath: IndexPath) -> UITableViewCell
}

open class DefaultTableViewKitModel<SectionIdentifier: Hashable>: TableViewKitModel {
	
	public var sharedContext: [AnyHashable: Any] = [:]

	public var allSections: [SectionIdentifier: AnyTableViewKitSection] = [:]
	public var preferredSectionOrder: [SectionIdentifier] = []
	internal var activeSections: [SectionIdentifier] = []

	public var delegate: TableViewKitModelDelegate
	
	public init(delegate: TableViewKitModelDelegate) {
		self.delegate = delegate
	}
	
	public func applyDesiredState() -> TableViewKitModelOperation {
		let stateManager = StateManager(allItems: allSections, preferredOrder: preferredSectionOrder)
		let sortedActiveSections = stateManager.sortByPreferredOrder(activeSections)
		let sortedAllSections = stateManager.sortByPreferredOrder(Array(allSections.keys))

		for section in sortedActiveSections {
			if section.desiredState == .hide {
				// This is a special case, where it overrides the
				// state of the rows
				// Should this be possible??
			} else {
				section.applyDesiredState()
			}
		}
	}
	
	public func cell(withIdentifier identifier: String, at indexPath: IndexPath) -> UITableViewCell {
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

	public func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool {
		let section = self.section(at: path.section)
		return section.didSelectRow(at: path, from: controller)
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
