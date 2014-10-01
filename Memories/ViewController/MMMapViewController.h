//
//  MMMapViewController.h
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Account.h"

@interface MMMapViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) Account *accountManagedObject;
@end
