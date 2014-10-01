//
//  MMTripDetailProfileCell.m
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTripDetailProfileCell.h"
#import "constants.h"

@implementation MMTripDetailProfileCell

- (void)awakeFromNib
{
    // Initialization code
    
    // Add activity indicator to imageView
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.alpha = 1.0;
    
    self.activityIndicator.center = self.contentView.center;
    [self bringSubviewToFront:self.activityIndicator];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.profileImageView addSubview:self.activityIndicator];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
