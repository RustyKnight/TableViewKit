//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

/// Represents a TableViewModel whose sections are dynamic and can change in real time
class DynamicTableViewModel<SectionIdentifier: Hashable>: DefaultTableViewModel {

	internal var hidableItemsManager: HidableItemsManager<AnyTableViewSection>!

	internal func prepareHidableItemsManagerWith(_ sections: [AnyTableViewSection], allSections: [AnyHashable: AnyTableViewSection], preferredOrder: [AnyHashable]) {
		hidableItemsManager = HidableItemsManager(activeItems: sections, allItems: allSections, preferredOrder: preferredOrder)
		updateContents()
	}

	internal func updateContents() {
		sections = updateContents(with: hidableItemsManager)
	}

	internal func updateContents(with manager: HidableItemsManager<AnyTableViewSection>) -> [AnyTableViewSection] {
		let sections = manager.update(wereRemoved: { indices, result in
			self.sectionsWereRemoved(from: indices, withSectionsAfter: result)
		}, wereAdded: { indices, result in
			self.sectionsWereAdded(at: indices, withSectionsAfter: result)
		})
		return sections
	}

	internal func sectionsWereAdded(at indices: [Int], withSectionsAfter result: [AnyTableViewSection]) {
		var oldSections: [TableViewSection] = sections.filter { section in indices.contains(index(of: section) ?? -1)}

		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereRemovedAt: indices)

		for section in oldSections {
			section.didBecomeInactive()
		}
	}

	internal func sectionsWereRemoved(from indices: [Int], withSectionsAfter result: [AnyTableViewSection]) {
		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereAddedAt: indices)
		for index in indices {
			self.sections[index].willBecomeActive()
		}
	}

	override public func tableViewSection(_ section: TableViewSection, rowsWereRemovedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereRemovedAt: rows)
	}

	override public func tableViewSection(_ section: TableViewSection, rowsWereAddedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereAddedAt: rows)
	}

	override public func tableViewSection(_ section: TableViewSection, rowsWereChangedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereChangedAt: rows)
	}

	public override func tableViewSectionDidChange(_ section: TableViewSection) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSectionDidChange(section)
	}

	func isActive(section: TableViewSection) -> Bool {
		return index(of: section, in: sections) != nil
	}

//	override internal func index(of section: TableViewSection) -> Int? {
//		return index(of: section, in: activeSections)
//	}
//
//	override internal func index(of section: TableViewSection, `in` sections: [TableViewSection]) -> Int? {
//		return sections.index(where: { (entry: TableViewSection) -> Bool in
//			section == entry
//		})
//	}
//
//	override internal func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
//		return values.index(where: { (entry: T) -> Bool in
//			evaluator(value, entry)
//		})
//	}
}
