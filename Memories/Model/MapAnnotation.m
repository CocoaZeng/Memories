//
//  MapAnnotation.m
//  PhotoNotes
//
//  Created by Zeng Wang on 9/17/13.
//  Copyright (c) 2013 Zeng Wang. All rights reserved.
//

#import "MapAnnotation.h"
#import "constants.h"
#import "Trip.h"

//@interface MapAnnotation()
//@property (strong, nonatomic) Trip *trip;
//@end

@implementation MapAnnotation
- (id)initWithMemory:(Memory *)memory
{
    self = [super init];
    if (self)
    {
        self.memory = memory;
        CLLocation *memoryLocaton = [[CLLocation alloc] initWithLatitude:[memory.lattitude floatValue] longitude:[memory.longtitude floatValue]];
        self.coordinate = [memoryLocaton coordinate];
        if (nil != memory.trip.tripName) {
            self.title = memory.trip.tripName;
        }
    }
    return self;
}

@end
