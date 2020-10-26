//
//  SettingsViewController.swift
//  EKBTransport
//
//  Created by Артем Галиев on 04.05.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//
//MARK: - SettingsViewController
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var segmentStart: UISwitch!
    @IBOutlet weak var subscriptionButton: UIButton!
    @IBOutlet weak var warningVersionLabel: UILabel!
    @IBOutlet weak var mainSegment: UISegmentedControl!
    private let errorInSegmentTheme: String = "error in segment theme"
    let device = UIDevice()
    
    private lazy var alertView: AlertView = {
        let alertView: AlertView = AlertView.loadFromNib()
        alertView.alertDelegate = self
        return alertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Подписка активна - \(IAPManager.isInAppPurchases)")
        if #available(iOS 13.0, *) {
            mainSegment.isHidden = false
            warningVersionLabel.isHidden = true
        } else {
            mainSegment.isHidden = true
            warningVersionLabel.isHidden = false
        }
        currentSegmentIndex()
        gettingResponseFromUserDefaults()
        startSettingsForSwitchPaidContent() 
        subscriptionButton.layer.cornerRadius = 10
    }

    //MARK: - IBAction нажатие на switch
    @IBAction func tappedSegmentStartAction(_ sender: UISwitch) {
        if IAPManager.isInAppPurchases == false {
            segmentStart.setOn(false, animated: true)
            setAlert(title: "Дополнительный функционал выбора стартового экрана, является платным контентом, перейти на страницу подписок?", leftButtonTitle: "Перейти", rightButtonTitle: "Отмена", hiddenLeftButton: false)
        } else {
            switch sender.isOn {
            case true:  UserDefaults.standard.set(true, forKey: KeyForSave.startVC.rawValue)
            case false: UserDefaults.standard.set(false, forKey: KeyForSave.startVC.rawValue)
            }
        }
    }
    
    //MARK: - Получение данных из UD для switch
    private func gettingResponseFromUserDefaults() {
        var currentStatus: Bool = false
        if let switchStatus = UserDefaults.standard.object(forKey: KeyForSave.startVC.rawValue) {
            currentStatus = switchStatus as! Bool
            switch currentStatus {
            case true: segmentStart.isOn = true
            case false: segmentStart.isOn = false
            }
        }
    }
    
    //MARK: - Найстройки alert
    private func setAlert(title titleString: String, leftButtonTitle leftButtonTitleString: String, rightButtonTitle rightButtonString: String, hiddenLeftButton hiddenButtonBool: Bool) {
        alertView.addVisualEffectView(view: self.view)
        view.addSubview(alertView)
        alertView.center = view.center
        alertView.set(title: titleString, leftButtonTitle: leftButtonTitleString, rightButtonTitle: rightButtonString, hiddenLeftButton: hiddenButtonBool)
        alertView.layer.cornerRadius = 50
        alertView.layer.shadowOpacity = 0.2
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOffset = CGSize.zero
        alertView.layer.shadowRadius = 5
        alertView.alertDelegate = self

    }
    
    //MARK: - Настройки отображения сигмена при отсутсвии подписки
    private func startSettingsForSwitchPaidContent() {
        if IAPManager.isInAppPurchases == false {
            segmentStart.setOn(false, animated: true)
        }
    }
    
    //MARK: - Выбор index сегмента
    private func currentSegmentIndex() {
        if let segment = UserDefaults.standard.object(forKey: KeyForSave.segment.rawValue) {
            mainSegment.selectedSegmentIndex = segment as! Int
        } else {
            mainSegment.selectedSegmentIndex = 0
        }
    }

    //MARK: -  @IBAction
    @IBAction func settingsButton(_ sender: UIBarButtonItem) {
        let pushViewController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController")
        navigationController?.present(pushViewController!, animated: true, completion: nil)
    }
    
    @IBAction func subscriptionAction(_ sender: UIButton) {
        //fatalError()
        let pushViewController = storyboard?.instantiateViewController(withIdentifier: "PurchasesViewController")
        navigationController?.present(pushViewController!, animated: true, completion: nil)
        
        
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch mainSegment.selectedSegmentIndex {
        case 0:
            UIApplication.shared.windows.forEach { (window) in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .light
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotifiKey.lightInterface.rawValue), object: nil)
                }
            }
            UserDefaults.standard.setValue(SegmentTheme.light.rawValue, forKey: KeyForSave.theme.rawValue)
            UserDefaults.standard.set(mainSegment.selectedSegmentIndex, forKey: KeyForSave.segment.rawValue)
        case 1:
            UIApplication.shared.windows.forEach { (window) in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .dark
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotifiKey.darkInterface.rawValue), object: nil)
                }
            }
            UserDefaults.standard.setValue(SegmentTheme.dark.rawValue, forKey: KeyForSave.theme.rawValue)
            UserDefaults.standard.set(mainSegment.selectedSegmentIndex, forKey: KeyForSave.segment.rawValue)

        default: print(errorInSegmentTheme)
        }
    }
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: - AlertDelegate
extension SettingsViewController: AlertDelegate {
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
