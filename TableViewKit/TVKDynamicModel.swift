
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

///// Represents a TableViewModel whose sections are dynamic and can change in real time
//open class TVKDynamicModel<SectionIdentifier: Hashable>: DefaultTableViewKitModel {
//
//	public var allSections: [SectionIdentifier: TVKAnySection] = [:]
//	public var preferredSectionOrder: [SectionIdentifier] = []
//	
//	public override init(delegate: TableViewKitModelDelegate) {
//		super.init(delegate: delegate)
//		commonInit()
//	}
//	
//	open func commonInit() {
////		prepareHidableItemsManager()
//	}
//
////	public func prepareHidableItemsManager() {
////		hidableItemsManager = StatfulManager(
////				activeItems: sections,
////				allItems: allSections,
////				preferredOrder: preferredSectionOrder)
////	}
////
////	public func updateContents() {
////		sections = updateContents(with: hidableItemsManager)
////	}
//
////	internal func updateContents(with manager: StatfulManager<TVKAnySection>) -> [TVKAnySection] {
////		let sections = manager.update(wereRemoved: { indices, result in
////			self.sectionsWereRemoved(from: indices, withSectionsAfter: result)
////		}, wereAdded: { indices, result in
////			self.sectionsWereAdded(at: indices, withSectionsAfter: result)
////		})
////		return sections
////	}
////
////	internal func sectionsWereAdded(at indices: [Int], withSectionsAfter result: [TVKAnySection]) {
////		let oldSections: [TableViewKitSection] = sections.filter { section in
////			indices.contains(index(of: section) ?? -1)
////		}
////
////		for section in oldSections {
////			section.willBecomeActive()
////		}
////
////		self.sections = result
////		self.delegate.tableViewModel(self, sectionsWereAddedAt: indices)
////	}
//
////	internal func sectionsWereRemoved(from indices: [Int], withSectionsAfter result: [TVKAnySection]) {
////		self.sections = result
////		self.delegate.tableViewModel(self, sectionsWereRemovedAt: indices)
////		for index in indices {
////			self.sections[index].didBecomeInactive()
////		}
////	}
////
////	override public func tableViewSection(_ section: TableViewKitSection, rowsWereRemovedAt rows: [Int]) {
////		guard isActive(section: section) else {
////			guard !section.isHidden else {
////				return
////			}
//////			updateContents()
////			return
////		}
////		super.tableViewSection(section, rowsWereRemovedAt: rows)
////	}
////
////	override public func tableViewSection(_ section: TableViewKitSection, rowsWereAddedAt rows: [Int]) {
////		guard isActive(section: section) else {
////			guard !section.isHidden else {
////				return
////			}
//////			updateContents()
////			return
////		}
////		super.tableViewSection(section, rowsWereAddedAt: rows)
////	}
////
////	override public func tableViewSection(_ section: TableViewKitSection, rowsWereChangedAt rows: [Int]) {
////		guard isActive(section: section) else {
////			guard !section.isHidden else {
////				return
////			}
//////			updateContents()
////			return
////		}
////		super.tableViewSection(section, rowsWereChangedAt: rows)
////	}
////
////	public override func tableViewSectionDidChange(_ section: TableViewKitSection) {
////		guard isActive(section: section) else {
////			guard !section.isHidden else {
////				return
////			}
//////			updateContents()
////			return
////		}
////		super.tableViewSectionDidChange(section)
////	}
////
////	func isActive(section: TableViewKitSection) -> Bool {
////		return index(of: section, in: sections) != nil
////	}
//
//}

