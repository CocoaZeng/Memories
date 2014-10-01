//
//  MMTripDetailViewController.h
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

// TableViewController to show trip details

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface MMTripDetailViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Trip* trip;

@end
