//
//  MMMemoryLocation.m
//  Memories
//
//  Created by Zeng Wang on 6/18/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMMemoryLocation.h"

@interface MMMemoryLocation ()
@end


@implementation MMMemoryLocation

// init
- (id)init
{
    self = [super init];
    if (self)
    {
        self.currentLocation = [[CLLocation alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    return self;
}

// location service is turned on and gets returned location information
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    [manager stopUpdatingLocation];
}

// location service is turned off or location info can't be retained
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.currentLocation = nil;
    [manager stopUpdatingLocation];
}



@end
