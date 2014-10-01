//
//  MMCollectionView.h
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

// Collection View controlled by segment control in RootViewController
// It presents a list of trips

#import <UIKit/UIKit.h>
#import "Account.h"

@interface MMCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) Account *accountManagedObject;

@end
