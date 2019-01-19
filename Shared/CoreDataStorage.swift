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
    
    // MARK: - Core Data Saving support
    
    public func saveContext(_ context: NSManagedObjectContext?) {
        if let moc = context, moc.hasChanges {
            try? moc.save()
        }
    }
    
    // MARK: - Core Data stack
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "BCD", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private let migrationOptions = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: urlInContainer, options: migrationOptions)
        } catch {
            fatalError("Unresolved error \(error), \(String(describing: error._userInfo))")
        }
        return coordinator
    }()
    
    // MARK: - NSManagedObject Contexts
    
    /// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application).
    public private(set) lazy var mainQueueContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    /// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application).
    private lazy var privateQueueContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
}

//import UIKit

extension CoreDataStorage {
    private static let name = "BCD.sqlite"
    
    var urlInContainer: URL {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Future-Code-Institute.bili_cita_group")!
        let url = directory.appendingPathComponent(CoreDataStorage.name)
        return url
    }
    
    var urlInDocuments: URL {
        return applicationDocumentsDirectory.appendingPathComponent(CoreDataStorage.name)
    }
    
    /// The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's documents Application Support directory.
    private var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}

#if canImport(MaterialKit)
import MaterialKit

func show(_ error: Error) {
    var message = error.localizedDescription
    if let exception = error._userInfo?["NSUnderlyingException"] as? NSException,
        let reason = exception.reason {
        message += "(\(reason))"
    }
    show(message)
}

func show(_ message: String) {
    print(message)
    #warning("Snackbar not showing???")
    MKSnackbar(withTitle: message, withDuration: nil, withTitleColor: nil, withActionButtonTitle: nil, withActionButtonColor: nil).show()
}

extension CoreDataStorage {
    func saveCoreDataModelToDocuments() {
        do {
            #warning("Not really working")
            try persistentStoreCoordinator.migratePersistentStore(persistentStoreCoordinator.persistentStore(for: urlInContainer)!, to: urlInDocuments, options: nil, withType: NSSQLiteStoreType)
            show("Export Complete")
        } catch {
            show(error)
        }
    }
    
    func replaceCoreDataModelWithOneInDocuments() {
        if FileManager.default.fileExists(atPath: urlInDocuments.path) {
            do {
                try persistentStoreCoordinator.remove(persistentStoreCoordinator.persistentStore(for: urlInContainer)!)
                try persistentStoreCoordinator.replacePersistentStore(at: urlInContainer, destinationOptions: nil, withPersistentStoreFrom: urlInDocuments, sourceOptions: nil, ofType: NSSQLiteStoreType)
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: urlInContainer, options: migrationOptions)
                show("Import Complete")
            } catch {
                show(error)
            }
        } else {
            show("Nothing to Import")
        }
    }
}
#endif
