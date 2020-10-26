//
//  ConsumptionViewController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 29.08.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//MARK: - class PurchasesViewController

import UIKit
import StoreKit

class PurchasesViewController: UIViewController {
    
    //var static
    static var currentUrl: String = ""
    
    // other var
    var pri = "1 месяц - 70 ₽ 70 ₽/месяц"
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonSub: UIButton!
    let iapManeger = IAPManager.shared
    var identifierProductPayment: String = "ru.Etransport.onemonth"
    
    //1 mounth sub button
    @IBOutlet weak var firstMainView: UIView!
    @IBOutlet weak var firstSubButton: UIButton!
    @IBOutlet weak var firstSubLabelTop: UILabel!
    @IBOutlet weak var firstSubLabelBottom: UILabel!
    @IBOutlet weak var firstOkImage: UIImageView!
    
    //6 mounth sub button
    @IBOutlet weak var secondMainView: UIView!
    @IBOutlet weak var secondSubLabelTop: UILabel!
    @IBOutlet weak var secondSubLabelBottom: UILabel!
    @IBOutlet weak var secondOkImage: UIImageView!
    
    
    var senderFirstButtonBoll: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Подписка активна - \(IAPManager.isInAppPurchases)")
        startButtoSettings()
        buttonAnimation(senderFirstButtonBoll)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - @IBAction
    @IBAction func subButtonAction(_ sender: UIButton) {
        iapManeger.purchese(productWith: identifierProductPayment)
        print(identifierProductPayment)
    }
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        PurchasesViewController.currentUrl = "https://docs.google.com/document/d/1x29ym1wRCEdRQSHgvUegsDADbAdpNmlLMIbSnE0Q_x8/edit"
    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        iapManeger.restoreCompletedTransactions()
    }
    
    @IBAction func termsOfServiceAction(_ sender: UIButton) {
        PurchasesViewController.currentUrl = "https://docs.google.com/document/d/12OCCrpcaxkCD5AvmSgysbQJ1qeY0uVpDqf4uAbdpdiY/edit#heading=h.vsrtk4e0fl6b"
    }
    
    @IBAction func senderFirstSubButton(_ sender: UIButton) {
        senderFirstButtonBoll = true
        buttonAnimation(senderFirstButtonBoll)
        identifierProductPayment = IAPProducts.oneMonth.rawValue
        print(identifierProductPayment)
    }
    
    @IBAction func senderSecondSubButton(_ sender: Any) {
        senderFirstButtonBoll = false
        buttonAnimation(senderFirstButtonBoll)
        identifierProductPayment = IAPProducts.sixMonth.rawValue
        print(identifierProductPayment)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - NotificationObserver
    private func notificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadIAP), name: Notification.Name(rawValue: IAPManager.productNotificationIdentifier), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(oneMonthAction), name: Notification.Name(rawValue: IAPProducts.oneMonth.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sixMonthAction), name: Notification.Name(rawValue: IAPProducts.sixMonth.rawValue), object: nil)

    }
    
    //MARK: -  @objc
    
    @objc func reloadIAP() {
        print("обновление данных о подписке")
    }
    
    @objc func oneMonthAction() {
        print("got one month purchases")
    }
    
    @objc func sixMonthAction() {
        print("got six month purchases")
    }
    //MARK: - Изменение визуала для кнопки подписок
    private func buttonAnimation(_ boolValue: Bool) {
        switch boolValue {
        case true:
            //Нажатая кнопка оплата по месячно
            firstMainView.backgroundColor = #colorLiteral(red: 0.1199959889, green: 0.1295567453, blue: 0.1424047351, alpha: 1)
            firstSubLabelTop.textColor = .white
            firstSubLabelBottom.textColor = .white
            firstOkImage.isHidden = false
            
            secondMainView.backgroundColor = .white
            secondSubLabelTop.textColor = .black
            secondSubLabelBottom.textColor = .black
            secondOkImage.isHidden = true
            
            labelDescription.text = "Подписка возобновляется автоматический каждый месяц, пока не будет отменена."
            
        case false:
            //Нажатая кнопка оплата за пол года
            secondMainView.backgroundColor = #colorLiteral(red: 0.1199959889, green: 0.1295567453, blue: 0.1424047351, alpha: 1)
            secondSubLabelTop.textColor = .white
            secondSubLabelBottom.textColor = .white
            secondOkImage.isHidden = false
            
            firstMainView.backgroundColor = .white
            firstSubLabelTop.textColor = .black
            firstSubLabelBottom.textColor = .black
            firstOkImage.isHidden = true 
            
            labelDescription.text = "Подписка возобновляется автоматический каждые пол года, пока не будет отменена."
        }
    }
}

extension PurchasesViewController {
    //MARK: - Начальные настройки кнопок
    func startButtoSettings() {
        buttonSub.layer.cornerRadius = 10
        firstMainView.layer.borderWidth = 1
        firstMainView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        firstMainView.layer.cornerRadius = 10
        
        secondMainView.layer.borderWidth = 1
        secondMainView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        secondMainView.layer.cornerRadius = 10
        
        firstOkImage.isHidden = true
        secondOkImage.isHidden = true
    }
}

extension PurchasesViewController {
    
    //MARK: - Метод определяющий цену продукта
    private func priceStringFor(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        
        return numberFormatter.string(from: product.price)!
    }
}

