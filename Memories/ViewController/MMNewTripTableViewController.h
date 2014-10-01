//
//  MMNewTripTableViewController.h
//  Memories
//
//  Created by Zeng Wang on 4/29/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface MMNewTripTableViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Trip *trip;

@end
