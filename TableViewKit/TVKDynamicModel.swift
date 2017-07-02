//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

/// Represents a TableViewModel whose sections are dynamic and can change in real time
public class TVKDynamicModel<SectionIdentifier: Hashable>: TVKDefaultModel {

	internal var hidableItemsManager: HidableItemsManager<TVKAnySection>!

	internal func prepareHidableItemsManagerWith(_ sections: [TVKAnySection], allSections: [AnyHashable: TVKAnySection], preferredOrder: [AnyHashable]) {
		hidableItemsManager = HidableItemsManager(activeItems: sections, allItems: allSections, preferredOrder: preferredOrder)
		updateContents()
	}

	internal func updateContents() {
		sections = updateContents(with: hidableItemsManager)
	}

	internal func updateContents(with manager: HidableItemsManager<TVKAnySection>) -> [TVKAnySection] {
		let sections = manager.update(wereRemoved: { indices, result in
			self.sectionsWereRemoved(from: indices, withSectionsAfter: result)
		}, wereAdded: { indices, result in
			self.sectionsWereAdded(at: indices, withSectionsAfter: result)
		})
		return sections
	}

	internal func sectionsWereAdded(at indices: [Int], withSectionsAfter result: [TVKAnySection]) {
		var oldSections: [TVKSection] = sections.filter { section in indices.contains(index(of: section) ?? -1)}

		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereRemovedAt: indices)

		for section in oldSections {
			section.didBecomeInactive()
		}
	}

	internal func sectionsWereRemoved(from indices: [Int], withSectionsAfter result: [TVKAnySection]) {
		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereAddedAt: indices)
		for index in indices {
			self.sections[index].willBecomeActive()
		}
	}

	override public func tableViewSection(_ section: TVKSection, rowsWereRemovedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereRemovedAt: rows)
	}

	override public func tableViewSection(_ section: TVKSection, rowsWereAddedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereAddedAt: rows)
	}

	override public func tableViewSection(_ section: TVKSection, rowsWereChangedAt rows: [Int]) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSection(section, rowsWereChangedAt: rows)
	}

	public override func tableViewSectionDidChange(_ section: TVKSection) {
		guard isActive(section: section) else {
			guard !section.isHidden else {
				return
			}
			updateContents()
			return
		}
		super.tableViewSectionDidChange(section)
	}

	func isActive(section: TVKSection) -> Bool {
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
