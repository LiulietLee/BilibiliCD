//
//  History+CoreDataProperties.swift
//  
//
//  Created by Liuliet.Lee on 21/7/2017.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var av: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var up: String?
    @NSManaged public var url: String?

}
