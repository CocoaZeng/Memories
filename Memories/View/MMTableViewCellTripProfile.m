//
//  MMTableViewCellTripProfile.m
//  Memories
//
//  Created by Zeng Wang on 4/29/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTableViewCellTripProfile.h"
#import "constants.h"

@implementation MMTableViewCellTripProfile

- (void)awakeFromNib
{
    // Initialization code
    
    // Add activity indicator to imageView
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.alpha = 1.0;
    
    self.activityIndicator.center = self.contentView.center;
    [self bringSubviewToFront:self.activityIndicator];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.contentView addSubview:self.activityIndicator];
}

@end
