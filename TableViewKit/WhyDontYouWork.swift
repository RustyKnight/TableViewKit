//
//  WhyDontYouWork.swift
//  TableViewKit
//
//  Created by Shane Whitehead on 2/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation

class SimpleState: Statful {
  var actualState: State = .show
  var desiredState: State = .show
  
  // Move desiredState to actualState
  func updateToDesiredState() {
    actualState = desiredState == .reload ? actualState : desiredState
  }
  
  let name: String
  
  init(name: String, actualState: State = .show, desiredState: State = .show) {
    self.name = name
    self.actualState = actualState
    self.desiredState = desiredState
  }
  
}

func test() {
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
  let operations = stateManager.applyDesiredState(basedOn: items)
  
  assert(operations[.delete]?.count == 0, "Expecting 0 deleted items")
  assert(operations[.insert]?.count == 0, "Expecting 0 insert items")
  assert(operations[.update]?.count == 2, "Expecting 2 update items")
  
  assert(operations[.insert]?.contains(where: { $0.identifier.hashValue == "Row 03".hashValue}) ??  false, "Expecting Row 03 to be updated")
  assert(operations[.insert]?.contains(where: { $0.identifier.hashValue == "Row 04".hashValue}) ??  false, "Expecting Row 04 to be update")
  
  
  assert(allItems["Row 03"]?.actualState == .show, "Expecting Row 03's state to be .show")
  assert(allItems["Row 04"]?.actualState == .show, "Expecting Row 04's state to be .show")

}
