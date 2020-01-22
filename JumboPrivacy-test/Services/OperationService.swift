//
//  OperationService.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import Foundation

final class OperationService {
    public static let shared = OperationService()
    public var operationQueue: [MessageData] = []
    private var currentGeneratedId: Int = 0
    
    private func generatedNextId() {
        
    }
    
    public func initializeMessageHandler() {

    }
    
    public func startOperation() {

    }
    
    public func parseMessageHandlerData(forNew dictionaryData: [String: Any]) {
        guard
            let id = dictionaryData["id"] as? String,
            let message = dictionaryData["message"] as? String else {
                print("Unable to parse Message objects.")
                fatalError()
        }
        
        if let progress = dictionaryData["progress"] as? Double {
            if progress == 0 {
                operationQueue.append(MessageData(
                    id: id,
                    message: message,
                    progress: 0,
                    state: nil))
                return
            } else {
                operationQueue.append(MessageData(
                    id: id,
                    message: message,
                    progress: progress,
                    state: nil))
                return
            }
        }
        
        if let state = dictionaryData["state"] as? String {
            operationQueue.append(MessageData(
                id: id,
                message: message,
                progress: nil,
                state: state))
            return
        }
        
        operationQueue.append(MessageData(
            id: id,
            message: message))
    }
    
    public func parseMessageHandlerData(forExisting dictionaryData: [String: Any], atIndex messageDataIndex: Int) {
        guard
            let id = dictionaryData["id"] as? String,
            let message = dictionaryData["message"] as? String else {
                print("Unable to parse Message objects.")
                fatalError()
        }
        
        if let progress = dictionaryData["progress"] as? Double {
            if progress != 0 {
                operationQueue[messageDataIndex].message = message
                operationQueue[messageDataIndex].progress = progress
            }
        }
        
        if let state = dictionaryData["state"] as? String {
            operationQueue.append(MessageData(
                id: id,
                message: message,
                progress: nil,
                state: state))
            return
        }
        
        operationQueue.append(MessageData(
            id: id,
            message: message))
    }
}
