//
//  MMMemoryCollectionViewCell.m
//  Memories
//
//  Created by Zeng Wang on 6/18/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMMemoryCollectionViewCell.h"

@implementation MMMemoryCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
   
        // Add activity indicator to imageView
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.alpha = 1.0;
            
        self.activityIndicator.center = self.contentView.center;
        [self bringSubviewToFront:self.activityIndicator];
        self.activityIndicator.hidesWhenStopped = YES;
        [self.contentView addSubview:self.activityIndicator];
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
