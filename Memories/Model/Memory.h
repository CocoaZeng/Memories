//
//  Memory.h
//  Memories
//
//  Created by Zeng Wang on 4/28/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Trip;

@interface Memory : NSManagedObject

@property (nonatomic, retain) NSString *memoryURL;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSNumber * lattitude;
@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) Account *account;

@end