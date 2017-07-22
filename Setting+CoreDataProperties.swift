//
//  Setting+CoreDataProperties.swift
//  
//
//  Created by Liuliet.Lee on 22/7/2017.
//
//

import Foundation
import CoreData


extension Setting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Setting> {
        return NSFetchRequest<Setting>(entityName: "Setting")
    }

    @NSManaged public var historyNumber: Int16

}
