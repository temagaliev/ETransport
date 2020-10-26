//
//  RestrictionsPurchasesManager.swift
//  EKBTransport
//
//  Created by Артем Галиев on 07.09.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation

class RestrictionsPurchases {
    static let shared = RestrictionsPurchases()
    
    //MARK: - Сохранение новых значений удаления
    public func updateDeletedValue() {
        UserDefaults.standard.set(7, forKey: KeyForSave.deletedValue.rawValue)
    }
    
    //MARK: - Получение значения счетчиков
    public func updateLimitedValueCounter(valueDefault defaultInt: Int, key keyString: String) -> Int {
        var currentName: Int = defaultInt
        if let currentValue = UserDefaults.standard.object(forKey: keyString) {
            currentName = currentValue as! Int
            return currentName
        } else { return defaultInt }
    }
    
    //MARK: - Вычитание лимитовых значенй
    public func limitedValueCounter(count currentValue: Int, key keyString: String) -> Int {
        var userDefaultsValue: Int?
        (currentValue - 1) >= 0 ? (userDefaultsValue = currentValue - 1) : (userDefaultsValue = 0)
        UserDefaults.standard.set(userDefaultsValue, forKey: keyString)
        return userDefaultsValue ?? 3
    }
    
    //MARK: - Проверки при нажатии на кнопку, на которой действет платное ограничение
    public func senderOnButtonWhenHavePaidContent(valueDefault defValue: Int, key keyString: String) -> Bool {
        var isLimited: Bool = false
        var currentCounter = updateLimitedValueCounter(valueDefault: defValue, key: keyString)
        currentCounter = limitedValueCounter(count: currentCounter, key: keyString)
        currentCounter == 0 ? isLimited = true : print(isLimited)
        return isLimited
        
    }
    
    //MARK: - Проверка на добавление остановок в избранные (ограничение 3 остановки)
    public func senderOnAddStationButtonCheckPaidContent(dataArray: [TransportCDModel]) -> Bool {
        var isLimited: Bool = false
        let countArray = dataArray.count
        ((countArray + 1) <= 3) ? (isLimited = false) : (isLimited = true)
        return isLimited
    }
    
    //MARK: - Главный метод ограничений
    public func accessControlOfPaidContent(isLimited isLimit: Bool, completion: @escaping(_ bool: Bool) -> Void) {
        switch IAPManager.isInAppPurchases {
        case true:
            completion(true)
            updateDeletedValue()
            UserDefaults.standard.set(true, forKey: KeyForSave.isEndIAP.rawValue)
        case false: isLimit ? completion(false) : completion(true)
        }
    }
}


