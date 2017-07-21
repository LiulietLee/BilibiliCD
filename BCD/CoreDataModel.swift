//
//  CoreDataModel.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreData

class CoreDataModel {
    
    fileprivate let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    fileprivate let PermFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Permission")
    fileprivate let HistFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
    
    fileprivate func saveContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    // MARK: - AD
    
    func readAdPremission() -> Bool? {
        do {
            let searchResults = try context.fetch(PermFetchRequest)
            if searchResults.count == 0 {
                return nil
            }
            
            let per = (searchResults as! [NSManagedObject])[0].value(forKey: "adPerm") as! Bool
            return per
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func setAdPremissionWith(_ per: Bool) {
        clearAdPermission()
        
        let entity = NSEntityDescription.entity(forEntityName: "Permission", in: context)
        let permission = NSManagedObject(entity: entity!, insertInto: context)
        permission.setValue(per, forKey: "adPerm")
        saveContext()
    }
    
    fileprivate func clearAdPermission() {
        do {
            let searchResults = try context.fetch(PermFetchRequest)
            for object in (searchResults as! [NSManagedObject]) {
                context.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - History
    
    func getHistory() -> [History] {
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
    
    func deleteHistory(item: History) {
        context.delete(item)
        saveContext()
    }
    
    func clearHistory() {
        do {
            let items = try context.fetch(HistFetchRequest) as! [History]
            for item in items {
                deleteHistory(item: item)
            }
        } catch {
            print(error)
        }
    }
    
}
