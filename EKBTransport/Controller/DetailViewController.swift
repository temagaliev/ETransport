//
//  DetailViewController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 23.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var detailTableView: UITableView!
    static var isNonData: Bool = false 
    
    private let idCell: String = "detailCell"
    private var dataArray: [ItemStation] = []
    private let restrictionsPurchases = RestrictionsPurchases.shared
    
    private var currentNameStation: String = ""
    private var currentLinkStation: String = ""
    private var currentTypeStation: Int16 = 3
    private var currentIsFavorites: Bool!
    private var currentSecondName: String = ""
    private var currentIndexPath: Int!
    
    private var nowAdded: Bool = false
    private var transp: TransportCDModel!
    private var refreshControl: UIRefreshControl!
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private var stationCounter: Int = 3
    private var deletedCounter: Int = 6
    
    private lazy var alertView: AlertView = {
        let alertView: AlertView = AlertView.loadFromNib()
        alertView.alertDelegate = self
        return alertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        addActivityIndicator()
        recivingDataOnRequest()
        CDManager.releaseCoreData()
        startSettings()
        addRefreshControlOnTabelView()
        checkIsNonDataArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateCurrentData()
        favoritesButtonSettings()
    }
    
    //MARK: - Проверка на "Нет данных" и Соединения
    private func checkIsNonDataArray() {
        NotificationCenter.default.addObserver(self, selector: #selector(addAlertNonData), name: NSNotification.Name(NotifiKey.isNonData.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionErrorAlert), name: NSNotification.Name(NotifiKey.connectionError.rawValue), object: nil)
    }
    
    //MARK: - Начальные настройки
    private func startSettings() {
        updateCurrentData()
        navigationItem.title = currentSecondName
    }
    
    //MARK: - Обновление данных об остановке
    private func updateCurrentData() {
        currentNameStation = MainViewController.nameStation
        currentLinkStation = MainViewController.linkStation
        currentSecondName = MainViewController.secondName
        currentTypeStation = Int16(MainViewController.typeStation)
        currentIndexPath = MainViewController.indexPathStation
        currentIsFavorites = MainViewController.isFavoriteDetail
    }
    
    //MARK: - Добавление крутилки-загрузки
    private func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView()
        let bounds: CGRect = UIScreen.main.bounds
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }

    //MARK: - Настройки кнопки добавления
    private func favoritesButtonSettings() {
        switch currentIsFavorites {
        case true:
            favoritesButton.image = #imageLiteral(resourceName: "star30")
        case false:
            let isRepeat: Bool = checkNewElement(name: currentNameStation, link: currentLinkStation)
            if isRepeat != true {
                favoritesButton.image = #imageLiteral(resourceName: "starContur30")
            } else {
                favoritesButton.image = #imageLiteral(resourceName: "star30")
            }
        default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
        }
    }
    
    //проверка есть ли такой элемент в избранных
    private func checkNewElement(name: String, link: String) -> Bool {
        let array = CDManager.fetchRequestTransportCDModel()
        var isRepeat = false
        if array.count != 0 {
            for i in 0...array.count - 1 {
                if (array[i].nameStation == name) && (array[i].linkStation == link) {
                    isRepeat = true
                    break
                }
            }
        }
        return isRepeat
    }
    
    //метод обновление данных и рефреш
    private func addRefreshControlOnTabelView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.reloadData), for: .valueChanged)
        if let aControl = refreshControl {
            detailTableView.addSubview(aControl)
        }
    }
    
    //MARK: - @objc method
    @objc func connectionErrorAlert() {
        DispatchQueue.main.async {
            self.setAlert(title: "Нет подключения к интернету. Попробуйте обновить страницу или проверить подключение к интернету в настройках сети.", leftButtonTitle: "", rightButtonTitle: "Продолжить", hiddenLeftButton: true)
        }
    }
    
    
    @objc func addAlertNonData() {
        DispatchQueue.main.async {
            self.setAlert(title: "В текущий момент информация о транспорте в близи данной остановки не найдена, продолжить ожидание?", leftButtonTitle: "", rightButtonTitle: "Продолжить", hiddenLeftButton: true)
        }
    }
    
    @objc func reloadData() {
        recivingDataOnRequest()
        if refreshControl != nil {
            let formatter = DateFormatter()
            formatter.locale = Locale.init(identifier: "ru")
            formatter.dateFormat = "HH:mm"
            let title = "Последнее обновление: \(formatter.string(from: Date()))"
            let attributedTitle = NSAttributedString(string: title, attributes: nil)
            refreshControl?.attributedTitle = attributedTitle
            refreshControl?.endRefreshing()
        }
    }
    
    //метод удаление элемента из массива
    private func deletedItem(name: String, link: String) {
        let array = CDManager.fetchRequestTransportCDModel()
        if array.count != 0 {
            for i in 0...array.count - 1 {
                if (array[i].nameStation == name) && (array[i].linkStation == link) {
                    let context = CDManager.context
                    let item: NSManagedObject = array[i] as NSManagedObject
                    let itemReport: NSManagedObject = array[i] as NSManagedObject
                    context!.delete(itemReport)
                    context!.delete(item)
                    try? context!.save()
                    break
                }
            }
        }
    }
    
    //MARK: - setAlert
    private func setAlert(title titleString: String, leftButtonTitle leftButtonTitleString: String, rightButtonTitle rightButtonString: String, hiddenLeftButton hiddenButtonBool: Bool) {
        alertView.addVisualEffectView(view: self.view)
        view.addSubview(alertView)
        alertView.center = detailTableView.center
        alertView.set(title: titleString, leftButtonTitle: leftButtonTitleString, rightButtonTitle: rightButtonString, hiddenLeftButton: hiddenButtonBool)
        alertView.layer.cornerRadius = 50
        alertView.layer.shadowOpacity = 0.2
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOffset = CGSize.zero
        alertView.layer.shadowRadius = 5
        alertView.alertDelegate = self

    }
    
    //MARK: - IBAction
    @IBAction func swipeAndPopVC(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // кнопка удалить и добавить
    @IBAction func favoritesAction(_ sender: UIBarButtonItem) {
        switch currentIsFavorites {
        case true:
            let isLimited = restrictionsPurchases.senderOnButtonWhenHavePaidContent(valueDefault: 7, key: KeyForSave.deletedValue.rawValue)
            restrictionsPurchases.accessControlOfPaidContent(isLimited: isLimited) { (isInAppPurchases) in
                switch isInAppPurchases {
                case true:
                    self.deletedItem(name: self.currentNameStation, link: self.currentLinkStation)
                    self.navigationController?.popViewController(animated: true)
                case false: self.setAlert(title: "Бесплатный лимит на удаление остановок закончился, перейти на страницу подписок", leftButtonTitle: "Перейти", rightButtonTitle: "Отмена", hiddenLeftButton: false)
                }
            }
        case false:
            let isRepeat: Bool = checkNewElement(name: currentNameStation, link: currentLinkStation)
            switch isRepeat {
            case true:
                let isLimited = restrictionsPurchases.senderOnButtonWhenHavePaidContent(valueDefault: 7, key: KeyForSave.deletedValue.rawValue)
                restrictionsPurchases.accessControlOfPaidContent(isLimited: isLimited) { (isInAppPurchases) in
                    switch isInAppPurchases {
                    case true:
                        self.deletedItem(name: self.currentNameStation, link: self.currentLinkStation)
                        self.favoritesButton.image = #imageLiteral(resourceName: "starContur30")
                    case false: self.setAlert(title: "Бесплатный лимит на удаление остановок закончился, перейти на страницу подписок", leftButtonTitle: "Перейти", rightButtonTitle: "Отмена", hiddenLeftButton: false)
                    }
                }
            case false:
                let arrayData = CDManager.fetchRequestTransportCDModel()
                let isLimited = restrictionsPurchases.senderOnAddStationButtonCheckPaidContent(dataArray: arrayData)
                restrictionsPurchases.accessControlOfPaidContent(isLimited: isLimited) { (isInAppPurchases) in
                    switch isInAppPurchases {
                    case true:
                        self.transp = CDManager.addTransportStation(name: self.currentNameStation, link: self.currentLinkStation, type: self.currentTypeStation, secondName: self.currentSecondName)
                        self.favoritesButton.image = #imageLiteral(resourceName: "star30")
                    case false: self.setAlert(title: "Бесплатный лимит на добавление остановок закончился, купить платную подписку и снять все ограничения?", leftButtonTitle: "Перейти", rightButtonTitle: "Отмена", hiddenLeftButton: false)
                    }
                }
            }
        default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
        }
    }
    
    //получение данных
    private func recivingDataOnRequest() {
        NetworkingManager.gettingDataFromHTML(url: MainViewController.linkStation) { (currentArray) in
            DispatchQueue.main.async {
                print(currentArray)
                self.dataArray = currentArray
                self.activityIndicatorView.stopAnimating()
                self.detailTableView.reloadData()
            }
        }
    }
}

//MARK: - Table delegate and data source
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArray.count == 0 {
            activityIndicatorView.startAnimating()
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath) as? DetailStationViewCell {
            let item = dataArray[indexPath.row]
            cell.refreshDetail(model: item)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

//MARK: - alert delegate
extension DetailViewController: AlertDelegate {
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

