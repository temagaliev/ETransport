//
//  ViewController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 06.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private let iPhoneCell: String = "iPhoneCell"
    private let segmentCell: String = "segmentCell"
    private var isFirstOpenApp: Bool = true
    
    static var searching: Bool = false
    static var nameStation: String = ""
    static var linkStation: String = ""
    static var secondName: String = ""
    static var typeStation: Int = 3
    static var isFavoriteDetail: Bool = false
    static var indexPathStation: Int!
    static var segmentStatus: SegmentStatus = .all
    
    var arrayForSearchingTram: [Transport] = []
    var arrayForSearchingBus: [Transport] = []
    var timer: Timer?
    let device = UIDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Подписка активна - \(IAPManager.isInAppPurchases)")
        self.definesPresentationContext = true
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        setupSearchBar()
        translucentAction()
        acceptsInfoFromNotification()
//        startAlertInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mainTableView.reloadData()
    }
    
    //MARK: - Настройки поисковой строки
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        mainTableView.keyboardDismissMode = .interactive
        mainTableView.keyboardDismissMode = .onDrag
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Отмена"
        UISearchBar.appearance().tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    //fix bag, with visual effect, when push detail vc there was a black line instead of shit
    private func translucentAction() {
        var nameThemeType: String = SegmentTheme.light.rawValue

        if let theme = UserDefaults.standard.object(forKey: KeyForSave.theme.rawValue) {
            nameThemeType = theme as! String
            switch nameThemeType {
            case SegmentTheme.dark.rawValue: navigationController?.navigationBar.isTranslucent = false
            case SegmentTheme.light.rawValue: navigationController?.navigationBar.isTranslucent = true
            default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
            }
        } else {
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    //MARK: - Стартовое уведомление
//    private func startAlertInformation() {
//        if let first = UserDefaults.standard.object(forKey: KeyForSave.startInfoMain.rawValue) {
//            isFirstOpenApp = first as! Bool
//        }
//        let title = "Экран «Остановки» предназначен для поиска редко посещаемых остановок, часто используемые остановки советуем добавлять в «Избранные»."
//        if isFirstOpenApp {
//            DispatchQueue.main.async {
//                self.setAlert(title: title, leftButtonTitle: "", rightButtonTitle: "Понятно", hiddenLeftButton: true)
//            }
//            UserDefaults.standard.set(false, forKey: KeyForSave.startInfoMain.rawValue)
//        }
//    }
    
    //MARK: -  NotificationCenter
    private func acceptsInfoFromNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(lightInterface), name: NSNotification.Name(NotifiKey.lightInterface.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkInterface), name: NSNotification.Name(NotifiKey.darkInterface.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSegmentStatus), name: NSNotification.Name(NotifiKey.updateStatus.rawValue), object: nil)
    }
    
    //MARK: - @objc method
    
    @objc private func lightInterface() {
        navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc private func darkInterface() {
        navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc private func updateSegmentStatus() {
        print(MainViewController.segmentStatus)
        mainTableView.reloadData()
    }
}

//MARK:- TableDelegate and TableDatasource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Вид секции
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if #available(iOS 13.0, *) {
            header.backgroundView?.backgroundColor = .systemBackground
            header.textLabel?.textColor = .label
            header.tintColor = .systemBackground
        } else {
            header.backgroundView?.backgroundColor = .white
            header.textLabel?.textColor = .black
            header.tintColor = .white
        }
        header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)
    }

    //MARK: - Количество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        switch MainViewController.searching {
        case true: return 2
        case false:
            switch MainViewController.segmentStatus {
            case .all: return 3
            case .bus: return 2
            case .tram: return 2
            }
        }
    }

    //MARK: -  Название секций
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch MainViewController.searching {
        case true:
            switch section {
            case 0:  return TransportName.tram.rawValue
            case 1: return TransportName.bas.rawValue
            default: return TransportName.space.rawValue
            }
        case false:
            switch MainViewController.segmentStatus {
            case .all:
                switch section {
                case 0: return nil
                case 1: return TransportName.tram.rawValue
                case 2: return TransportName.bas.rawValue
                default: return TransportName.space.rawValue
                }
            case .tram:
                switch section {
                case 0: return nil
                case 1: return TransportName.tram.rawValue
                default: return TransportName.space.rawValue
                }
            case .bus:
                switch section {
                case 0: return nil
                case 1: return TransportName.bas.rawValue
                default: return TransportName.space.rawValue
                }
            }
        }
    }
    
    //MARK: - Количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MainViewController.searching {
        case true:
            switch section {
            case 0: return arrayForSearchingTram.count
            case 1: return arrayForSearchingBus.count
            default: return 0
            }
        case false:
            switch MainViewController.segmentStatus {
            case .all:
                switch section {
                case 0: return 1
                case 1: return TransportData.dataTram.count
                case 2: return TransportData.dataBus.count
                default: return 0
                }
            case .tram:
                switch section {
                case 0: return 1
                case 1: return TransportData.dataTram.count
                case 2: return 0
                default: return 0
                }
            case .bus:
                switch section {
                case 0: return 1
                case 1: return TransportData.dataBus.count
                case 2: return 0
                default: return 0
                }
            }
        }
    }
    
    //MARK: - Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (device.modelName.rawValue == "iPhone SE") || (device.modelName.rawValue == "iPhone 5") || (device.modelName.rawValue == "iPhone 5s") {
            if indexPath.section == 0 && MainViewController.searching == false {
                return 40.0
            } else {
                return 100.0
            }
        } else if indexPath.section == 0  && MainViewController.searching == false {
            return 40.0
        } else {
            return 110.0
        }
        
        
        
        
    }
    
    //MARK: - Создание ячеек
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && MainViewController.searching == false {
            if let cellSeg = tableView.dequeueReusableCell(withIdentifier: segmentCell) as? SegmentCell {
                return cellSeg
                
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: iPhoneCell, for: indexPath) as? TransportViewCell {
            switch MainViewController.searching {
            case true:
                switch indexPath.section {
                case 0:
                    let item = arrayForSearchingTram[indexPath.row]
                    cell.refreshTram(model: item)
                case 1:
                    let item = arrayForSearchingBus[indexPath.row]
                    cell.refreshBus(model: item)
                default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                }
                return cell
            case false:
                switch MainViewController.segmentStatus {
                case .all:
                    switch indexPath.section {
                    case 0: break
                    case 1:
                        let item = TransportData.dataTram[indexPath.row]
                        cell.refreshTram(model: item)
                    case 2:
                        let item = TransportData.dataBus[indexPath.row]
                        cell.refreshBus(model: item)
                    default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                    }
                    return cell
                case .tram:
                    switch indexPath.section {
                    case 0: break
                    case 1:
                        let item = TransportData.dataTram[indexPath.row]
                        cell.refreshTram(model: item)
                    case 2: break
                    default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                    }
                    return cell
                case .bus:
                    switch indexPath.section {
                    case 0: break
                    case 1:
                        let item = TransportData.dataBus[indexPath.row]
                        cell.refreshBus(model: item)
                    case 2: break
                    default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    //MARK: - Нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch MainViewController.searching {
        case true:
            switch indexPath.section {
            case 0:
                MainViewController.nameStation = arrayForSearchingTram[indexPath.row].nameStation
                MainViewController.secondName = arrayForSearchingTram[indexPath.row].secondName
                MainViewController.linkStation = arrayForSearchingTram[indexPath.row].link
                MainViewController.typeStation = indexPath.section
            case 1:
                MainViewController.nameStation = arrayForSearchingBus[indexPath.row].nameStation
                MainViewController.secondName = arrayForSearchingBus[indexPath.row].secondName
                MainViewController.linkStation = arrayForSearchingBus[indexPath.row].link
                MainViewController.typeStation = indexPath.section
            default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
            }
        case false:
            switch MainViewController.segmentStatus {
            case .all:
                switch indexPath.section {
                case 1:
                    MainViewController.nameStation = TransportData.dataTram[indexPath.row].nameStation
                    MainViewController.secondName = TransportData.dataTram[indexPath.row].secondName
                    MainViewController.linkStation = TransportData.dataTram[indexPath.row].link
                    MainViewController.typeStation = indexPath.section - 1
                case 2:
                    MainViewController.nameStation = TransportData.dataBus[indexPath.row].nameStation
                    MainViewController.secondName = TransportData.dataBus[indexPath.row].secondName
                    MainViewController.linkStation = TransportData.dataBus[indexPath.row].link
                    MainViewController.typeStation = indexPath.section - 1
                default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                }
            case .tram:
                switch indexPath.section {
                case 1:
                    MainViewController.nameStation = TransportData.dataTram[indexPath.row].nameStation
                    MainViewController.secondName = TransportData.dataTram[indexPath.row].secondName
                    MainViewController.linkStation = TransportData.dataTram[indexPath.row].link
                    MainViewController.typeStation = indexPath.section - 1
                default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                }
            case .bus:
                switch indexPath.section {
                case 1:
                    MainViewController.nameStation = TransportData.dataBus[indexPath.row].nameStation
                    MainViewController.secondName = TransportData.dataBus[indexPath.row].secondName
                    MainViewController.linkStation = TransportData.dataBus[indexPath.row].link
                    MainViewController.typeStation = indexPath.section
                default: print(ErrorInSwitch.defaultErrorInSwitch.rawValue)
                }
            }
        }
        MainViewController.isFavoriteDetail = false

        if MainViewController.searching == false && indexPath.section == 0 { } else {
            print(MainViewController.nameStation)
            print(MainViewController.secondName)
            print(MainViewController.linkStation)
            print(MainViewController.typeStation)
            let pushViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
            navigationController?.pushViewController(pushViewController!, animated: true)
        }
        
    }
}

//MARK:- UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        MainViewController.searching = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.arrayForSearchingTram = SearchManager.newSearch(searchText, array: TransportData.dataTram)
            self.arrayForSearchingBus = SearchManager.newSearch(searchText, array: TransportData.dataBus)
            self.mainTableView.reloadData()
        })

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        MainViewController.searching = false
        mainTableView.reloadData()
    }
}

