//
//  CDManager.swift
//  EKBTransport
//
//  Created by Артем Галиев on 27.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//

import UIKit
import CoreData


class CDManager {
    
    static var context: NSManagedObjectContext!
    
    //MARK: - Добавление данных в хранилище
    static func addTransportStation(name: String, link: String, type: Int16, secondName: String) -> TransportCDModel {
        let transportCDModel = TransportCDModel(context: context)
        transportCDModel.typeStation = type
        transportCDModel.nameStation = name
        transportCDModel.linkStation = link
        transportCDModel.secondName = secondName
        do {
            try context.save()
        } catch {
            fatalError("Could not save \(error)")
        }
        
        return transportCDModel
    }
    
    //MARK: - Получение данных из БД
    static func fetchRequestTransportCDModel() -> [TransportCDModel] {
        let fetchRequest: NSFetchRequest<TransportCDModel> = TransportCDModel.fetchRequest()
        
        var list: [TransportCDModel]
        
        do {
            list = try context.fetch(fetchRequest)
        } catch  {
            fatalError("Fatching Falied")
        }
        list.reverse()
        return list
    }
    
    //MARK: - Реализация контекста
    static func releaseCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else  {
            fatalError("appdelegate error")
        }
        context = appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - Удаление всех данных
    static func deletedAllData() {
        let currnetArray = fetchRequestTransportCDModel()
        if currnetArray.count != 0 {
            for i in 1...currnetArray.count {
                let item: NSManagedObject = currnetArray[i-1] as NSManagedObject
                context.delete(item)
                try? context.save()
            }
        }
    }
}
