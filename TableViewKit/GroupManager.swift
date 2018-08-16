//
//  GroupManager.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 23/1/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import Foundation

/**
There is a concept of "active" or "visible" and "configured" items through out the
API. Rather then trying to expose functionality for both at a class level, instead
we expose a "manager" for that "group", this means that the model and section
only needs to provide impementations for both the "active" and "configured" groups
which is then provided in a common form
*/
public protocol GroupManager {
	associatedtype Item
	
	var count: Int { get }
	var identifiers: [AnyHashable] { get }

	func item(at: Int) -> Item
	func identifier(at: Int) -> AnyHashable
	func item(byIdentifier: AnyHashable) -> Item?
}

public class AnyGroupManager<I>: GroupManager {
	
	public typealias Item = I
	
	public var count: Int = 0
	
	public var identifiers: [AnyHashable] = []
	
	public func item(at index: Int) -> I {
		fatalError("Not yet implemented")
	}
	
	public func identifier(at index: Int) -> AnyHashable {
		return identifiers[index]
	}
	
	public func item(byIdentifier: AnyHashable) -> I? {
		fatalError("Not yet implemented")
	}
	
}

public class ProxyGroupManager<I>: AnyGroupManager<I> {
	
	var items: [AnyHashable: I]
	
	public override var count: Int {
		set {}
		get {
			return items.count
		}
	}
	
	public init(identifiers: [AnyHashable], items: [AnyHashable: I]) {
		self.items = items
		super.init()
		self.identifiers = identifiers
	}
	
	public override func item(at index: Int) -> I {
		let id = identifier(at: index)
		return items[id]!
	}
	
	public override func item(byIdentifier identifier: AnyHashable) -> I? {
		// It's possible that the list of items might contain more then
		// the identifiers wants to expose
		guard identifiers.contains(identifier) else {
			return nil
		}
		return items[identifier]
	}
	
}
