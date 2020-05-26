//
//  OpenXCClasses.swift
//  openxc-ios-framework
//
//  Created by Tim Buick on 2016-08-10.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//  Version 0.9.2
//

import Foundation


public struct OpenXCConstants {
  static let C5_VI_NAME_PREFIX = "OPENXC-VI-"
  static let C5_OPENXC_BLE_SERVICE_UUID = "6800D38B-423D-4BDB-BA05-C9276D8453E1"
  static let C5_OPENXC_BLE_CHARACTERISTIC_NOTIFY_UUID = "6800D38B-5262-11E5-885D-FEFF819CDCE3"
  static let C5_OPENXC_BLE_CHARACTERISTIC_WRITE_UUID = "6800D38B-5262-11E5-885D-FEFF819CDCE2"
}


public enum VehicleMessageType: NSString {
  case measurementResponse
  case commandRequest
  case commandResponse
  case diagnosticRequest
  case diagnosticResponse
  case canResponse
  case canRequest
}


open class VehicleBaseMessage {
  open var timeStamp: NSInteger = 0
  open var type: VehicleMessageType = .measurementResponse
  func traceOutput() -> NSString {
    return "{}"
  }
}


