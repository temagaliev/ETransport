//
//  Enums.swift
//  EKBTransport
//
//  Created by Артем Галиев on 06.09.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation

enum KeyForSave: String {
    case theme = "theme"
    case segment = "segment"
    case startVC = "startVC"
    case stationValue = "stationValue"
    case deletedValue = "deletedValue"
    case isOK = "content is active"
    case allBad = "подписка закончилась"
    case isEndIAP = "isEndIAP"
    case isActiveVip = "isActiveVip"
    case startInfoMain = "startInfoMain"
    case startInfoFavorit = "startInfoFavorit"
    case isSubWasActive = "isSubWasActive"
}

enum NotifiKey: String {
    case lightInterface = "lightInterface"
    case darkInterface = "darkInterface"
    case updateStatus = "updateStatus"
    case isNonData = "isNonData"
    case changeIAP = "changeIAP"
    case errorIAP = "errorIAP"
    case connectionError = "connectionError"
}

enum TransportName: String {
    case tram = "Трамваи"
    case bas = "Троллейбусы"
    case space = ""
}

enum ErrorInSwitch: String {
    case defaultErrorInSwitch = "defaultErrorInSwitch"
}


