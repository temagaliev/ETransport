//
//  FavoritesViewCell.swift
//  EKBTransport
//
//  Created by Артем Галиев on 27.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit

class FavoritesViewCell: UITableViewCell {

    @IBOutlet weak var colorNameLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var nameStationLabel: UILabel!
    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerView.layer.cornerRadius = 20
        cornerView.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Заполнение ячейки о избранных
    func refreshFavorites(model: TransportCDModel) {
        nameStationLabel.text = model.nameStation
        switch model.typeStation {
        case 0: colorView.backgroundColor = #colorLiteral(red: 0.8764405847, green: 0.2356418073, blue: 0.2189298272, alpha: 1)
        case 1: colorView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        case 3: colorView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        default:
            colorView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.frame.width / 2
        }
        let string = (model.nameStation)?.first
        colorNameLabel.text = String(string!)
    }
}
