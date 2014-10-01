//
//  Account.h
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memory, Trip;

@interface ImageToDataTransformer : NSValueTransformer
@end

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString *accountName;
@property (nonatomic, retain) NSString *profileURL;
@property (nonatomic, retain) NSSet *trips;
@property (nonatomic, retain) NSSet *memories;
@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

- (void)addMemoriesObject:(Memory *)value;
- (void)removeMemoriesObject:(Memory *)value;
- (void)addMemories:(NSSet *)values;
- (void)removeMemories:(NSSet *)values;

@end
