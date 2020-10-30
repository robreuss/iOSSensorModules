//
//  CameraSensorBroadcaster.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

// TODO: Setup queuing for multiple requests, including IDs that are sent by the client
// TODO: Deepen functionality around authorization
// TODO: Support some configuration options: Resolution, flash, stabilization
// TODO: Video: user sends amount of time to record and send back as parameter.  Video returned with start/end date objects.
// TODO: Support scheduled/repeat takePhoto
// TODO: Framerate

import Foundation
import AVFoundation
import UIKit
import ElementalController

public class CameraSensorBroadcaster: NSObject, AVCapturePhotoCaptureDelegate {

    var device: ClientDevice
    let jsonEncoder = JSONEncoder()
    var errorManager: ErrorManager
    var cameraController = CameraController()
    var requestQueue = Queue<PhotoRequest>()
    var cameraConfigured = false
    
    public typealias PhotoTakenHandler = ((ImageData) -> Void)?
    public var photoTaken: PhotoTakenHandler?
    
    public init(device: ClientDevice)  {

        self.device = device
        
        errorManager = ErrorManager(device: device)
        
        super.init()
        
        self.cameraController.prepare {(error) in
            if let error = error {
                print(error) // TODO: Handle error
            }
            print("Configuring camera controller: Done")
            self.startQueue()   
        }
       
        let _ = device.attachElement(Element(identifier: ElementIdentifier.imageData.rawValue, displayName: "imageData", proto: .tcp, dataType: .Data))
        let elementRequestPhoto = device.attachElement(Element(identifier: ElementIdentifier.photoRequest.rawValue, displayName: "requestPhoto", proto: .tcp, dataType: .Data))

        elementRequestPhoto.handler = { element, device in
  
            let jsonDecoder = JSONDecoder()
            do {
                if let rp = element.dataValue {
                    let photoRequest = try jsonDecoder.decode(PhotoRequest.self, from: rp)
                    self.requestQueue.enqueue(photoRequest)
                    
                } else {
                    // TODO: Error
                }
            }
            catch {
                self.errorManager.sendError(message: "JSON decoding error on element \(elementRequestPhoto.displayName): \(error)")
            }

            
        }
        
    }
    
    func thatTakesClosure( _ someString: String, _ aClosure: (String) -> (String)) -> String {
        return (aClosure(someString))
    }
    

    var continueRunning = true
    var takingPhoto = false
    var authorized = false
    
    func startQueue() {

        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async { [self] in
            
            while self.continueRunning == true {
                
                if self.authorized == false {
                    switch AVCaptureDevice.authorizationStatus(for: .video) {
                    case .authorized: // The user has previously granted access to the camera.
                        self.authorized = true
                    case .notDetermined: // The user has not yet been asked for camera access.
                        AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
                                self.authorized = true
                            }
                        }
                    case .denied: // The user has previously denied access.
                        self.continueRunning = false
                        self.authorized = false
                        continue
                    // TODO: Error message here
                    case .restricted: // The user can't grant access due to restrictions.
                        self.continueRunning = false
                        self.authorized = false
                        continue
                        // TODO: Error message here
                    }
                }

                if !self.takingPhoto && self.requestQueue.count > 0 && self.authorized {
                    // Scan the queue for next job
                    if let request = self.requestQueue.dequeue() {
                        self.takingPhoto = true
                        self.takePhoto(request)
                    } else {
                        // TODO: Error message here
                    }
                }
                //sleep(1)
            }

            
        }
        
    }

    
    func takePhoto(_ photoRequest: PhotoRequest) {
        
        captureImage(photoRequest)
        
    }

    func captureImage(_ photoRequest: PhotoRequest) {
        
        logDebug("Capturing image")
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                self.errorManager.sendError(message: "Image capture error: \(error)")
                return
            }
            if let elementImageData = self.device.getElementWith(identifier: ElementIdentifier.imageData.rawValue) {
                
                do {
                    let imageData = ImageData.init(requestID: photoRequest.requestID, data: image.pngData()!)
                    
                    if let handler = self.photoTaken {
                        
                        handler!(imageData)
                        
                    }

                    let jsonData = try self.jsonEncoder.encode(imageData)
                    elementImageData.dataValue = jsonData
                    do {
                        try self.device.send(element: elementImageData)
                    }
                    catch {
                        self.errorManager.sendError(message: "Sending element \(elementImageData.displayName) resulted in error: \(error)")
                    }
                }
                catch {
                    self.errorManager.sendError(message: "JSON encoding error on element \(elementImageData.displayName): \(error)")
                }
                self.takingPhoto = false
            }

            
            //try? PHPhotoLibrary.shared().performChangesAndWait {
            //    PHAssetChangeRequest.creationRequestForAsset(from: image)
            //}
        }
        
    }
 
}
