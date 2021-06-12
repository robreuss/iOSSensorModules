//
//  BatteryStatusListener.swift
//  
//
//  Created by Rob Reuss on 11/19/20.
//

import Foundation
import ElementalController

public class BatteryStatusListener {
    
    var device: ServerDevice
    var elementBatteryStatusOn: Element?
    var errorManager: ErrorManager
    
    public typealias BatteryLevelHandler = ((Float) -> Void)?
    public var receivedBatteryLevelData: BatteryLevelHandler?
    
    public typealias BatteryStateHandler = ((Int8) -> Void)?
    public var receivedBatteryStateData: BatteryStateHandler?
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        elementBatteryStatusOn = device.attachElement(Element(identifier: ElementIdentifier.batteryStatusOn.rawValue, displayName: "batteryStatusOn", proto: .tcp, dataType: .Bool))
        let elementBatteryLevel = device.attachElement(Element(identifier: ElementIdentifier.batteryLevel.rawValue, displayName: "batteryLevel", proto: .tcp, dataType: .Float))
        let elementBatteryState = device.attachElement(Element(identifier: ElementIdentifier.batteryState.rawValue, displayName: "batteryState", proto: .tcp, dataType: .Int8))
        
        print("Battery sensor listener eid: \(ElementIdentifier.batteryLevel.rawValue)")
        
        elementBatteryLevel.handler = { element, device in
            do {
                if let v = element.floatValue {
                    if let handler = self.receivedBatteryLevelData {
                        handler!(v)
                    }
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(element.displayName): \(error)")
            }
        }
        
        elementBatteryState.handler = { element, device in
            do {
                if let v = element.int8Value {
                    if let handler = self.receivedBatteryStateData {
                        handler!(v)
                    }
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(element.displayName): \(error)")
            }
        }
        
    }
    
    func toggleBatteryStatusUpdates(enabled: Bool) {
        if let e = elementBatteryStatusOn {
            do {
                e.boolValue = enabled
                try self.device.send(element: e)
                }
            catch {
                errorManager.sendError(message: "Sending element \(e.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func startBatteryStatusUpdates() {
        toggleBatteryStatusUpdates(enabled: true)
    }
    
    public func stopBatteryStatusUpdates() {
        toggleBatteryStatusUpdates(enabled: false)
    }
    
}
