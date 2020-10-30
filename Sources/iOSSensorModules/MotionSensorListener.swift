//
//  MotionSensorListener.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/14/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import ElementalController

public class MotionSensorListener {
    
    var device: ServerDevice
    var errorManager: ErrorManager
    
    public typealias DeviceMotionHandler = ((DeviceMotionData) -> Void)?
    public var receivedDeviceMotionData: DeviceMotionHandler?
    
    public typealias GyroHandler = ((GyroData) -> Void)?
    public var receivedGyroData: GyroHandler?
    
    public typealias AccelerometerHandler = ((AccelerometerData) -> Void)?
    public var receivedAccelerometerData: AccelerometerHandler?
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        let _ = device.attachElement(Element(identifier: ElementIdentifier.deviceMotionOn.rawValue, displayName: "deviceMotionOn", proto: .tcp, dataType: .Double))
        let elementDeviceMotionData = device.attachElement(Element(identifier: ElementIdentifier.deviceMotionData.rawValue, displayName: "deviceMotionData", proto: .tcp, dataType: .Data))
        elementDeviceMotionData.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let deviceMotionData = try jsonDecoder.decode(DeviceMotionData.self, from: v)
                    if let handler = self.receivedDeviceMotionData {
                        
                        handler!(deviceMotionData)
                        
                    }
                    
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementDeviceMotionData.displayName): \(error)")
            }
        }
        
        let _ = device.attachElement(Element(identifier: ElementIdentifier.gyroOn.rawValue, displayName: "gyroOn", proto: .tcp, dataType: .Double))
        let elementGyroData = device.attachElement(Element(identifier: ElementIdentifier.gyroData.rawValue, displayName: "gyroData", proto: .tcp, dataType: .Data))
        elementGyroData.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let gyroData = try jsonDecoder.decode(GyroData.self, from: v)
                    if let handler = self.receivedGyroData {
                        
                        handler!(gyroData)
                        
                    }
                    
                } else {
                    self.errorManager.sendError(message: "Nil value on element \(elementGyroData.displayName)")
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementGyroData.displayName): \(error)")

            }
        }
        
        let _ = device.attachElement(Element(identifier: ElementIdentifier.accelerometerOn.rawValue, displayName: "accelerometerOn", proto: .tcp, dataType: .Double))
        let elementAccelerometerData = device.attachElement(Element(identifier: ElementIdentifier.accelerometerData.rawValue, displayName: "accelerometerData", proto: .tcp, dataType: .Data))
        elementAccelerometerData.handler = { element, device in
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let accelerometerData = try jsonDecoder.decode(AccelerometerData.self, from: v)
                    if let handler = self.receivedAccelerometerData {
                        
                        handler!(accelerometerData)
                        
                    }
                    
                } else {
                    self.errorManager.sendError(message: "Nil value on element \(elementAccelerometerData.displayName)")
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementAccelerometerData.displayName): \(error)")
                
            }
        }
    }
    
    public func startAccelerometerUpdateAt(interval: Double) {
        logDebug("Starting accelerometer")
        if let elementAccelerometerOn = self.device.getElementWith(identifier: ElementIdentifier.accelerometerOn.rawValue) {
            elementAccelerometerOn.doubleValue = interval
            do {
                try device.send(element: elementAccelerometerOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementAccelerometerOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func stopAccelerometer() {
        logDebug("Stopping accelerometer")
        if let elementAccelerometerOn = self.device.getElementWith(identifier: ElementIdentifier.accelerometerOn.rawValue) {
            elementAccelerometerOn.doubleValue = 0.0 // Setting interval to zero turns Gyro updates off
            do {
                try device.send(element: elementAccelerometerOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementAccelerometerOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func startGyroUpdateAt(interval: Double) {
        
        logDebug("Starting gyro")
        if let elementGyroOn = self.device.getElementWith(identifier: ElementIdentifier.gyroOn.rawValue) {
            elementGyroOn.doubleValue = interval
            do {
                try device.send(element: elementGyroOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementGyroOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func stopGyro() {
        
        logDebug("Stopping gyro")
        if let elementGyroOn = self.device.getElementWith(identifier: ElementIdentifier.gyroOn.rawValue) {
            elementGyroOn.doubleValue = 0.0 // Setting interval to zero turns Gyro updates off
            do {
                try device.send(element: elementGyroOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementGyroOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    
    public func startDeviceMotionUpdateAt(interval: Double) {

        logDebug("Starting device motion")
        if let elementDeviceMotionOn = self.device.getElementWith(identifier: ElementIdentifier.deviceMotionOn.rawValue) {
            elementDeviceMotionOn.doubleValue = interval
            do {
                try device.send(element: elementDeviceMotionOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementDeviceMotionOn.displayName) resulted in error: \(error)")
            }
        }
    }
    
    public func stopDeviceMotion() {
        
        logDebug("Stopping device motion")
        if let elementDeviceMotionOn = self.device.getElementWith(identifier: ElementIdentifier.deviceMotionOn.rawValue) {
            elementDeviceMotionOn.doubleValue = 0.0 // Setting interval to zero turns DM updates off
            do {
                try device.send(element: elementDeviceMotionOn)
            }
            catch {
                errorManager.sendError(message: "Sending element \(elementDeviceMotionOn.displayName) resulted in error: \(error)")
            }
        }
    }

}
