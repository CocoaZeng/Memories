//
//  MMTripDetailMemoryCell.h
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTripDetailMemoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *memoryView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@end
