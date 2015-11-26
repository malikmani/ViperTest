//
//  ZTCoreDataStore.m
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTCoreDataStore.h"

#import "ZTManagedVideoItem.h"

@interface ZTCoreDataStore ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation ZTCoreDataStore

- (id)init
{
    if ((self = [super init]))
    {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error = nil;
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"ZazoTest.sqlite"];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options error:&error];
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _managedObjectContext.undoManager = nil;
        
    }
    
    return self;
}


- (void)fetchDataWithEntityName:(NSString *)entityName
                      predicate:(NSPredicate *)predicate
                sortDescriptors:(NSArray *)sortDescriptors
                     fetchLimit:(NSUInteger )fetchLimit
                completionBlock:(ZTDataStoreFetchCompletionBlock)completionBlock
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    if (sortDescriptors) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    if (fetchLimit) {
      [fetchRequest setFetchLimit:fetchLimit];
    }
    [self.managedObjectContext performBlock:^{
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        
        if (completionBlock)
        {
            completionBlock(results);
        }
    }];
}

- (ZTManagedVideoItem *)newVideoItem
{

    ZTManagedVideoItem *newEntry = (ZTManagedVideoItem *)[self newEntityWithName:@"VideoItem"];
    
    return newEntry;
}

- (id)newEntityWithName:(NSString *)name;
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:name
                                                         inManagedObjectContext:self.managedObjectContext];
    ZTManagedVideoItem *newEntry = (ZTManagedVideoItem *)[[NSManagedObject alloc] initWithEntity:entityDescription
                                                                  insertIntoManagedObjectContext:self.managedObjectContext];
    
    return newEntry;
}

- (void)save
{
    [self.managedObjectContext save:NULL];
}

- (void)removeObject:(NSManagedObject *)object
{
    [self.managedObjectContext deleteObject:object];
}


@end
