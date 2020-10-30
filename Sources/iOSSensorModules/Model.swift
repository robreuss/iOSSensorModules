//
//  Model.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//
import Foundation
import AVFoundation

public struct MagneticField: Codable {
    public var field: ThreeAxis
    public var accuracy: Int32
}

public struct Attitude: Codable {
    public var pitch: Double
    public var roll: Double
    public var yall: Double
}

public struct ThreeAxis: Codable {
    public var x: Double
    public var y: Double
    public var z: Double
}

public struct HeadingData: Codable {
    
    public var magneticHeading: Double
    public var trueHeading: Double
}

public struct GyroData: Codable {
    
    public var rotationRate: ThreeAxis
    
}

public struct AccelerometerData: Codable {
    
    public var acceleration: ThreeAxis
    
}

public struct MagnetometerData: Codable {
    
    public var magneticField: ThreeAxis
    
}

public struct DeviceMotionData: Codable {
    
    public var attitude: Attitude
    public var rotationRate: ThreeAxis
    public var userAcceleration: ThreeAxis
    public var gravity: ThreeAxis
    public var magneticField: MagneticField
    public var heading: Double
    
}

public struct LocationData: Codable {

    public var timestamp: Double
    public var lattitude: Double
    public var longitude: Double
    public var altitude: Double
    public var horizontalAccurracy: Double
    public var verticalAccurracy: Double
    public var speed: Double
    public var course: Double
    
}

public enum Camera: Int, Codable {
    case frontCamera
    case backCamera
}

public struct PhotoRequest: Codable {
    
    public var requestID: Int
    public var duration: Int
    public var captureSessionPreset: CaptureSessionPreset
    public var camera: Camera
    //public var exposureDuration: CMTime  // Setting exposure: https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624646-setexposuremodecustom
    
}

public struct ImageData: Codable {
    public var requestID: Int
    public var data: Data
}

public struct ErrorData: Codable {
    public var message: String
}

public enum CaptureSessionPreset: Int, Codable {
    
    case cif352x288
    case hd1280x720
    case hd1920x1080
    case high
    
}

/*
 static let cif352x288: AVCaptureSession.Preset
 Specifies capture settings suitable for CIF quality (352 x 288 pixel) video output.
 static let hd1280x720: AVCaptureSession.Preset
 Specifies capture settings suitable for 720p quality (1280 x 720 pixel) video output.
 static let hd1920x1080: AVCaptureSession.Preset
 Specifies capture settings suitable for 1080p quality (1920 x1080 pixel) video output.
 static let hd4K3840x2160: AVCaptureSession.Preset
 Specifies capture settings suitable for 2160p (also called UHD or 4K) quality (3840 x 2160 pixel) video output.
 static let high: AVCaptureSession.Preset
 Specifies capture settings suitable for high-quality video and audio output.
*/
