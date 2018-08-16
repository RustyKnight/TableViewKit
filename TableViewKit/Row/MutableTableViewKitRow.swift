//
//  MutableTableViewKitRow.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 28/2/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

public protocol MutableTableViewKitRow: TableViewKitRow {
	func delete()
	// Determines if the row can actually be deleted or not
	var isDeletable: Bool { get }
}
