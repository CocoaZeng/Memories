//
//  MMConfirmMemoryTableViewController.h
//  Memories
//
//  Created by Zeng Wang on 5/31/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Memory.h"
#import "Trip.h"

@interface MMConfirmMemoryTableViewController : UITableViewController <UINavigationBarDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) Memory *memoryToConfirm;
//@property (strong, nonatomic) Trip *trip;
@property BOOL unKnownTrip;

@end
