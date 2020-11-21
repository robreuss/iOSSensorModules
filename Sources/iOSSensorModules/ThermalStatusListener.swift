//
//  ThermalStatusListener.swift
//
//
//  Created by Rob Reuss on 11/19/20.
//

import Foundation
import ElementalController

public class ThermalStatusListener {
    
    var device: ServerDevice
    var elementThermalStatusOn: Element?
    var errorManager: ErrorManager
    
    public typealias ThermalLevelHandler = ((Float) -> Void)?
    public var receivedThermalLevelData: ThermalLevelHandler?
    
    public typealias ThermalStateHandler = ((Int8) -> Void)?
    public var receivedThermalStateData: ThermalStateHandler?
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        elementThermalStatusOn = device.attachElement(Element(identifier: ElementIdentifier.thermalStatusOn.rawValue, displayName: "ThermalStatusOn", proto: .tcp, dataType: .Bool))
        let elementThermalState = device.attachElement(Element(identifier: ElementIdentifier.thermalState.rawValue, displayName: "ThermalState", proto: .tcp, dataType: .Int8))
        
        elementThermalState.handler = { element, device in
            do {
                if let v = element.int8Value {
                    if let handler = self.receivedThermalStateData {
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
    
    func toggleThermalStatusUpdates(enabled: Bool) {
        if let e = elementThermalStatusOn {
            do {
                e.boolValue = enabled
                try self.device.send(element: e)
                }
            catch {
                errorManager.sendError(message: "Sending element \(e.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func startThermalStatusUpdates() {
        toggleThermalStatusUpdates(enabled: true)
    }
    
    public func stopThermalStatusUpdates() {
        toggleThermalStatusUpdates(enabled: false)
    }
    
}
