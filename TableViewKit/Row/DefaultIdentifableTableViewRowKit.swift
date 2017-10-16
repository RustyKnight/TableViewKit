//
//  DefaultIdentifableTableViewRowKit.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 1/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

open class DefaultIdentifiableTableViewKitRow<Identifer: CellIdentifiable>: AnyTableViewKitRow {
	
	public let cellIdentifier: CellIdentifiable
	
	public init(cellIdentifier: CellIdentifiable, delegate: TableViewKitRowDelegate) {
		self.cellIdentifier = cellIdentifier
		super.init(delegate: delegate)
	}
	
	open override func cell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = delegate.cell(withIdentifier: cellIdentifier, at: indexPath)
		configure(cell)
		return cell
	}
	
	open func configure(_ cell: UITableViewCell) {
		fatalError("Not yet implemented")
	}
	
}
