//
//  CoreDataModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataModel {
    
    fileprivate let context = CoreDataStorage.mainQueueContext()
    fileprivate let PermFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Permission")
    fileprivate let HistFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
    fileprivate let SettFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setting")
    
    fileprivate func saveContext() {
        CoreDataStorage.saveContext(self.context)
    }
    
    // MARK: - History
    
    func refreshHistory() {
        if let limit = historyNum {
            checkHistoryNumLimit(limit)
        }
    }
    
    var history: [History] {
        var items = [History]()
        
        let sort = NSSortDescriptor(key: #keyPath(History.date), ascending: true)
        HistFetchRequest.sortDescriptors = [sort]
        
        do {
            items = try context.fetch(HistFetchRequest) as! [History]
            items = items.reversed()
        } catch {
            print(error)
        }
        
        return items
    }
    
    func addNewHistory(av: String, date: NSDate, image: NSData, title: String, up: String, url: String) {
        refreshHistory()

        let list = history
        if list.count != 0, list[0].up == up && list[0].title == title { return }
        
        let entity = NSEntityDescription.entity(forEntityName: "History", in: context)!
        let newItem = History(entity: entity, insertInto: context)
        newItem.av = av
        newItem.date = date
        newItem.image = image
        newItem.title = title
        newItem.up = up
        newItem.url = url
        saveContext()
    }
    
    func deleteHistory(_ item: History) {
        context.delete(item)
        saveContext()
    }
    
    func clearHistory() {
        do {
            let items = try context.fetch(HistFetchRequest) as! [History]
            for item in items {
                deleteHistory(item)
            }
        } catch {
            print(error)
        }
    }
    
    private func checkHistoryNumLimit(_ limit: Int, history: [History]! = nil) {
        var list = history ?? self.history
        let count = list.count
        if count == 0 { return }
        let overflow = count - limit
        if overflow > 0 {
            for i in 0..<overflow {
                let lastestItem = list[count - 1 - i]
                deleteHistory(lastestItem)
            }
        }
    }
    
    // MARK: - Setting
    
    private func initSetting() {
        let initHistoryNum: Int16 = 6
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in: context)!
        let newItem = Setting(entity: entity, insertInto: context)
        newItem.historyNumber = initHistoryNum
        saveContext()
    }
    
    private var setting: Setting? {
        do {
            let searchResults = try context.fetch(SettFetchRequest)
            if searchResults.count == 0 {
                initSetting()
                return self.setting
            } else {
                return (searchResults[0] as! Setting)
            }
        } catch {
            print(error)
        }
        
        return nil
    }

    var historyNum: Int! {
        get {
            return Int(setting!.historyNumber)
        }
        set {
            setting?.historyNumber = Int16(newValue)
            saveContext()
        }
    }
}
