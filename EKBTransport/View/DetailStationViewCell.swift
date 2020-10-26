//
//  DetailStationViewCell.swift
//  EKBTransport
//
//  Created by Артем Галиев on 23.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

class DetailStationViewCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var numberTransportLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var circleColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerView.layer.cornerRadius = 20
        cornerView.layer.masksToBounds = false
        circleColorView.layer.cornerRadius = circleColorView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Заполнение ячейки с информацией о транспорте
    func refreshDetail(model: ItemStation) {
        numberTransportLabel.text = model.numberTransport
        timeLabel.text = model.timeTransport
        distanceLabel.text = model.distanceTransport
        let time = String(model.timeTransport.replacingOccurrences(of: " мин", with: ""))
        if  Int(time)! >= 8 {
            circleColorView.backgroundColor = #colorLiteral(red: 0, green: 0.8655427098, blue: 0.06802584976, alpha: 1)
        } else if (4 <= Int(time)! && Int(time)! < 8) {
            circleColorView.backgroundColor = #colorLiteral(red: 1, green: 0.545410037, blue: 0.03123589419, alpha: 1)
        } else if 4 > Int(time)! {
            circleColorView.backgroundColor = #colorLiteral(red: 0.9743875861, green: 0.1581939757, blue: 0.05981228501, alpha: 1)
        }
    }
}
