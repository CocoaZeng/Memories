//
//  MMDateViewController.h
//  Memories
//
//  Created by Zeng Wang on 5/2/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface MMDateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) Trip *trip;

@end
