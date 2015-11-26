//
//  ZTMainInteracter.m
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTMainInteracter.h"

#import "ZTMainDataManager.h"
#import "ZTVideoItem.h"

@interface ZTMainInteracter ()

@property (nonatomic, strong) ZTMainDataManager *mainDataManager;

@end

@implementation ZTMainInteracter

- (id)init
{
    if ((self = [super init]))
    {
        [self configureInteracter];
    }
    
    return self;
}

-(void) configureInteracter
{
    _mainDataManager = [[ZTMainDataManager alloc] init];
}

- (BOOL)saveVideoEntryWithName:(NSString *)name date:(NSDate *)date duration:(NSNumber *)duration serverPath:(NSString *)serverPath localPath:(NSString *)localPath
{
    ZTVideoItem *newVideoItem = [[ZTVideoItem alloc] init];
    newVideoItem.name = name;
    newVideoItem.date = date;
    newVideoItem.duration = duration;
    newVideoItem.serverPath = serverPath;
    newVideoItem.localPath = localPath;
    __block BOOL returnValue = YES;
    [_mainDataManager addNewVideoItemEntry:newVideoItem withCompletionBlock:^(BOOL result) {
        returnValue = result;
    }];
    
    return returnValue;
}

- (void)fetchVideoEntries
{
    [_mainDataManager fetchVideoEntriesWithCompletionBlock:^(NSArray *results) {
        [self.output loadVideoItemsInPreviews:results];
    }];
}
//elimanate
- (void)removeVideoEntries
{
    [_mainDataManager removeAllVideoEntriesWithCompletionBlock:^(BOOL result) {
        if (result) {
            [self.output removeVideoEntriesFromView];
        }
    }];
    
}

@end
