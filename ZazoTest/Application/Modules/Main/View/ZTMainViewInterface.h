//
//  ZTMainViewInterface.h
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZTMainViewInterface <NSObject>

- (void)requestingCameraAndMicrophonePermission;
- (void)formattingPreviewCells;

- (void)loadVideoItemsInPreviews:(NSArray *)videoItemsArray;
- (void)removeVideoEntriesFromView;

@end
