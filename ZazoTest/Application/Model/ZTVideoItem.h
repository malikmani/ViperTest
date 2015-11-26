//
//  ZTVideoItem.h
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZTVideoItem : NSObject

@property (strong, retain) NSString *name;
@property (strong, retain) NSDate *date;
@property (strong, retain) NSNumber *duration;
@property (strong, retain) NSString *localPath;
@property (strong, retain) NSString *serverPath;

@end
