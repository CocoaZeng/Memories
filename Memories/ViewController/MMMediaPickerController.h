//
//  MMMediaPickerController.h
//  Memories
//
//  Created by Zeng Wang on 6/19/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMConfirmMemoryTableViewController.h"
#import "constants.h"
#import "MMImagePickerController.h"
#import "Account.h"
#import "Trip.h"

@interface MMMediaPickerController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Account *account;
@property (strong, nonatomic) Trip *trip;
@property BOOL isAccount;
@property (strong, nonatomic) UIViewController* superViewController;

- (void)addNewMemory;
- (void)profileImageViewTapDetected;

@end
