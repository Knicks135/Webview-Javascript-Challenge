//
//  MessageData.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/19/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import Foundation

class MessageData: NSObject {
    let id: String
    var message: String
    var progress: Double?
    var state: String?
    
    init(id: String, message: String, progress: Double? = nil, state: String? = nil) {
        self.id = id
        self.message = message
        self.progress = progress
        self.state = state
    }
}
