//
//  MotionSensorBroadcaster.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import CoreMotion
import ElementalController

public class MotionSensorBroadcaster {
    
    var device: ClientDevice
    var motionManager = CMMotionManager()
    let jsonEncoder = JSONEncoder()
    let errorManager: ErrorManager
    var handlersAdded = false
    
    public func stopDeviceMotionUpdates() {
        logDebug("Stopping device motion updates")
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    
    public func stopGyroUpdates() {
        logDebug("Stopping gyro updates")
        self.motionManager.stopGyroUpdates()
    }
    
    
    public func stopAccelerometerUpdates() {
        logDebug("Stopping accelerometer updates")
        self.motionManager.stopAccelerometerUpdates()
    }
    
    public init(device: ClientDevice)  {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        addHandlers()
        
    }
    
    func addHandlers() {
        
        handlersAdded = true

        device.events.deviceDisconnected.handler = { [self] _ in
            logDebug("iOS Sensors client disconnected")
            device.isConnected = false
            self.stopDeviceMotionUpdates()
            self.stopGyroUpdates()
            self.stopAccelerometerUpdates()
        }
        
        let elementDeviceMotionOn = device.attachElement(Element(identifier: ElementIdentifier.deviceMotionOn.rawValue, displayName: "deviceMotionOn", proto: .tcp, dataType: .Double))
        let elementDeviceMotionData = device.attachElement(Element(identifier: ElementIdentifier.deviceMotionData.rawValue, displayName: "deviceMotionData", proto: .tcp, dataType: .Data))
        elementDeviceMotionOn.handler = { element, device in

            if let deviceMotionUpdateInterval = element.doubleValue {
                
                if deviceMotionUpdateInterval == 0.0 {
                    
                    self.stopDeviceMotionUpdates()
                    
                } else {
                    
                    self.motionManager.deviceMotionUpdateInterval = deviceMotionUpdateInterval
                    
                    self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical, to: OperationQueue.main, withHandler: { (motionData, error) in
                        
                        if let md = motionData {
                            let attitude = Attitude.init(pitch: Float(md.attitude.pitch), roll: Float(md.attitude.roll), yaw: Float(md.attitude.yaw))
                            let rotationRate = ThreeAxis.init(x: (md.rotationRate.x), y: (md.rotationRate.y), z: (md.rotationRate.z))
                            let userAcceleration = ThreeAxis.init(x: md.userAcceleration.x, y: md.userAcceleration.y, z: md.userAcceleration.z)
                            let gravity = ThreeAxis.init(x: md.gravity.x, y: md.gravity.y, z: md.gravity.z)
                            let field = ThreeAxis.init(x: md.magneticField.field.x, y: md.magneticField.field.y, z: md.magneticField.field.z)
                            let magneticField = MagneticField.init(field: field, accuracy: md.magneticField.accuracy.rawValue)
                            let data = DeviceMotionData.init(attitude: attitude, rotationRate: rotationRate, userAcceleration: userAcceleration, gravity: gravity, magneticField: magneticField, heading: md.heading)
                            do {
                                let jsonData = try self.jsonEncoder.encode(data)
                                elementDeviceMotionData.dataValue = jsonData
                                do {
                                    try self.device.send(element: elementDeviceMotionData)
                                }
                                catch {
                                    self.errorManager.sendError(message: "Sending element \(elementDeviceMotionData.displayName) resulted in error: \(error)")
                                }
                                
                            }
                            catch {
                                self.errorManager.sendError(message: "JSON encoding error on element \(elementDeviceMotionData.displayName): \(error)")
                            }
                        }
                    })
                }
            } else {
                // TODO: Error
            }
            
        }
        
        let elementGyroOn = device.attachElement(Element(identifier: ElementIdentifier.gyroOn.rawValue, displayName: "gyroOn", proto: .tcp, dataType: .Double))
        let elementGyroData = device.attachElement(Element(identifier: ElementIdentifier.gyroData.rawValue, displayName: "gyroData", proto: .tcp, dataType: .Data))
        elementGyroOn.handler = { element, device in

            if let gyroUpdateInterval = element.doubleValue {
                
                if gyroUpdateInterval == 0.0 {
                    
                    self.stopGyroUpdates()
                    
                } else {
                    
                    self.motionManager.gyroUpdateInterval = gyroUpdateInterval
                    self.motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: { (gyroData, error) in
                        
                        if let gd = gyroData {
                            let data = GyroData.init(rotationRate: ThreeAxis.init(x: gd.rotationRate.x, y: gd.rotationRate.y, z: gd.rotationRate.z))
                            do {
                                let jsonData = try self.jsonEncoder.encode(data)
                                elementGyroData.dataValue = jsonData
                                do {
                                    try self.device.send(element: elementGyroData)
                                }
                                catch {
                                    self.errorManager.sendError(message: "Sending element \(elementGyroData.displayName) resulted in error: \(error)")
                                }
                                
                            }
                            catch {
                                self.errorManager.sendError(message: "JSON encoding error on element \(elementGyroData.displayName): \(error)")
                                
                            }
                        }
                    })
                }
            } else {
                // TODO: Error
            }
        }
        
        let elementAccelerometerOn = device.attachElement(Element(identifier: ElementIdentifier.accelerometerOn.rawValue, displayName: "accelerometerOn", proto: .tcp, dataType: .Double))
        let elementAccelerometerData = device.attachElement(Element(identifier: ElementIdentifier.accelerometerData.rawValue, displayName: "accelerometerData", proto: .tcp, dataType: .Data))
        elementAccelerometerOn.handler = { element, device in

            if let accelerometerUpdateInterval = element.doubleValue {
                
                if accelerometerUpdateInterval == 0.0 {
                    
                    self.stopAccelerometerUpdates()
                    
                } else {
                    
                    self.motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
                    self.motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { (accelerometerData, error) in
                        
                        if let ad = accelerometerData {
                            let data = AccelerometerData.init(acceleration: ThreeAxis.init(x: ad.acceleration.x, y: ad.acceleration.y, z: ad.acceleration.z))
                            do {
                                let jsonData = try self.jsonEncoder.encode(data)
                                elementAccelerometerData.dataValue = jsonData
                                do {
                                    try self.device.send(element: elementAccelerometerData)
                                }
                                catch {
                                    self.errorManager.sendError(message: "Sending element \(elementGyroData.displayName) resulted in error: \(error)")
                                }
                                
                            }
                            catch {
                                self.errorManager.sendError(message: "JSON encoding error on element \(elementGyroData.displayName): \(error)")
                                
                            }
                        }
                    })
                }
            } else {
                // TODO: Error
            }
        }
    }
    
}

