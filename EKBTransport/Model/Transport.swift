//
//  Transport.swift
//  EKBTransport
//
//  Created by Артем Галиев on 13.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation


// Модели для конвертации данных с сайта
struct Transport {
    let link: String
    let nameStation: String
    let secondName: String
    let searchName: String?
}

struct ItemStation {
    let numberTransport: String
    let timeTransport: String
    let distanceTransport: String
}
