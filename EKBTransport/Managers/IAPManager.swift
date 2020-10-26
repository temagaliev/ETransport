//
//  IAPManager.swift
//  EKBTransport
//
//  Created by Артем Галиев on 31.08.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    static let productNotificationIdentifier = "IAPManagerProductIdentifier"
    static let shared = IAPManager()
    
    private override init() {}
    
    var products: [SKProduct] = []
    let paymentQueue = SKPaymentQueue.default()
    
    //MARK:- Может ли устройство выполнять платежи
    public func setupPurcheses(callback: @escaping(Bool) -> Void) {
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.add(self)
            callback(true)
            return
        }
        callback(false)
    }
    
    //Получение продуктов
    public func getProducts() {
        let identifires: Set = [
            IAPProducts.oneMonth.rawValue,
            IAPProducts.sixMonth.rawValue
        ]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifires)
        productRequest.delegate = self
        // Запускаем запрос (по умолчанию он не действует)
        productRequest.start()
    }
    
    //Покупка
    public func purchese(productWith identifier: String) {
        guard let product = products.filter({ $0.productIdentifier == identifier}).first else {return}
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }
    
    public func restoreCompletedTransactions() {
        paymentQueue.restoreCompletedTransactions()
    }
    
    public func checkSubscriptionExpirationDate() {
        let receiptValidator = ReceiptValidator()
        let result = receiptValidator.validateReceipt()
        switch result {
        case let .success(receipt):
            
            var maxSubExpDate = receipt.inAppPurchaseReceipts![0].subscriptionExpirationDate ?? currentDataActive()
            
            for i in 0...receipt.inAppPurchaseReceipts!.count - 1 {
                if maxSubExpDate < receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate ?? currentDataActive() {
                    maxSubExpDate = receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate!
                }
                print(receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate ?? "")
            }
            
            print("is maxSubExpDate \(maxSubExpDate)")

            guard (receipt.inAppPurchaseReceipts?.filter({ $0.productIdentifier == IAPProducts.oneMonth.rawValue || $0.productIdentifier == IAPProducts.sixMonth.rawValue }).last) != nil else {
                return
            }

            let currentData = currentDataActive()
            
            if maxSubExpDate.compare(currentData) == .orderedDescending {
                IAPManager.isInAppPurchases = true
                IAPManager.isSubWasActive = true
                UserDefaults.standard.set(true, forKey: KeyForSave.isSubWasActive.rawValue)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(NotifiKey.changeIAP.rawValue), object: nil)
                IAPManager.isInAppPurchases = false
            }
        case let .error(error): print(error.localizedDescription)
        }
    }
}

//MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        products.forEach { print($0.localizedTitle) }
        
        if products.count > 0 {
            NotificationCenter.default.post(name: Notification.Name(IAPManager.productNotificationIdentifier), object: nil)
        }
    }
}

//MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred: break
            case .purchasing: break
            case .failed: failed(transaction: transaction)
            case .purchased: purchased(transition: transaction)
            case .restored: restored(transition: transaction)
            default: defaultState()
            }
        }
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        print("failed")
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Ошибка транзакции: \(transaction.error!.localizedDescription)")
            }
        }
        paymentQueue.finishTransaction(transaction)
    }
    
    private func purchased(transition: SKPaymentTransaction) {
        print("purchased")
        let receiptValidator = ReceiptValidator()
        let result = receiptValidator.validateReceipt()
        
        switch result {
        case let .success(receipt):
            
            var maxSubExpDate = receipt.inAppPurchaseReceipts![0].subscriptionExpirationDate ?? currentDataActive()
            
            for i in 0...receipt.inAppPurchaseReceipts!.count - 1 {
                if maxSubExpDate < receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate ?? currentDataActive() {
                    maxSubExpDate = receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate!
                }
                print(receipt.inAppPurchaseReceipts![i].subscriptionExpirationDate ?? "")
            }
            
            print("is maxSubExpDate \(maxSubExpDate)")
            
            print("success in purchased")
            guard let purchase = receipt.inAppPurchaseReceipts?.filter({ $0.productIdentifier == IAPProducts.oneMonth.rawValue || $0.productIdentifier == IAPProducts.sixMonth.rawValue }).last else {
                NotificationCenter.default.post(name: NSNotification.Name(transition.payment.productIdentifier), object: nil)
                paymentQueue.finishTransaction(transition)
                return
            }
            let currentData = currentDataActive()
            if maxSubExpDate.compare(currentData) == .orderedDescending {
                UserDefaults.standard.set(true, forKey: KeyForSave.isActiveVip.rawValue)
                IAPManager.isInAppPurchases = true
                IAPManager.isSubWasActive = true
                UserDefaults.standard.set(true, forKey: KeyForSave.isSubWasActive.rawValue)
                print(purchase.subscriptionExpirationDate!)
            } else {
                UserDefaults.standard.set(false, forKey: KeyForSave.isActiveVip.rawValue)
                print("Подписка не найдена purshesed")
                IAPManager.isInAppPurchases = false
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(transition.payment.productIdentifier), object: nil)
            
        case let .error(error): print(error.localizedDescription)
        }
        
        paymentQueue.finishTransaction(transition)
    }
    
    private func restored(transition: SKPaymentTransaction) {
        print("restored")
        IAPManager.isSubWasActive = true
        UserDefaults.standard.set(true, forKey: KeyForSave.isSubWasActive.rawValue)
        paymentQueue.finishTransaction(transition)
    }
    
    private func defaultState() {
        print("In transition state default error")
    }
    
    private func currentDataActive() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 5)

        let newDate = Date()
        dateFormatter.string(from: newDate)
        let dataX = dateFormatter.date(from: dateFormatter.string(from: newDate))
        print("is dataX - \(String(describing: dataX))")
        return dataX ?? Date()

    }
}

//MARK: - Менеджер контроля доступа платного контента
extension IAPManager {
    static var isInAppPurchases: Bool = false 
    static let isEndIAP: Bool = false
    static var isSubWasActive: Bool = false 
    static public func hiddenActionForPurcheses() {
    }
}


