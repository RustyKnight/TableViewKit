//
// Created by Shane Whitehead on 12/12/2016.
// Copyright (c) 2016 Beam Communications. All rights reserved.
//

import Foundation

public class DynamicTableViewSection: DefaultTableViewSection {

	internal var hidableItemsManager: HidableItemsManager<AnyTableViewRow>!

	internal func prepareHidableItemsManagerWith(_ rows: [AnyTableViewRow], allRows: [AnyHashable: AnyTableViewRow], preferredOrder: [AnyHashable]) {
		hidableItemsManager = HidableItemsManager(activeItems: rows, allItems: allRows, preferredOrder: preferredOrder)
		updateContents()
	}
	
	internal func updateContents() {
		rows = updateContents(with: hidableItemsManager)
	}
	
	internal func updateContents(with manager: HidableItemsManager<AnyTableViewRow>) -> [AnyTableViewRow] {
		let rows = manager.update(wereRemoved: { indices, result in
			self.rowsWereRemoved(from: indices, withRowsAfter: result)
		}, wereAdded: { indices, result in
			self.rowsWereAdded(at: indices, withRowsAfter: result)
		})
		return rows
	}
	
	internal func rowsWereRemoved(from indices: [Int], withRowsAfter result: [AnyTableViewRow]) {
		// Want a reference to the rows which are going to be removed, so we can
		// deactivate them, but only AFTER we notify the delegate, as the deactivation
		// might cause updates to be triggered
		var oldRows: [AnyTableViewRow] = rows.filter { row in indices.contains(index(of: row) ?? -1) }
		
		self.rows = result
		self.delegate?.tableViewSection(self, rowsWereRemovedAt: indices)
		
		for row in oldRows {
			row.didBecomeInactive(self)
		}
	}
	
	internal func rowsWereAdded(at indices: [Int], withRowsAfter result: [AnyTableViewRow]) {
		self.rows = result
		self.delegate?.tableViewSection(self, rowsWereAddedAt: indices)
		for index in indices {
			self.rows[index].willBecomeActive(self)
		}
	}
	
	override public func willBecomeActive() {
		for row in rows {
			guard !row.isHidden else {
				continue
			}
			row.willBecomeActive(self)
		}
	}
	
	override public func didBecomeInactive() {
		for row in rows {
			guard !row.isHidden else {
				continue
			}
			row.didBecomeInactive(self)
		}
	}
	
	
}