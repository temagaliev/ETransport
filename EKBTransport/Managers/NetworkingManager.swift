//
//  Networking Manager.swift
//  EKBTransport
//
//  Created by Артем Галиев on 07.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation
import Kanna

public class NetworkingManager {
    //MARK: - Получение данных и фильтрация их
    static func gettingDataFromHTML(url urlAdress: String, completion: @escaping([ItemStation]) -> Void)  {
        var array: [String] = []
        let myURLAdress = urlAdress
        guard let url = URL(string: myURLAdress) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotifiKey.connectionError.rawValue), object: nil)
                return
            }
            let myString = String(data: data!, encoding: String.Encoding.utf8)
            
            if let doc = try? HTML(html: myString!, encoding: .utf8) {
                
                for div in doc.css("div, style") {
                    let text = div.text!
                    var result = text.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "        ", with: "").split(separator: " ")
                    
                    result.removeFirst(5)
                    result.removeLast(4)

                    for i in 1...result.count {
                        array.append(String(result[i-1]))
                    }
                    var currentArray: [ItemStation] = []
                    currentArray = resultProcessing(arr: array)
                    completion(currentArray)
                    break
                }
                
            }
        }.resume()
    }
    
    //MARK: - Конечная сортировка массива, конвертация данных в модель
    static func resultProcessing(arr myArray: [String]) -> [ItemStation] {
        print("start array \(myArray)")
        var array = myArray
        var currentValue: Int = 0

        for item in 0...array.count - 1 {
            if (array[item].count == 5) || (array[item].count == 4) {
                for i in array[item] {
                    if i == ":" {
                        print("item is \(item)")
                        currentValue = item + 1
                        break
                    }
                }
            }
        }
        print("currentValue is \(currentValue)")
        array.removeFirst(currentValue)
        
        print("after remove array is \(array)")

        if array[0] == "Нет" {
            NotificationCenter.default.post(name: NSNotification.Name(NotifiKey.isNonData.rawValue), object: nil)
        }
        var currentArray: [ItemStation] = []
        var arrayCount = array.count / 5

        if arrayCount != 0 {
            while arrayCount != 0 {
                if array.count % 5 == 0 {
                    //print("array.count % 5 == 0 is \(array.count % 5 == 0)")
                    for _ in 0...4 {
                        let item: ItemStation = ItemStation(numberTransport: array[0], timeTransport: array[1] + " " + array[2], distanceTransport: array[3] + " " + array[4])
                        currentArray.append(item)
                        break
                    }
                }
                arrayCount = arrayCount - 1
                array.removeFirst(5)
            }
        }
        return currentArray
    }
}

