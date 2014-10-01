//
//  MMTableViewCellTrip.m
//  Memories
//
//  Created by Zeng Wang on 8/4/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTableViewCellTrip.h"

@implementation MMTableViewCellTrip
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tripProfileImageView = [[UIImageView alloc] init];
        self.tripNameLabel = [[UILabel alloc] init];
        self.tripNameLabel.textAlignment = NSTextAlignmentCenter;
        self.tripNameLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.tripProfileImageView];
        [self.contentView addSubview:self.tripNameLabel];
        
        // Add activity indicator to imageView
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.activityIndicator];
        self.activityIndicator.alpha = 1.0;
        self.activityIndicator.center = self.contentView.center;
        [self bringSubviewToFront:self.activityIndicator];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return self;
}


- (void)layoutSubviews
{
#warning make them relevent rather than abusolute value
    [super layoutSubviews];
    [self.tripProfileImageView setFrame:CGRectMake(0, 0, 140, 100)];
    [self.tripNameLabel setFrame:CGRectMake(10, 90, 120, 20)];
}

@end
