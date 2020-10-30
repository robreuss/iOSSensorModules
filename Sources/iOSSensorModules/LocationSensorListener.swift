//
//  LocationSensorListener.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/14/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import ElementalController

public class LocationSensorListener {
    
    var device: ServerDevice
    var errorManager: ErrorManager
    
    public typealias LocationDataHandler = ((LocationData) -> Void)?
    public var receivedLocationData: LocationDataHandler?
    
    public typealias HeadingDataHandler = ((HeadingData) -> Void)?
    public var receivedHeadingData: HeadingDataHandler?
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        let _ = device.attachElement(Element(identifier: ElementIdentifier.standardLocationServiceOn.rawValue, displayName: "standardLocationServiceOn", proto: .tcp, dataType: .Bool))
        let _ = device.attachElement(Element(identifier: ElementIdentifier.headingOn.rawValue, displayName: "headingOn", proto: .tcp, dataType: .Bool))
        let elementLocationData = device.attachElement(Element(identifier: ElementIdentifier.locationData.rawValue, displayName: "locationData", proto: .tcp, dataType: .Data))
        let elementHeadingData = device.attachElement(Element(identifier: ElementIdentifier.headingData.rawValue, displayName: "headingData", proto: .tcp, dataType: .Data))
        
        elementLocationData.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let locationData = try jsonDecoder.decode(LocationData.self, from: v)
                    if let handler = self.receivedLocationData {
                        
                        handler!(locationData)
                        
                    }
                    
                } else {
                    // TODO: Error
                }
            }
            catch {
                print("Got error: \(error)") // TODO: Error
            }
            
        }
        
        elementHeadingData.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let headerData = try jsonDecoder.decode(HeadingData.self, from: v)
                    if let handler = self.receivedHeadingData {
                        
                        handler!(headerData)
                        
                    }
                    
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementHeadingData.displayName): \(error)")
            }
            
        }
        
    }
    
    public func turnHeadingOn() {
        if let elementHeadingOn = self.device.getElementWith(identifier: ElementIdentifier.headingOn.rawValue) {
            elementHeadingOn.boolValue = true // Setting interval to zero turns DM updates off
            do {
                try device.send(element: elementHeadingOn)
            }
            catch {
                self.errorManager.sendError(message: "Sending element \(elementHeadingOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func turnStandardLocationServiceOn() {
        if let elementStandardLocationServiceOn = self.device.getElementWith(identifier: ElementIdentifier.standardLocationServiceOn.rawValue) {
            elementStandardLocationServiceOn.boolValue = true // Setting interval to zero turns DM updates off
            do {
                try device.send(element: elementStandardLocationServiceOn)
            }
            catch {
                self.errorManager.sendError(message: "Sending element \(elementStandardLocationServiceOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
}
