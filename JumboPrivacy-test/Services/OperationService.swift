//
//  OperationService.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import Foundation

enum ErrorTypes: Error {
    case parsingError
}

final class OperationService {
    public static let shared = OperationService()
    public var operationQueue: [MessageData] = []
    private var currentGeneratedId: Int = 0
    private var currentIndex: Int {
        get {
            return operationQueue.endIndex - 1
        }
    }
    
    public func generatedNextId() -> Int {
        let nextId = currentGeneratedId + 1
        currentGeneratedId = nextId
        return nextId
    }
    
    /// Parses out message handler data and prepares a new MessageData to add to the operationQueue.
    /// - Parameters:
    ///   - dictionaryData: data to be parse which is a dictionary data type
    ///   - completionHandler: once the function completes it would return the row index to be updated in the table view
    public func parseMessageHandlerData(forNew dictionaryData: [String: Any], completionHandler: @escaping (Result<Int, ErrorTypes>) -> Void) {
        guard
            let id = dictionaryData["id"] as? String,
            let message = dictionaryData["message"] as? String else {
                completionHandler(.failure(.parsingError))
                return
        }
        
        if let progress = dictionaryData["progress"] as? Double {
            if progress == 0 {
                operationQueue.append(MessageData(
                    id: id,
                    message: message,
                    progress: 0,
                    state: nil))
                completionHandler(.success(currentIndex))
                return
            } else {
                operationQueue.append(MessageData(
                    id: id,
                    message: message,
                    progress: progress,
                    state: nil))
                completionHandler(.success(currentIndex))
                return
            }
        }
        
        if let state = dictionaryData["state"] as? String {
            operationQueue.append(MessageData(
                id: id,
                message: message,
                progress: nil,
                state: state))
            completionHandler(.success(currentIndex))
            return
        }
        
        operationQueue.append(MessageData(
            id: id,
            message: message))
        completionHandler(.success(currentIndex))
        return
    }
        
    /// Parses the message from the message handler where the operation is already in the queue.  It would update MessageData object with the latest information
    /// - Parameters:
    ///   - dictionaryData: data to be parse which is a dictionary data type
    ///   - messageDataIndex: the index of the operationQueue where the messageData exists
    ///   - completionHandler: returns an error if there is one
    public func parseMessageHandlerData(forExisting dictionaryData: [String: Any], atIndex messageDataIndex: Int, completionHandler: @escaping (Result<Bool, ErrorTypes>) -> Void) {
        guard
            let _ = dictionaryData["id"] as? String,
            let message = dictionaryData["message"] as? String else {
                completionHandler(.failure(.parsingError))
                return
        }
        
        if let progress = dictionaryData["progress"] as? Double {
            if progress != 0 {
                operationQueue[messageDataIndex].message = message
                operationQueue[messageDataIndex].progress = progress
                completionHandler(.success(true))
                return
            }
        }
        
        if let state = dictionaryData["state"] as? String {
            operationQueue[messageDataIndex].state = state
            
            if message == "completed" && state == "success" {
                operationQueue[messageDataIndex].progress = 100
            } else {
                operationQueue[messageDataIndex].progress = 0
            }
            completionHandler(.success(true))
            return
        }
        
    }
}
