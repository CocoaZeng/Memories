//
//  MMFetchResultsModel.m
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMFetchResultsModel.h"
#import "constants.h"
#import "MMSharedClasses.h"
#import "Trip.h"
#import "Memory.h"
#import <MapKit/MapKit.h>

@interface MMFetchResultsModel()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation MMFetchResultsModel

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (long)numberOfTrips
{
    NSMutableArray *trips = [self.account valueForKey:@"trips"];
    if (trips == nil) {
        return 0;
    }
    else{
        return [trips count];
    }
}

- (long)numberOfMemories
{
    NSMutableArray *memories = [self.account valueForKey:@"memories"];
    if (memories == nil) {
        return 0;
    }
    else{
        return [memories count];
    }
}

- (long)numberOfLocations
{
    NSArray *locations = [self.account valueForKeyPath:@"memories.longtitude"];
    if (locations == nil || [locations count] == 0) {
        return 0;
    }
    else{
        return [locations count];
    }
}

- (long)numberOfMemoriesForTrip:(Trip *)trip
{
    NSMutableArray *memories = [trip valueForKey:@"memories"];
    if (memories == nil) {
        return 0;
    }
    else{
        return [memories count];
    }
}

- (long)numberOfLocationsForTrip:(Trip *)trip
{
    NSMutableArray *memories = [trip valueForKey:@"memories"];
    if (memories == nil) {
        return 0;
    }
    else {
        NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
        for (Memory* memory in memories)
        {
            CLLocation *newLocaton = [[CLLocation alloc] initWithLatitude:[memory.lattitude floatValue] longitude:[memory.longtitude floatValue]];
            if (![locationsArray containsObject:newLocaton]) {
                [locationsArray addObject:newLocaton];
            }
        }
        return [locationsArray count];
    }
}

- (Account *)account
{
    self.managedObjectContext = [[MMSharedClasses sharedClasses] managedObjectContext];
    if (_account == nil) {
        // Init account object
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:EntityAccount
                                                  inManagedObjectContext:self.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:EntityAccountSortKey ascending:NO];
        [request setEntity:entity];
        [request setSortDescriptors:@[sortDescriptor]];
        NSError *error;
        NSArray *accounts = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (accounts == nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        else if ([accounts count] == 0){
            Account *newAccount = [NSEntityDescription insertNewObjectForEntityForName:EntityAccount
                                                     inManagedObjectContext:self.managedObjectContext];
            self.account = newAccount;
            [[MMSharedClasses sharedClasses] saveManagedContext];
        }
        else{
            self.account = [accounts objectAtIndex:0];
        }
    }
    return _account;
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)createFetchedRequestControllerWithEntity:(NSString *)entityName
                                                  withSortDescriptorKey:(NSString *)sortKey
                                                    withPredicateFormat:(NSString *)predicateFormat
                                                    withPredicateObject:(id)object
{
    // Create the fetch results for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as approriate
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[MMSharedClasses sharedClasses].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as approriate
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the predicate as approriate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, object];
    [fetchRequest setPredicate:predicate];
    
    
    // Edit the section name key path and cache name if appropriate
    // nil for section name key path means "no sections"
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:Cachename];
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)tripFetchedResultsController
{
    if (_tripFetchedResultsController == nil) {
        NSString *predicateFormat = @"account == %@";
        self.tripFetchedResultsController = [self createFetchedRequestControllerWithEntity:EntityTrip
                                                                     withSortDescriptorKey:EntityTripSortKey
                                                                       withPredicateFormat:predicateFormat
                                                                       withPredicateObject:self.account];
    }
    return _tripFetchedResultsController;
}

- (NSFetchedResultsController *)memoryFetchedResultsController
{
    if (_memoryFetchedResultsController == nil) {
        if (self.trip == nil) {
            NSLog(@"Can't find trip info.");
            return nil;
        }
        NSString *predicateFormat = @"trip == %@";
        self.tripFetchedResultsController = [self createFetchedRequestControllerWithEntity:(NSString *)EntityMemory
                                                                     withSortDescriptorKey:(NSString *)EntityMemorySortKey
                                                                       withPredicateFormat:(NSString *)predicateFormat
                                                                       withPredicateObject:self.trip];
    }
    return _memoryFetchedResultsController;
}

@end
