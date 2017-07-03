//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

/// Represents a TableViewModel whose sections are dynamic and can change in real time
open class TVKDynamicModel<SectionIdentifier: Hashable>: TVKDefaultModel {

	internal var hidableItemsManager: HidableItemsManager<TVKAnySection>!

	public var allSections: [SectionIdentifier: TVKAnySection] = [:]
	public var preferredSectionOrder: [SectionIdentifier] = []
	
	public override init() {
		super.init()
		commonInit()
	}
	
	open func commonInit() {
		prepareHidableItemsManager()
	}

	public func prepareHidableItemsManager() {
		hidableItemsManager = HidableItemsManager(
				activeItems: sections,
				allItems: allSections,
				preferredOrder: preferredSectionOrder)
		updateContents()
	}

	public func updateContents() {
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
		let oldSections: [TVKSection] = sections.filter { section in
			indices.contains(index(of: section) ?? -1)
		}

		for section in oldSections {
			section.willBecomeActive()
		}

		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereAddedAt: indices)
	}

	internal func sectionsWereRemoved(from indices: [Int], withSectionsAfter result: [TVKAnySection]) {
		self.sections = result
		self.delegate?.tableViewModel(self, sectionsWereRemovedAt: indices)
		for index in indices {
			self.sections[index].didBecomeInactive()
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

}
