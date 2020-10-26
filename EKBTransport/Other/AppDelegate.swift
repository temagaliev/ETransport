//
//  AppDelegate.swift
//  EKBTransport
//
//  Created by Артем Галиев on 06.04.2020.
//  Copyright © 2020 Артем Галиев. All rights reserved.
//


import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Оформление темы
        interfaceTheme()
        
        //CoreData
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        print(urls[urls.count - 1] as URL)
        saveContext()
        
        FirebaseApp.configure()
        
 //       In app purchases
        IAPManager.shared.setupPurcheses { (succes) in
            if succes {
                print("can products")
                IAPManager.shared.getProducts()
            }
        }
        
        if let checkSub = UserDefaults.standard.object(forKey: KeyForSave.isSubWasActive.rawValue) {
            IAPManager.isSubWasActive = checkSub as! Bool
        }
        
        if IAPManager.isSubWasActive {
            print("check sub in now")
            IAPManager.shared.checkSubscriptionExpirationDate()
        } else {
            print("check bad try")
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    //MARK: - Создание контейнера
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransportCDModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Проверка подписки
    
    //MARK: -  Загрузка цветового интерфейса 
    func interfaceTheme() {
        var nameThemeType: String = SegmentTheme.light.rawValue

        if let theme = UserDefaults.standard.object(forKey: KeyForSave.theme.rawValue) {
            nameThemeType = theme as! String

            switch nameThemeType {
            case SegmentTheme.dark.rawValue:
                UIApplication.shared.windows.forEach { (window) in
                    if #available(iOS 13.0, *) {
                        window.overrideUserInterfaceStyle = .dark
                    }
                }
            case SegmentTheme.light.rawValue:
                UIApplication.shared.windows.forEach { (window) in
                    if #available(iOS 13.0, *) {
                        window.overrideUserInterfaceStyle = .light
                    }
                }
            default: print("error")
            }
        } else {
            UIApplication.shared.windows.forEach { (window) in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }
}





