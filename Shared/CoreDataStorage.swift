//
//  CoreDataStorage.swift
//  TutorialAppGroup
//
//  Created by Maxim on 10/18/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

import CoreData
import Foundation

final class CoreDataStorage {
    
    // MARK: - Shared Instance
    
    public static let sharedInstance = CoreDataStorage()
    
    // MARK: - Initialization
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSavePrivateQueueContext(_:)), name: .NSManagedObjectContextDidSave, object: privateQueueContext)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveMainQueueContext(_:)), name: .NSManagedObjectContextDidSave, object: mainQueueContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notifications
    
    @objc func contextDidSavePrivateQueueContext(_ notification: Notification) {
        synced {
            self.mainQueueContext.perform {
                self.mainQueueContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    @objc func contextDidSaveMainQueueContext(_ notification: Notification) {
        synced {
            self.privateQueueContext.perform {
                self.privateQueueContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    private func synced(_ lock: AnyObject = CoreDataStorage.sharedInstance, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    // MARK: - Core Data stack
    
    private lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "BCD", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Future-Code-Institute.bilibilicdgroup")!
        let url = directory.appendingPathComponent("BCD.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            fatalError("Unresolved error \(error), \(String(describing: error._userInfo))")
        }
        return coordinator
    }()
    
    // MARK: - NSManagedObject Contexts
    public private(set) lazy var mainQueueContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var privateQueueContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext(_ context: NSManagedObjectContext?) {
        if let moc = context, moc.hasChanges {
            try? moc.save()
        }
    }
    
}
