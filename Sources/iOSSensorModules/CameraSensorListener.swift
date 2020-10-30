//
//  CameraSensorListener.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/14/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import AVFoundation
import ElementalController



public class CameraSensorListener {
    
    var device: ServerDevice
    
    public typealias ImageDataHandler = ((ImageData) -> Void)?
    public var receivedImageData: ImageDataHandler?
    var errorManager: ErrorManager
    let jsonEncoder = JSONEncoder()
    
    public init(device: ServerDevice) {
        
        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        let elementImageData = device.attachElement(Element(identifier: ElementIdentifier.imageData.rawValue, displayName: "imageData", proto: .tcp, dataType: .Data))
        let _ = device.attachElement(Element(identifier: ElementIdentifier.photoRequest.rawValue, displayName: "requestPhoto", proto: .tcp, dataType: .Data))
        
        elementImageData.handler = { element, device in
            logDebug("Got image data")
            let jsonDecoder = JSONDecoder()
            
            do {
                if let v = element.dataValue {
                    let imageData = try jsonDecoder.decode(ImageData.self, from: v)
                    if let handler = self.receivedImageData {
                        
                        handler!(imageData)
                        
                    }
                    
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementImageData.displayName): \(error)")
            }
        }
        
    }
    
    public func requestPhoto(requestID: Int) {
        
    if let elementRequestPhoto = self.device.getElementWith(identifier: ElementIdentifier.photoRequest.rawValue) {
        let requestPhoto = PhotoRequest.init(requestID: requestID, duration: 0, captureSessionPreset: CaptureSessionPreset.high, camera: Camera.frontCamera)
            do {
                let jsonData = try self.jsonEncoder.encode(requestPhoto)
                elementRequestPhoto.dataValue = jsonData
                do {
                    try self.device.send(element: elementRequestPhoto)
                }
                catch {
                    errorManager.sendError(message: "Sending element \(elementRequestPhoto.displayName) resulted in error: \(error)")
                }
                
            } catch {
                self.errorManager.sendError(message: "JSON encoding error on element \(elementRequestPhoto.displayName): \(error)")
            }
        }

    }
    
    
}

