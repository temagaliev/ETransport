//
//  AlertView.swift
//  EKBTransport
//
//  Created by Артем Галиев on 06.05.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

//MARK: - AlertDelegate
protocol AlertDelegate: AnyObject {
    func leftButtonAction()
    func rightButtonAction()
}

//MARK: - class AlertView
class AlertView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var visualEffectView = UIVisualEffectView()
    
    weak var alertDelegate: AlertDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 30
        leftButton.layer.cornerRadius = 20
        rightButton.layer.cornerRadius = 20

    }
    
    //MARK: - Заполнение текстом
    func set(title: String, leftButtonTitle: String, rightButtonTitle: String, hiddenLeftButton: Bool) {
        titleLabel.text = title
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        leftButton.isHidden = hiddenLeftButton
    }
    
    //MARK: - Визуальный эффект
    func addVisualEffectView(view: UIView) {
        let blurEffect = checkCurrentTheme()
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.alpha = 0.3
        
    }
    
    //MARK: - Удаление визуального эффекта
    func removeVisualEffectView(view: UIView) {
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffectView.alpha = 0
        visualEffectView.removeFromSuperview()
        
    }
    
    //MARK: - Проверка текущей темы
    func checkCurrentTheme() -> UIBlurEffect {
        var nameThemeType: String = SegmentTheme.light.rawValue
        
        if let theme = UserDefaults.standard.object(forKey: KeyForSave.theme.rawValue) {
            nameThemeType = theme as! String
            switch nameThemeType {
            case SegmentTheme.dark.rawValue: return UIBlurEffect(style: .dark)
            case SegmentTheme.light.rawValue: return UIBlurEffect(style: .light)
            default: return UIBlurEffect(style: .light)
            }
        } else { return UIBlurEffect(style: .light) }
    }
    
    //MARK: - Actions кнопок
    @IBAction func rightActionButton(_ sender: UIButton) {
        alertDelegate?.rightButtonAction()
    }
    @IBAction func leftActionButton(_ sender: UIButton) {
        alertDelegate?.leftButtonAction()
    }
}

//MARK: - loadfromNib
extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}


