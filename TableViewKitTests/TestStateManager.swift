//
//  TestStateManager.swift
//  TableViewKitTests
//
//  Created by Shane Whitehead on 2/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import XCTest
@testable import TableViewKit
import LogWrapperKit

class TestStateManager: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
	
	func testEnumIdentifier() {
		enum RowIdentifier: String {
			case row1
			case row2
			case row3
			case row4
			case row5
		}
		let allItems: [RowIdentifier: SimpleState] = [
			.row5: SimpleState(name: "Row 05"),
			.row4: SimpleState(name: "Row 04"),
			.row3: SimpleState(name: "Row 03"),
			.row2: SimpleState(name: "Row 02"),
			.row1: SimpleState(name: "Row 01"),
			]
		let preferredOrder: [RowIdentifier] = [
			.row1,
			.row2,
			.row3,
			.row4,
			.row5,
			]
		let items: [RowIdentifier] = [
			.row1,
			.row2,
			.row5
			]
		let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
		let operations = stateManager.operationsForDesiredState(basedOn: items)
		
		let insert = operations.insert
		for op in insert {
			//log(debug: op.identifier)
			allItems[op.identifier]
			guard let id = op.identifier as? RowIdentifier else {
				XCTFail("Could not convert Operation Identifier to RowIdentifier")
				return
			}
			//log(debug: id)
		}
	}

  func testThatStateManagerDoesNotChange() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04"),
      "Row 03": SimpleState(name: "Row 03"),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.update.count == 0, "Expecting 0 update items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
  }
  
  func testThatStateManagerCanDeleteWithActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .hide),
      "Row 03": SimpleState(name: "Row 03", desiredState: .hide),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 2, "Expecting 2 deleted items")

    assert(operations.delete.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be removed")
    assert(operations.delete.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be removed")
    
    assert(operations.update.count == 0, "Expecting 0 update items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
  }
  
  func testThatStateManagerCanDeleteWithoutActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .hide),
      "Row 03": SimpleState(name: "Row 03", desiredState: .hide),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
//      "Row 03",
//      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.update.count == 0, "Expecting 0 update items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
  }
  
  func testThatStateManagerCanDeleteWithMixedActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .hide),
      "Row 03": SimpleState(name: "Row 03", desiredState: .hide),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
//      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 1, "Expecting 1 deleted items")
    
    assert(!(operations.delete.contains(where: { $0.identifier.hashValue == "Row 03".hashValue})), "Not expecting Row 03 to be removed")
    assert(operations.delete.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be removed")
    
    assert(operations.update.count == 0, "Expecting 0 update items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
  }

  func testThatStateManagerCanInsertWithoutActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", actualState: .hide, desiredState: .show),
      "Row 03": SimpleState(name: "Row 03", actualState: .hide, desiredState: .show),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
//      "Row 03",
//      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.update.count == 0, "Expecting 0 update items")
    //log(debug: "toInsert = \(operations.insert.count)")
    assert(operations.insert.count == 2, "Expecting 2 insert items")
    
    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be inserted")
    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be inserted")
    
  }
  
  func testThatStateManagerCanInsertWithActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", actualState: .hide, desiredState: .show),
      "Row 03": SimpleState(name: "Row 03", actualState: .hide, desiredState: .show),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.update.count == 0, "Expecting 0 update items")
    //log(debug: "toInsert = \(operations.insert.count)")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
    
//    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be inserted")
//    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be inserted")
    
  }
  
  func testThatStateManagerCanInsertWithMixedActiveItems() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", actualState: .hide, desiredState: .show),
      "Row 03": SimpleState(name: "Row 03", actualState: .hide, desiredState: .show),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
//      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.update.count == 0, "Expecting 0 update items")
    //log(debug: "toInsert = \(operations.insert.count)")
    assert(operations.insert.count == 1, "Expecting 1 insert items")
    
    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be inserted")
    assert(!(operations.insert.contains(where: { $0.identifier.hashValue == "Row 04".hashValue})), "Not expecting Row 04 to be inserted")
    
  }

  func testThatStateManagerCanReloadWithActiveItem() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .reload),
      "Row 03": SimpleState(name: "Row 03", desiredState: .reload),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
    assert(operations.update.count == 2, "Expecting 2 update items")

    assert(operations.update.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be updated")
    assert(operations.update.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be updated")
    
    assert(allItems["Row 03"]?.actualState == .show, "Expecting Row 03's state to be .show")
    assert(allItems["Row 04"]?.actualState == .show, "Expecting Row 04's state to be .show")
  }
  
  func testThatStateManagerCanReloadWithoutActiveItem() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .reload),
      "Row 03": SimpleState(name: "Row 03", desiredState: .reload),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
//      "Row 03",
//      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.insert.count == 0, "Expecting 0 insert items")
    assert(operations.update.count == 0, "Expecting 0 update items")
  }
  
  func testThatStateManagerCanReloadWithMixedItem() {
    let allItems: [AnyHashable: SimpleState] = [
      "Row 05": SimpleState(name: "Row 05"),
      "Row 04": SimpleState(name: "Row 04", desiredState: .reload),
      "Row 03": SimpleState(name: "Row 03", desiredState: .reload),
      "Row 02": SimpleState(name: "Row 02"),
      "Row 01": SimpleState(name: "Row 01"),
      ]
    let preferredOrder: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
      "Row 04",
      "Row 05",
      ]
    let items: [AnyHashable] = [
      "Row 01",
      "Row 02",
      "Row 03",
//      "Row 04",
      "Row 05",
      ]
    
    let stateManager = StateManager(allItems: allItems, preferredOrder: preferredOrder)
    //    func applyDesiredState(basedOn activeItems: [AnyHashable]) -> [Operation: [OperationTarget]] {
    let operations = stateManager.operationsForDesiredState(basedOn: items)
    
    //log(debug: operations.update)
    
    assert(operations.delete.count == 0, "Expecting 0 deleted items")
    assert(operations.insert.count == 1, "Expecting 1 insert items")
    assert(operations.update.count == 2, "Expecting 2 update items")
    
    assert(operations.update.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}), "Expecting Row 03 to be updated")
    assert(operations.update.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be updated")
    assert(operations.insert.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}), "Expecting Row 04 to be inserted")

    assert(allItems["Row 03"]?.actualState == .show, "Expecting Row 03's state to be .show")
    assert(allItems["Row 04"]?.actualState == .show, "Expecting Row 04's state to be .show")
  }
}
