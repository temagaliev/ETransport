//
//  TabBarController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 06.09.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Подписка активна - \(IAPManager.isInAppPurchases)")
        gettingResponseFromUserDefaults()
    }
    
    //MARK: - Определение стартового контроллера
    private func gettingResponseFromUserDefaults() {
        var currentStatus: Bool = false
        if let switchStatus = UserDefaults.standard.object(forKey: KeyForSave.startVC.rawValue) {
            currentStatus = switchStatus as! Bool
            if IAPManager.isInAppPurchases {
                switch currentStatus {
                case true: self.selectedIndex = 1
                case false: self.selectedIndex = 0
                }
            } else {
                self.selectedIndex = 0
            }
        }
    }
}
