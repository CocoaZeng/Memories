//
//  Trip.h
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Memory;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * tripDescription;
@property (nonatomic, retain) NSString * tripEndDate;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSString * tripStartDate;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) NSSet *memories;
@property (nonatomic, retain) NSString *tripProfileURL;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addMemoriesObject:(Memory *)value;
- (void)removeMemoriesObject:(Memory *)value;
- (void)addMemories:(NSSet *)values;
- (void)removeMemories:(NSSet *)values;

@end
