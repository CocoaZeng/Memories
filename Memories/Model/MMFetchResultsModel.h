//
//  MMFetchResultsModel.h
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Account.h"

@interface MMFetchResultsModel : NSObject

@property (strong, nonatomic) Account *account;
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) NSFetchedResultsController* tripFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController* memoryFetchedResultsController;

- (long)numberOfTrips;
- (long)numberOfMemories;
- (long)numberOfLocations;
- (long)numberOfLocationsForTrip:(Trip *)trip;
- (long)numberOfMemoriesForTrip:(Trip *)trip;
//- (NSArray *)fetchTrips:(Account *)account;
//- (NSArray *)fetchMemories:(Trip *)trip;
@end
