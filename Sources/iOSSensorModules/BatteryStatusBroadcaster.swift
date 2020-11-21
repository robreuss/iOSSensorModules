//
//  BatteryStatusBroadcaster.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 11/19/2020.
//  Copyright © 2020 Rob Reuss. All rights reserved.
//

import Foundation
import ElementalController
import UIKit

public class BatteryStatusBroadcaster {
    
    var device: ClientDevice
    let errorManager: ErrorManager
    var handlersAdded = false
    var elementBatteryLevel: Element?
    var elementBatteryState: Element?
    
    public func stopBatteryStatusUpdates() {
        logDebug("Stopping battery status updates")
    }
    
    public init(device: ClientDevice)  {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        errorManager.sendError(message: "This is an error message")
        
        addHandlers()
        
    }
    
    func addHandlers() {
        
        handlersAdded = true
        
        let elementBatteryStatusOn = device.attachElement(Element(identifier: ElementIdentifier.batteryStatusOn.rawValue, displayName: "batteryStatusOn", proto: .tcp, dataType: .Bool))
        elementBatteryLevel = device.attachElement(Element(identifier: ElementIdentifier.batteryLevel.rawValue, displayName: "batteryLevel", proto: .tcp, dataType: .Float))
        elementBatteryState = device.attachElement(Element(identifier: ElementIdentifier.batteryState.rawValue, displayName: "batteryState", proto: .tcp, dataType: .Int8))
        
        elementBatteryStatusOn.handler = { element, device in
            
            if let batteryStatusOn = element.boolValue {
                
                if batteryStatusOn {
                    UIDevice.current.isBatteryMonitoringEnabled = true
                    NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
                    sendBatteryLevel(level: UIDevice.current.batteryLevel)
                    NotificationCenter.default.addObserver(self, selector: Selector(("batteryStateDidChange:")), name: UIDevice.batteryStateDidChangeNotification, object: nil)
                } else {
                    UIDevice.current.isBatteryMonitoringEnabled = false
                    NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
                }
            } else {
                // TODO: Error
            }
        }
        
        func sendBatteryLevel(level: Float) {
            elementBatteryLevel?.floatValue = level
            if let e = elementBatteryLevel {
                do {
                    try self.device.send(element: e)
                }
                catch {
                    errorManager.sendError(message: "Sending element \(e.displayName) resulted in error: \(error)")
                }
            }
        }
        
        func sendBatteryState(state: Int8) {
            elementBatteryState?.int8Value = state
            if let e = elementBatteryState {
                do {
                    try self.device.send(element: e)
                }
                catch {
                    errorManager.sendError(message: "Sending element \(e.displayName) resulted in error: \(error)")
                }
            }
        }
        
        func batteryStateDidChange(notification: NSNotification){
            sendBatteryState(state: Int8(UIDevice.current.batteryState.rawValue))
        }

        func batteryLevelDidChange(notification: NSNotification){
            sendBatteryLevel(level: UIDevice.current.batteryLevel)
        }
    }
    
}

