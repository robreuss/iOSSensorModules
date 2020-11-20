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
    
    public typealias BatteryStatusHandler = ((BatteryStatusData) -> Void)?
    public var receivedBatteryStatusData: BatteryStatusHandler?
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        elementBatteryStatusOn = device.attachElement(Element(identifier: ElementIdentifier.batteryStatusOn.rawValue, displayName: "batteryStatusOn", proto: .tcp, dataType: .Bool))
        let elementBatteryLevel = device.attachElement(Element(identifier: ElementIdentifier.batteryStatus.rawValue, displayName: "batteryStatus", proto: .tcp, dataType: .Float))
        
        elementBatteryLevel.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    if let handler = self.receivedBatteryStatusData {
                        let batteryStatusData = try jsonDecoder.decode(BatteryStatusData.self, from: v)
                        handler!(batteryStatusData)
                        
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
