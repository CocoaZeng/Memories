//
//  MMTableViewCellPickDate.m
//  Memories
//
//  Created by Zeng Wang on 5/2/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTableViewCellPickDate.h"

@implementation MMTableViewCellPickDate

- (void)awakeFromNib
{
    [self.dateLabel setTextAlignment:NSTextAlignmentRight];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
