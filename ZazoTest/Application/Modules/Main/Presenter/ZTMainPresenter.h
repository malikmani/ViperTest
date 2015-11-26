//
//  ZTMainPresenter.h
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZTMainViewInterface.h"

#import "ZTMainInteracter.h"

typedef void(^ZTMainPresenterCompletionBlock)(NSArray *results);

@interface ZTMainPresenter : NSObject <ZTMainInteractorOutput>

- (void)configureUserInterfaceForPresentation:(id<ZTMainViewInterface>)mainViewUserInterface;

- (void)saveVideoEntryWithName:(NSString *)name date:(NSDate *)date duration:(NSNumber *)duration serverPath:(NSString *)serverPath localPath:(NSString *)localPath;

- (void)fetchVideoEntries;

- (void)removeAllVideoEntries;

@end
