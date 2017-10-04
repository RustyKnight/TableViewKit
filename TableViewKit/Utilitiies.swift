//
//  Utilitiies.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 5/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

public struct Utilities {

	public static func sort(_ items: [AnyHashable], byPreferredOrder preferredOrder: [AnyHashable]) -> [AnyHashable] {
		let sortedNames = items.sorted(by: {(lhs: AnyHashable, rhs: AnyHashable) -> Bool in
			// Then we can figure out the preferred index
			let lhsIndex = index(of: lhs, in: preferredOrder, where: { $0 == $1 })!
			let rhsIndex = index(of: rhs, in: preferredOrder, where: { $0 == $1 })!
			
			// And we can sort them
			return lhsIndex < rhsIndex
		})
		
		return sortedNames
	}

	internal static func index<T>(of value: T, `in` values: [T], `where` evaluator: Evaluator<T>) -> Int? {
		return values.index(where: { (entry: T) -> Bool in
			evaluator(value, entry)
		})
	}

}
