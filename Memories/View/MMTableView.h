//
//  MMTableView.h
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

// Tableview controlled by segment control in RootViewController.
// It presents a list of trips.

#import <UIKit/UIKit.h>
#import "Account.h"

@interface MMTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Account *accountManagedObject;
@end
