//
//  ThermalStatusBroadcaster.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 11/19/2020.
//  Copyright © 2020 Rob Reuss. All rights reserved.
//

import Foundation
import ElementalController
import UIKit

public class ThermalStatusBroadcaster {
    
    var device: ClientDevice
    let errorManager: ErrorManager
    var handlersAdded = false
    var elementThermalState: Element?
    var thermalStatusOn: Bool = true
    
    public func stopThermalStatusUpdates() {
        logDebug("Stopping thermal status updates")
    }
    
    public init(device: ClientDevice)  {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        errorManager.sendError(message: "This is an error message")
        
        addHandlers()
        
    }
    
    @objc
    func thermalStateChanged(notification: NSNotification) {
        print("Got thermal state change in ThermalStatusBroadcaster")
        if let processInfo = notification.object as? ProcessInfo {
            if self.thermalStatusOn { self.sendThermalState(state: Int8(UIDevice.current.batteryState.rawValue)) }
        }
    }

    func addHandlers() {
        
        handlersAdded = true
        
        let elementThermalStatusOn = device.attachElement(Element(identifier: ElementIdentifier.thermalStatusOn.rawValue, displayName: "thermalStatusOn", proto: .tcp, dataType: .Bool))
        elementThermalState = device.attachElement(Element(identifier: ElementIdentifier.thermalState.rawValue, displayName: "thermalState", proto: .tcp, dataType: .Int8))
        
        elementThermalStatusOn.handler = { element, device in

            if let thermalStatusOn = element.boolValue {
                
                self.thermalStatusOn = thermalStatusOn
                
                if thermalStatusOn {
                    
                    self.sendThermalState(state: Int8(ProcessInfo.processInfo.thermalState.rawValue))
                    
                }
            } else {
                // TODO: Error
            }
        }
        
    }
    
    func sendThermalState(state: Int8) {
        print("Attempting to send thermal state")
        elementThermalState?.int8Value = state
        if let e = elementThermalState {
            do {
                try self.device.send(element: e)
            }
            catch {
                errorManager.sendError(message: "Sending element \(e.displayName) resulted in error: \(error)")
            }
        }
    }

    
}

