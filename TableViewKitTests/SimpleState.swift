//
//  SimpleState.swift
//  TableViewKitTests
//
//  Created by Shane Whitehead on 2/10/17.
//  Copyright © 2017 Beam Communications. All rights reserved.
//

import Foundation
import TableViewKit

class SimpleState: Stateful {
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
