//
//  OperationTableViewCell.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/23/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import UIKit

class OperationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var emptyProgressBar: UIView!
    
    static let cellId = "OperationTableViewCell"
    
    public func configureCell(withMessageData message: MessageData) {
        idLabel.text = message.id
        
        //If the state is not in progress, then use the "state" property for the status label
        if let state = message.state {
            statusLabel.text = state
        } else {
            statusLabel.text = message.message
        }
        
        if let progress = message.progress {
            progressLabel.text = "\(progress)%"
            let progressBarWidthRatio = progress / 100.0
            let emptyProgressBarWidth = emptyProgressBar.bounds.width
            progressBarWidth.constant = CGFloat(progressBarWidthRatio) * emptyProgressBarWidth
        } else {
            progressLabel.text = ""
        }
        
        
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        idLabel.text = nil
        statusLabel.text = nil
        progressLabel.text = nil
    }
}
