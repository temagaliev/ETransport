//
//  UIDevice + modelName.swift
//  EKBTransport
//
//  Created by Артем Галиев on 15.05.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

//MARK: - Найстройки под модель девайса
public enum Devices: String {
    case IPhone5 = "iPhone 5"
    case IPhone5C = "iPhone 5c"
    case IPhone5S = "iPhone 5s"
    case Other = "other"
}

public extension UIDevice {
    
    var modelName: Devices {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPhone5,1", "iPhone5,2": return Devices.IPhone5
        case "iPhone5,3", "iPhone5,4": return Devices.IPhone5C
        case "iPhone6,1", "iPhone6,2": return Devices.IPhone5S
        default: return Devices.Other
        }
    }
    
}
