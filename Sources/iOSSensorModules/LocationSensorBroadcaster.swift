//
//  LocationSensorBroadcaster.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import CoreLocation
import ElementalController

public class LocationSensorBroadcaster: NSObject, CLLocationManagerDelegate {
    
    var device: ClientDevice
    var locationManager = CLLocationManager()
    var errorManager: ErrorManager
    let jsonEncoder = JSONEncoder()
    
    public func stopUpdatingHeading() {
        
        logDebug("Stopping heading updates")
        self.locationManager.stopUpdatingHeading()
    }
    
    public func stopUpdatingLocation() {
        
         logDebug("Stopping location updates")
        self.locationManager.stopUpdatingLocation()
        
    }
    
    public init(device: ClientDevice)  {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        super.init()
        
        locationManager.delegate = self

        //locationManager.requestAlwaysAuthorization() // Can't do this here because it could delay getting configured for incoming client activity
        
        let elementStandardLocationServiceOn = device.attachElement(Element(identifier: ElementIdentifier.standardLocationServiceOn.rawValue, displayName: "standardLocationServiceOn", proto: .tcp, dataType: .Bool))
        let elementHeadingOn = device.attachElement(Element(identifier: ElementIdentifier.headingOn.rawValue, displayName: "headingOn", proto: .tcp, dataType: .Bool))
        let _ = device.attachElement(Element(identifier: ElementIdentifier.headingData.rawValue, displayName: "headingData", proto: .tcp, dataType: .Data))
        let _ = device.attachElement(Element(identifier: ElementIdentifier.locationData.rawValue, displayName: "locationData", proto: .tcp, dataType: .Data))
        
        elementHeadingOn.handler = { element, device in
            self.locationManager.startUpdatingHeading()
        }
        
        elementStandardLocationServiceOn.handler = { element, device in
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
                // User has not authorized access to location information.
                return
            }
            // Do not start services that aren't available.
            if !CLLocationManager.locationServicesEnabled() {
                // Location services is not available.
                return
            }
            self.locationManager.startUpdatingLocation()
        }
        
        
    }
    
    // TODO: Add better logging and remote error message here
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        logDebug("Location authorization is: \(status)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !device.isConnected {
            self.locationManager.stopUpdatingLocation()
            return
        }
        if let elementLocationData = self.device.getElementWith(identifier: ElementIdentifier.locationData.rawValue) {
            for location in locations {
                // We don't support floor because it's an optional
                let locationData = LocationData.init(timestamp: location.timestamp.timeIntervalSince1970, lattitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, horizontalAccurracy: location.horizontalAccuracy, verticalAccurracy: location.verticalAccuracy, speed: location.speed, course: location.course)
                do {
                    let jsonData = try self.jsonEncoder.encode(locationData)
                    elementLocationData.dataValue = jsonData
                    do {
                        try self.device.send(element: elementLocationData)
                    }
                    catch {
                        errorManager.sendError(message: "Sending element \(elementLocationData.displayName) resulted in error: \(error)")
                    }
                    
                } catch {
                    self.errorManager.sendError(message: "JSON encoding error on element \(elementLocationData.displayName): \(error)")
                }
                
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if !device.isConnected {
            self.locationManager.stopUpdatingHeading()
            return
        }
        if let elementHeadingData = self.device.getElementWith(identifier: ElementIdentifier.headingData.rawValue) {
            let headingData = HeadingData.init(magneticHeading: newHeading.magneticHeading, trueHeading: newHeading.trueHeading)
            do {
                let jsonData = try self.jsonEncoder.encode(headingData)
                elementHeadingData.dataValue = jsonData
                do {
                    try self.device.send(element: elementHeadingData)
                }
                catch {
                    errorManager.sendError(message: "Sending element \(elementHeadingData.displayName) resulted in error: \(error)")
                }
                
            } catch {
                self.errorManager.sendError(message: "JSON encoding error on element \(elementHeadingData.displayName): \(error)")
            }
        }
    }
}

