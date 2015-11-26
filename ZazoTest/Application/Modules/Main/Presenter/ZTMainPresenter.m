//
//  ZTMainPresenter.m
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTMainPresenter.h"



@interface ZTMainPresenter()

@property ZTMainInteracter *mainInteracter;

@property id<ZTMainViewInterface> mainViewInterface;

@end

@implementation ZTMainPresenter


- (id)init
{
    if ((self = [super init]))
    {
        [self configurePresenter];
    }
    
    return self;
}

-(void) configurePresenter
{
    _mainInteracter = [[ZTMainInteracter alloc] init];
    _mainInteracter.output = self;
}

- (void)configureUserInterfaceForPresentation:(id<ZTMainViewInterface>)mainViewUserInterface
{
    _mainViewInterface = mainViewUserInterface;
    [_mainViewInterface requestingCameraAndMicrophonePermission];
    [_mainViewInterface formattingPreviewCells];
}

- (void)saveVideoEntryWithName:(NSString *)name date:(NSDate *)date duration:(NSNumber *)duration serverPath:(NSString *)serverPath localPath:(NSString *)localPath
{
    [_mainInteracter saveVideoEntryWithName:name date:date duration:duration serverPath:serverPath localPath:localPath];
}

- (void)fetchVideoEntries
{
    [_mainInteracter fetchVideoEntries];
}

- (void)removeAllVideoEntries
{
    [_mainInteracter removeVideoEntries];
}

-(void)loadVideoItemsInPreviews:(NSArray *)videoItems{
    [_mainViewInterface loadVideoItemsInPreviews:videoItems];
}

-(void)removeVideoEntriesFromView{
    [_mainViewInterface removeVideoEntriesFromView];
}

@end
