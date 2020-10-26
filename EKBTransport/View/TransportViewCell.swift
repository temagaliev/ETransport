//
//  TransportViewCell.swift
//  EKBTransport
//
//  Created by Артем Галиев on 13.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

class TransportViewCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var nameStationLabel: UILabel!
    @IBOutlet weak var firstLetter: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerView.layer.cornerRadius = 20
        cornerView.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Заполнение ячеек под трамваи
    func refreshTram(model: Transport) {
        nameStationLabel.text = model.nameStation
        colorView.backgroundColor = #colorLiteral(red: 0.8764405847, green: 0.2356418073, blue: 0.2189298272, alpha: 1)
        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.frame.width / 2
        }
        let string = (model.nameStation).first
        firstLetter.text = String(string!)
    }
    
    //MARK: - Заполнение ячеек под троллейбусы
    func refreshBus(model: Transport) {
        nameStationLabel.text = model.nameStation
        colorView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.frame.width / 2
        }
        let string = (model.nameStation).first
        firstLetter.text = String(string!)
    }
}
