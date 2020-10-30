//
//  ErrorManager.swift
//  iOSSensorModule
//
//  Created by Rob Reuss on 2/13/19.
//  Copyright © 2019 Rob Reuss. All rights reserved.
//

import Foundation
import ElementalController

class ErrorManager  {
    
    var device: Device
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    public typealias ErrorMessageHandler = ((ErrorData) -> Void)?
    var recievedErrorMessage: ErrorMessageHandler?
    
    init(device: Device) {
        
        self.device = device
        
        let elementError = device.attachElement(Element(identifier: ElementIdentifier.error.rawValue, displayName: "error", proto: .tcp, dataType: .Data))

        elementError.handler = { element, device in
            
            do {
                if let v = element.dataValue {
                    let errorData = try self.jsonDecoder.decode(ErrorData.self, from: v)
                    if let handler = self.recievedErrorMessage {
                        
                        handler!(errorData)
                        
                    }
                } else {
                    // TODO: Error
                }
            }
            catch {
                logError("Got error: \(error)") // TODO: Error
            }
            
        }
        
    }
    
    func sendError(message: String) {
        if let elementError = self.device.getElementWith(identifier: ElementIdentifier.error.rawValue) {
            let errorData = ErrorData.init(message: message)
            do {
                let jsonData = try self.jsonEncoder.encode(errorData)
                elementError.dataValue = jsonData
                do {
                    logError("\(message)")
                    try self.device.send(element: elementError)
                }
                catch {
                    // TODO: Error
                }
                
            }
            catch {
                // TODO: Error
            }

        }
    }
    
}
