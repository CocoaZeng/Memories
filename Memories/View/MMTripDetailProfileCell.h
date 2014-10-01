//
//  MMTripDetailProfileCell.h
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTripDetailProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *locationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoriesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@end
