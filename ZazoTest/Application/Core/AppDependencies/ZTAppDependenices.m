//
//  ZTAppDependenices.m
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTAppDependenices.h"

#import <UIKit/UIKit.h>

#import "ZTCoreDataStore.h"

#import "ZTMainPresenter.h"

@interface ZTAppDependenices ()

@property (strong, nonatomic) ZTCoreDataStore *dataStore;

@end

@implementation ZTAppDependenices

- (id)init
{
    if ((self = [super init]))
    {
        [self configureDependencies];
    }
    
    return self;
}

- (void)configureDependencies
{
    // Initializing
    ZTCoreDataStore *dataStore = [[ZTCoreDataStore alloc] init];
    
    self.dataStore = dataStore;
}

- (void)initialApplicationSetup:(UIApplication *)application launchOptions:(NSDictionary *)options
{
    
}

- (void)handleApplicationDidBecomeActive
{
    
}

- (void)handleApplicationWillTerminate:(UIApplication *)application
{
    [self.dataStore save];
}

@end
