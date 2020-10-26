//
//  Search Manager.swift
//  EKBTransport
//
//  Created by Артем Галиев on 22.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import Foundation

class SearchManager {
    //MARK:- Метод поиска
    static func newSearch(_ newSearchText: String, array: [Transport]) -> [Transport] {
        var arrayForSearchBar: [Transport] = []
        if array.count != 0 {
            let searchText = newSearchText.lowercased()
            for i in 0...array.count - 1 {
                let searchResultFromArray = createCharter(array[i].nameStation, searchText.count)
                let seatchResultSearchName = createCharter(array[i].searchName ?? "'", searchText.count)
                if (searchResultFromArray == searchText) || (seatchResultSearchName == searchText) {
                    arrayForSearchBar.append(array[i])
                } else {
                    print("Not \(array[i].nameStation)")
                }
            }
        }
        return arrayForSearchBar
    }

    //фильтрация текста 
    static func createCharter(_ text: String, _ number: Int) -> String {
        let textCharter = text.prefix(number)
        return String(textCharter).lowercased()
    }
}
