//
//  MMTableViewCellTripProfile.h
//  Memories
//
//  Created by Zeng Wang on 4/29/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

// Trip profile cell in TableViewController used to add new trip

#import <UIKit/UIKit.h>

@interface MMTableViewCellTripProfile : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *tripProfile;
@property (weak, nonatomic) IBOutlet UITextField *tripName;
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@end
