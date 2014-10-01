//
//  MMMemoriesCollectionViewController.h
//  Memories
//
//  Created by Zeng Wang on 6/18/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMMemoriesCollectionViewController : UIViewController
@property (strong, nonatomic) NSMutableArray* memories;
@property (strong, nonatomic) NSIndexPath* scrollToIndexPath;
@property (strong, nonatomic) UICollectionView* collectionView;
@end
