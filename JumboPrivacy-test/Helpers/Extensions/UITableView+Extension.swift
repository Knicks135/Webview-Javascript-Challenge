//
//  UITableView+Extension.swift
//  JumboPrivacy-test
//
//  Created by David Shi on 1/23/20.
//  Copyright © 2020 David Shi. All rights reserved.
//

import UIKit

extension UITableView
{
    func updateRow(row: Int, section: Int = 0)
    {
        let indexPath = IndexPath(row: row, section: section)

        self.beginUpdates()
        self.reloadRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        self.endUpdates()
    }
}
