//
//  MMTableViewCellTripDates.h
//  Memories
//
//  Created by Zeng Wang on 4/29/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

// Date table view cell in TableViewController used to add new trip

#import <UIKit/UIKit.h>

@interface MMTableViewCellTripDates : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;

@end
