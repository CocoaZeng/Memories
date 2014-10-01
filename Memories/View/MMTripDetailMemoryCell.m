//
//  MMTripDetailMemoryCell.m
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTripDetailMemoryCell.h"

@implementation MMTripDetailMemoryCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    
    [super didTransitionToState:state];
    if (state == UITableViewCellStateShowingEditControlMask) {
        [self.memoryView setFrame:CGRectMake(0, 0, 285, 140)];
    }
    else if (state == UITableViewCellStateDefaultMask) {
        self.memoryView.frame = CGRectMake(0, 0, 320, 140);
    }
}

@end
