//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public protocol TableViewModel {
	var delegate: TableViewModelDelegate? {get set}
	var sectionCount: Int {get}

	// The shared context is meant to allow sections to share information
	// between.  The actual value used is dependent on the implementation
	var sharedContext: [AnyHashable: Any] {get set}

	func section(at: Int) -> TableViewSection

	func didSelectRow(at path: IndexPath) -> Bool

	func willBecomeActive()
	func didBecomeInactive()
}

public protocol TableViewModelDelegate {

	func tableViewModel(_ model: TableViewModel, sectionsWereRemovedAt: [Int])
	func tableViewModel(_ model: TableViewModel, sectionsWereAddedAt: [Int])
	func tableViewModel(_ model: TableViewModel, sectionsWereChangedAt sections: [Int])

	func tableViewModel(_ model: TableViewModel, rowsWereAddedAt: [IndexPath])
	func tableViewModel(_ model: TableViewModel, rowsWereRemovedAt: [IndexPath])
	func tableViewModel(_ model: TableViewModel, rowsWereChangedAt: [IndexPath])

	func tableViewModel(_ model: TableViewModel, section: TableViewSection, didFailWith: Error)

	func performSegue(withIdentifier: String, controller: TableViewSegueController)

	func presentActionSheet(section: Int, row: Int, title: String?, message: String?, actions: [UIAlertAction])

	func tableViewModel(_ model: TableViewModel, sectionsDidStartLoading: [Int])
	func tableViewModel(_ model: TableViewModel, sectionsDidCompleteLoading: [Int])
}

public class DefaultTableViewModel: TableViewModel, TableViewSectionDelegate {

	public var sharedContext: [AnyHashable: Any] = [:]

	internal var sections: [TableViewSection] = []

	public var delegate: TableViewModelDelegate?
	public var sectionCount: Int { return sections.count }

	public func section(at: Int) -> TableViewSection {
		return sections[at]
	}

	public func didSelectRow(at path: IndexPath) -> Bool {
		let section = self.section(at: path.section)
		return section.didSelectRow(at: path)
	}

//	func add(section: TableViewSection) {
//		section.delegate = self
//		sections.append(section)
//		guard let delegate = delegate else {
//			return
//		}
//		guard let index = index(of: section) else {
//			return
//		}
//		delegate.tableViewModel(self, didAddSections: [index])
//	}

	public func setContext(`for` key: AnyHashable, to value: Any?) {
		sharedContext[key] = value

		for section in sections {
			section.sharedContext(for: key, didChangeTo: value)
		}
	}

	public func context(`for` key: AnyHashable) -> Any? {
		return sharedContext[key]
	}

	func index(of section: TableViewSection) -> Int? {
		return index(of: section, in: sections)
	}

	func index(of section: TableViewSection, `in` sections: [TableViewSection]) -> Int? {
		return sections.index(where: { (entry: TableViewSection) -> Bool in
			section == entry
		})
	}

	public func didStartLoading(section: TableViewSection) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidStartLoading: [index])
	}


	public func didCompleteLoading(section: TableViewSection) {
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsDidCompleteLoading: [index])
	}

	internal func indexPaths(forRows rows: [Int], from section: TableViewSection) -> [IndexPath]? {
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

//	func tableViewModel(_ model: TableViewModel, rowsWereRemovedAt: [IndexPath]) {}

	public func tableViewSection(_ section: TableViewSection, rowsWereRemovedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let delegate = delegate else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereRemovedAt: paths)
	}

	public func tableViewSection(_ section: TableViewSection, rowsWereAddedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let delegate = delegate else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereAddedAt: paths)
	}

	public func tableViewSection(_ section: TableViewSection, rowsWereChangedAt rows: [Int]) {
		guard !section.isHidden else {
			return
		}
		guard let delegate = delegate else {
			return
		}
		guard let paths = indexPaths(forRows: rows, from: section) else {
			return
		}
		delegate.tableViewModel(self, rowsWereChangedAt: paths)
	}

	public func sectionDidChange(_ section: TableViewSection) {
		guard !section.isHidden else {
			return
		}
		guard let delegate = delegate else {
			return
		}
		guard let index = index(of: section) else {
			return
		}
		delegate.tableViewModel(self, sectionsWereChangedAt: [index])
	}

	public func performSegue(withIdentifier identifier: String, controller: TableViewSegueController) {
		delegate?.performSegue(withIdentifier: identifier, controller: controller)
	}

	public func presentActionSheet(`for` tableViewSection: TableViewSection, row: Int, title: String?, message: String?, actions: [UIAlertAction]) {
		guard let sectionIndex = index(of: tableViewSection) else {
			return
		}
		delegate?.presentActionSheet(section: sectionIndex, row: row, title: title, message: message, actions: actions)
	}

	public func section(_ section: TableViewSection, didFailWith error: Error) {
		guard let delegate = delegate else {
			return
		}
		delegate.tableViewModel(self, section: section, didFailWith: error)
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
