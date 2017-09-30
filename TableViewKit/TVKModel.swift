//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol Contextual {
	func setContext(`for` key: AnyHashable, to value: Any?)
	func context(`for` key: AnyHashable) -> Any?
}

public enum Operation {
	case updated
	case deleted
	case inserted
}

public protocol TVKModel: Contextual {
	var delegate: TVKModelDelegate { get set }
	var sectionCount: Int { get }

	func section(at: Int) -> TVKSection

	func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool

	func willBecomeActive()
	func didBecomeInactive()
	
	// This is responsible for applying the changes which have been made
	// since the last update pass, so that the "view" mode matches the
	// "desired" state of the model
	func applyChanges() -> [Operation: [IndexPath]]
	
	func cell(forRowAt indexPath: IndexPath) -> UITableViewCell
}

public protocol TVKModelDelegate {

	func tableViewModel(_ model: TVKModel, sectionsWereRemovedAt sections: [Int])
	func tableViewModel(_ model: TVKModel, sectionsWereAddedAt sections: [Int])
	func tableViewModel(_ model: TVKModel, sectionsWereChangedAt sections: [Int])

	func tableViewModel(_ model: TVKModel, rowsWereAddedAt rows: [IndexPath])
	func tableViewModel(_ model: TVKModel, rowsWereRemovedAt rows: [IndexPath])
	func tableViewModel(_ model: TVKModel, rowsWereChangedAt rows: [IndexPath])

	func tableViewModel(_ model: TVKModel, section: TVKSection, didFailWith: Error)
	func tableViewModel(
			_ model: TVKModel,
			showAlertAtSection section: Int,
			row: Int,
			titled title: String?,
			message: String?,
			preferredStyle: UIAlertControllerStyle,
			actions: [UIAlertAction])

	func tableViewModel(
			_ model: TVKModel,
			performSegueWithIdentifier identifier: String,
			controller: TVKSegueController)

	func tableViewModel(
			_ model: TVKModel,
			presentActionSheetAtSection section: Int,
			row: Int,
			title: String?,
			message: String?,
			actions: [UIAlertAction])

	func tableViewModel(_ model: TVKModel, sectionsDidStartLoading: [Int])
	func tableViewModel(_ model: TVKModel, sectionsDidCompleteLoading: [Int])

	// This returns the cell with the specified identifier. Because it's possible for the UITableView
	// to manage the cells in different ways, this provides a simply delegation of responsibility
	// back up the call chain to all the UITableView implementation to decide how it should respond
	func cell(withIdentifier: String, at indexPath: IndexPath) -> UITableViewCell
}

open class TVKDefaultModel: TVKModel, TVKSectionDelegate {

	public var sharedContext: [AnyHashable: Any] = [:]

	internal var sections: [TVKAnySection] = []

	public var delegate: TVKModelDelegate
	
	public init(delegate: TVKModelDelegate) {
		self.delegate = delegate
	}
	
	public func applyChanges() -> [Operation : [IndexPath]] {
		fatalError("Not yet implemented")
	}
	
	public func cell(withIdentifier identifier: String, at indexPath: IndexPath) -> UITableViewCell {
		return delegate.cell(withIdentifier: identifier, at: indexPath)
	}
	
	public func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		let aSection = section(at: indexPath.section)
		return aSection.cell(forRowAt: indexPath)
	}

	public var sectionCount: Int {
		return sections.count
	}

	public func section(at: Int) -> TVKSection {
		return sections[at]
	}

	public func didSelectRow(at path: IndexPath, from controller: UITableViewController) -> Bool {
		let section = self.section(at: path.section)
		return section.didSelectRow(at: path, from: controller)
	}

	public func setContext(`for` key: AnyHashable, to value: Any?) {
		sharedContext[key] = value

		for section in sections {
			section.sharedContext(for: key, didChangeTo: value)
		}
	}

	public func context(`for` key: AnyHashable) -> Any? {
		return sharedContext[key]
	}

	func index(of section: TVKSection) -> Int? {
		return index(of: section, in: sections)
	}

	func index(of section: TVKSection, `in` sections: [TVKSection]) -> Int? {
		return sections.index(where: { (entry: TVKSection) -> Bool in
			section == entry
		})
	}

	public func tableViewSectionDidStartLoading(_ section: TVKSection) {
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidStartLoading: [index])
	}

	public func tableViewSectionDidCompleteLoading(_ section: TVKSection) {
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidCompleteLoading: [index])
	}

	internal func indexPaths(forRows rows: [Int], from section: TVKSection) -> [IndexPath]? {
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

	public func tableViewSection(_ section: TVKSection, rowsWereRemovedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereRemovedAt: paths)
	}

	public func tableViewSection(_ section: TVKSection, rowsWereAddedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereAddedAt: paths)
	}

	public func tableViewSection(_ section: TVKSection, rowsWereChangedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereChangedAt: paths)
	}

	public func tableViewSectionDidChange(_ section: TVKSection) {
		guard !section.isHidden else {
			return
		}
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsWereChangedAt: [index])
	}

	public func tableViewSection(
			_ section: TVKSection,
			performSegueWithIdentifier identifier: String,
			controller: TVKSegueController) {
		delegate.tableViewModel(self, performSegueWithIdentifier: identifier, controller: controller)
	}

	public func tableViewSection(
			_ tableViewSection: TVKSection,
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

	public func tableViewSection(_ section: TVKSection, didFailWith error: Error) {
		delegate.tableViewModel(self, section: section, didFailWith: error)
	}

	public func tableViewSection(
			_ section: TVKSection,
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
