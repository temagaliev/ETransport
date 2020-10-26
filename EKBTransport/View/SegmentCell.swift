//
//  SegmentCell.swift
//  EKBTransport
//
//  Created by Артем Галиев on 02.09.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

class SegmentCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var updateStatus: String = "updateStatus"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Выбор транспорта в сигменте
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            MainViewController.segmentStatus = .all
            NotificationCenter.default.post(name: Notification.Name(updateStatus), object: nil)
        case 1:
            MainViewController.segmentStatus = .bus
            NotificationCenter.default.post(name: Notification.Name(updateStatus), object: nil)
        case 2:
            MainViewController.segmentStatus = .tram
            NotificationCenter.default.post(name: Notification.Name(updateStatus), object: nil)
        default: print(updateStatus)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
