//
//  ElementIdentifiers.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

enum ElementIdentifier: Int8 {
    typealias RawValue = Int8
    
    case error
    
    // Core Motion
    case deviceMotionOn
    case deviceMotionData
    
    case gyroOn
    case gyroData
    
    case accelerometerOn
    case accelerometerData
    
    case magnetometerOn
    case magnetometerData
    
    /* Raw values, unimplemented yet
    case pedometerOn
    case altitudeOn
    */
    
    
    // Core Location
    case standardLocationServiceOn
    case headingOn
    case headingData
    case locationData
    
    case photoRequest
    case imageData
    
    // Battery Status
    
    case batteryStatusOn
    case batteryLevel
    case batteryState
    
    // Thermal
    case thermalStatusOn
    case thermalState
    
    /*
    // Camera
    case startVideo
    case stopVideo
    case takeImage
    case sendLastVideo
    case videoFile
    case sendLastImage
    case imageFile
    
    case startAudio
    case stopAudio
    case sendLastAudio
    case audioFile
    */
}
