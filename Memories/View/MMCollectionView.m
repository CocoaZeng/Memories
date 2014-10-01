//
//  MMCollectionView.m
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMCollectionView.h"
#import "MMCollectionViewCellTrip.h"
#import "constants.h"
#import "MMSharedClasses.h"
#import "Trip.h"

@implementation MMCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self)
    {
        [self registerClass:[MMCollectionViewCellTrip class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

#pragma UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.accountManagedObject.trips == nil) {
        return 0;
    }
    else{
        return [self.accountManagedObject.trips count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MMCollectionViewCellTrip *cell = [self dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    cell.tripProfile.image = nil;
    Trip* trip = (Trip *)[[self.accountManagedObject.trips allObjects] objectAtIndex:[indexPath row]];
    
    NSString *imageURL = trip.tripProfileURL;
    
    // Check whether image is in cache
    BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
    // Image is in cache. Set image
    if (isCached) {
        cell.tripProfile.image = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
    }
    // Image not in cache. Read image from file and save in cache
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Show spinner
            cell.activityIndicator.hidden = NO;
            [cell.activityIndicator startAnimating];
            UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:trip.tripProfileURL];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Hide spinner
                [cell.activityIndicator stopAnimating];
                // Save to cache
                [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];
                cell.tripProfile.image = tripProfile;
            });
        });
    }

    cell.tripName.text = trip.tripName;

    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeMake(140, 110);
    return cellSize;
}


- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 5, 20, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = [[self.accountManagedObject.trips allObjects] objectAtIndex:[indexPath row]];
        
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:trip, @"trip", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushTripDetailsView object:nil userInfo:userInfo];
}


//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}


@end
