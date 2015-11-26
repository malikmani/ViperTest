//
//  ZTMainDataManager.m
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTMainDataManager.h"

#import "ZTManagedVideoItem.h"
#import "ZTCoreDataStore.h"
#import "ZTVideoItem.h"

@interface ZTMainDataManager ()

@property (nonatomic, strong) ZTCoreDataStore *dataStore;

@end


@implementation ZTMainDataManager

- (id)init
{
    if ((self = [super init]))
    {
        [self configureDataManager];
    }
    
    return self;
}

- (void)configureDataManager
{
    _dataStore = [[ZTCoreDataStore alloc] init];
}

- (void)addNewVideoItemEntry:(ZTVideoItem *)entry withCompletionBlock:(ZTMainDataManagerBoolCompletionBlock)result
{
    
    //Before saving new video item entry we need to check wheter we have an existing video entry with same name
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",entry.name];
    
    [_dataStore fetchDataWithEntityName:@"VideoItem" predicate:predicate sortDescriptors:nil fetchLimit:0 completionBlock:^(NSArray *results) {
        
        ZTManagedVideoItem *videoEntry;
        if (results && [results count]) {
            //Video Item Exist
            videoEntry = (ZTManagedVideoItem *)[results firstObject];
            
            
        }else{
            videoEntry = [self.dataStore newVideoItem];
        }
        
        videoEntry.name = entry.name;
        videoEntry.date = entry.date;
        videoEntry.duration = entry.duration;
        videoEntry.serverPath = entry.serverPath;
        videoEntry.localPath = entry.localPath;
        
        [_dataStore save];
        if (result) {
            result(TRUE);
        }
    }];
}

- (void)fetchVideoEntriesWithCompletionBlock:(ZTMainDataManagerArrayCompletionBlock)completionBlock
{
    
 [_dataStore fetchDataWithEntityName:@"VideoItem" predicate:nil sortDescriptors:nil fetchLimit:0 completionBlock:^(NSArray *results) {
     
     NSMutableArray *videoItemsArray;
     if (results) {
         videoItemsArray = [[NSMutableArray alloc] init];
        
         for (ZTManagedVideoItem *entry in results) {
             
             ZTVideoItem *videoEntry = [[ZTVideoItem alloc] init];
             videoEntry.name = entry.name;
             videoEntry.date = entry.date;
             videoEntry.duration = entry.duration;
             videoEntry.serverPath = entry.serverPath;
             videoEntry.localPath = entry.localPath;
             
             [videoItemsArray addObject:videoEntry];
         }
     }
     
     if (completionBlock) {
         completionBlock(videoItemsArray);
     }
     
 }];
    
}

- (void)removeAllVideoEntriesWithCompletionBlock:(ZTMainDataManagerBoolCompletionBlock)result
{
    //remove all video entries
    [_dataStore fetchDataWithEntityName:@"VideoItem" predicate:nil sortDescriptors:nil fetchLimit:0 completionBlock:^(NSArray *results) {
        
        if (results && [results count]) {
            //Video Item Exist
            for (ZTManagedVideoItem *videoEntry in results) {
                [_dataStore removeObject:videoEntry];
            }
            
        }
        
        [_dataStore save];
        
        if (result) {
            result(TRUE);
        }
    }];
    
}

@end
