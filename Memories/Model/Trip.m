//
//  Trip.m
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "Trip.h"
#import "Account.h"
#import "Memory.h"
#import "constants.h"

@implementation Trip

@dynamic tripDescription;
@dynamic tripEndDate;
@dynamic tripName;
@dynamic tripStartDate;
@dynamic account;
@dynamic memories;
@dynamic tripProfileURL;

-(void)awakeFromInsert

{
    NSString *profileURL = [NSString stringWithFormat:@"%@.%@", DefaultProfileFileName, DefaultProfileFileExtention];
    [self setTripProfileURL:profileURL];
}

@end
