//
//  Permission+CoreDataProperties.swift
//  BCD
//
//  Created by Liuliet.Lee on 13/7/2017.
//  Copyright © 2017 Liuliet.Lee. All rights reserved.
//

import Foundation
import CoreData


extension Permission {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Permission> {
        return NSFetchRequest<Permission>(entityName: "Permission")
    }

    @NSManaged public var adPerm: Bool

}
