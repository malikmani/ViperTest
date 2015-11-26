//
//  ZTManagedVideoItem+CoreDataProperties.h
//  ZazoTest
//
//  Created by Usman Awan on 11/13/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZTManagedVideoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZTManagedVideoItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSString *localPath;
@property (nullable, nonatomic, retain) NSString *serverPath;

@end

NS_ASSUME_NONNULL_END
