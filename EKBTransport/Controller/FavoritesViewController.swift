//
//  FavoritesViewController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 27.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//
//MARK: - class FavoritesViewController
import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    @IBOutlet weak var favoritesTableView: UITableView!
    
    private let idCell: String = "favoritesCell"
    let restrictionsPurchases = RestrictionsPurchases.shared
    var arrayCDTransport: [TransportCDModel]!
    let device = UIDevice()
    private var alertView = AlertView()
    private var isFirstOpenApp: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Подписка активна - \(IAPManager.isInAppPurchases)")
        CDManager.releaseCoreData()
        deletedAllElemntsFromCore()
        startSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        arrayCDTransport = CDManager.fetchRequestTransportCDModel()
        favoritesTableView.reloadData()
    }
    
    //MARK: - Стартовые настройки
    private func startSettings() {
        arrayCDTransport = CDManager.fetchRequestTransportCDModel()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
    }
    
    //MARK: - Настройки алерт
    private func setAlert(title titleString: String, leftButtonTitle leftButtonTitleString: String, rightButtonTitle rightButtonString: String, hiddenLeftButton hiddenButtonBool: Bool) {
        alertView = AlertView.loadFromNib()
        alertView.addVisualEffectView(view: self.view)
        alertView.layer.cornerRadius = 50
        view.addSubview(alertView)
        alertView.center = favoritesTableView.center
        alertView.set(title: titleString, leftButtonTitle: leftButtonTitleString, rightButtonTitle: rightButtonString, hiddenLeftButton: hiddenButtonBool)
        alertView.layer.shadowOpacity = 0.2
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOffset = CGSize.zero
        alertView.layer.shadowRadius = 5
        alertView.alertDelegate = self

    }
    
    //MARK: - Удаление всех элементов при отмене подписки
    private func deletedAllElemntsFromCore() {
        var isInAppPurEnd: Bool = false
        if let newBool = UserDefaults.standard.object(forKey: KeyForSave.isEndIAP.rawValue) {
            isInAppPurEnd = newBool as! Bool
        }
        print("isInAppPurEnd is \(isInAppPurEnd)")
        if IAPManager.isInAppPurchases == false && isInAppPurEnd == true  {
            print("All elements deleted")
            CDManager.deletedAllData()
            UserDefaults.standard.set(false, forKey: KeyForSave.isEndIAP.rawValue)
            DispatchQueue.main.async {
                self.setAlert(title: "Срок действия подписки истек. Необходимо заново добавить остановки в избранные. Лимит на удаление остановок обновлен до 6. Продлить подписку?", leftButtonTitle: "Продолжить", rightButtonTitle: "Отмена", hiddenLeftButton: false)
            }
            favoritesTableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (device.modelName.rawValue == "iPhone SE") || (device.modelName.rawValue == "iPhone 5") || (device.modelName.rawValue == "iPhone 5s") {
            return 100.0
        } else {
            return 110.0
        }
    }
    
    //MARK: - Кол-во секций
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayCDTransport == nil {
            return 0
        } else {
            return arrayCDTransport.count
        }
    }
    
    //MARK: - Создание ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath) as? FavoritesViewCell {
            let item = arrayCDTransport[indexPath.row]
            cell.refreshFavorites(model: item)
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: - Удаление ячейки
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let context = CDManager.context
        let deleteButton =  UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            let isLimited = self.restrictionsPurchases.senderOnButtonWhenHavePaidContent(valueDefault: 7, key: KeyForSave.deletedValue.rawValue)
            self.restrictionsPurchases.accessControlOfPaidContent(isLimited: isLimited) { (isInAppPurchases) in
                switch isInAppPurchases {
                case true:
                    let item: NSManagedObject = self.arrayCDTransport[indexPath.row] as NSManagedObject
                    let itemReport: NSManagedObject = self.arrayCDTransport[indexPath.row] as NSManagedObject
                    context!.delete(itemReport)
                    context!.delete(item)
                    try? context!.save()
                    self.arrayCDTransport.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                case false: self.setAlert(title: "Бесплатный лимит на удаление остановок закончился, купить платную подписку и снять все ограничения?", leftButtonTitle: "Продолжить", rightButtonTitle: "Отмена", hiddenLeftButton: false)
                }
            }

        }
        return [deleteButton]
    }
    
    //MARK: - Нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MainViewController.nameStation = arrayCDTransport[indexPath.row].nameStation!
        MainViewController.secondName = arrayCDTransport[indexPath.row].secondName!
        MainViewController.linkStation = arrayCDTransport[indexPath.row].linkStation!
        MainViewController.isFavoriteDetail = true
        let pushViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
        navigationController?.pushViewController(pushViewController!, animated: true)
    }
    
    
}

//MARK: - AlertDelegate
extension FavoritesViewController: AlertDelegate {
    private func closeAlertView() {
        alertView.removeFromSuperview()
        alertView.removeVisualEffectView(view: self.view)
    }
    
    func leftButtonAction() {
        closeAlertView()
        let pushViewController = storyboard?.instantiateViewController(withIdentifier: "PurchasesViewController")
        navigationController?.present(pushViewController!, animated: true, completion: nil)
    }
    
    func rightButtonAction() {
        closeAlertView()
    }
}

