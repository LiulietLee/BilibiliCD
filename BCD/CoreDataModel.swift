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

    func readAdPremission() -> Bool? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Permission")
        do {
            let searchResults = try context.fetch(fetchRequest)
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
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    fileprivate func clearAdPermission() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Permission")
        do {
            let searchResults = try context.fetch(fetchRequest)
            for object in (searchResults as! [NSManagedObject]) {
                context.delete(object)
            }
        } catch {
            print(error)
        }
    }
    
}
