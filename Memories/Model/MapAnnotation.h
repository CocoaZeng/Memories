//
//  MapAnnotation.h
//  PhotoNotes
//
//  Created by Zeng Wang on 9/17/13.
//  Copyright (c) 2013 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Memory.h"

@interface MapAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) Memory *memory;

- (id)initWithMemory:(Memory *)memory;

@end
