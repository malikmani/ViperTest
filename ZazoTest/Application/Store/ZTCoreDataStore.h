//
//  ZTCoreDataStore.h
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^ZTDataStoreFetchCompletionBlock)(NSArray *results);

@class ZTManagedVideoItem;

@interface ZTCoreDataStore : NSObject

- (void)fetchDataWithEntityName:(NSString *)entityName
                      predicate:(NSPredicate *)predicate
                sortDescriptors:(NSArray *)sortDescriptors
                     fetchLimit:(NSUInteger )fetchLimit
                completionBlock:(ZTDataStoreFetchCompletionBlock)completionBlock;
- (void)save;
- (void)removeObject:(NSManagedObject *)object;

- (ZTManagedVideoItem *)newVideoItem;

@end
