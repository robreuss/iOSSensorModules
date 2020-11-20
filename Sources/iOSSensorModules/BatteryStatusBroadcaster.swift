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
        elementBatteryLevel = device.attachElement(Element(identifier: ElementIdentifier.batteryStatus.rawValue, displayName: "batteryStatus", proto: .tcp, dataType: .Float))
        elementBatteryStatusOn.handler = { element, device in
            
            if let batteryStatusOn = element.boolValue {
                
                if batteryStatusOn {
                    UIDevice.current.isBatteryMonitoringEnabled = true
                    NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
                    sendBatteryLevel(level: UIDevice.current.batteryLevel)
                } else {
                    UIDevice.current.isBatteryMonitoringEnabled = false
                    NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
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
        
        func batteryStateDidChange(notification: NSNotification){
            //let level = UIDevice.current.batteryLevel
            sendBatteryLevel(level: UIDevice.current.batteryLevel)
        }

        func batteryLevelDidChange(notification: NSNotification){

        }
    }
    
}

