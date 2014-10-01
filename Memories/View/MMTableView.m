//
//  MMTableView.m
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTableView.h"
#import "Trip.h"
#import "constants.h"
#import "MMFetchResultsModel.h"
#import "MMTripDetailViewController.h"
#import "MMSharedClasses.h"
#import "MMTableViewCellTrip.h"

@implementation MMTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self registerClass:[MMTableViewCellTrip class] forCellReuseIdentifier:TableViewCellIdentifier];
        
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
    if ([self.accountManagedObject.trips allObjects] == nil) {
        return 0;
    }
    else{
        return [[self.accountManagedObject.trips allObjects] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMTableViewCellTrip *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];

    cell.tripProfileImageView.image = nil;
    NSInteger totalOfTrips = [[self.accountManagedObject.trips allObjects] count];
    
    if (totalOfTrips > [indexPath row]) {
        Trip* trip = (Trip *)[[self.accountManagedObject.trips allObjects] objectAtIndex:[indexPath row]];
        
        NSString *imageURL = trip.tripProfileURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            [cell.tripProfileImageView setImage:[[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL]];
        }
        // Image not in cache. Read image from file and save in cache
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                cell.activityIndicator.hidden = NO;
                [cell.activityIndicator startAnimating];
                UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:trip.tripProfileURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Hide spinner
                    [cell.activityIndicator stopAnimating];
                    
                    // Save to cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];

                    [cell.tripProfileImageView setImage: tripProfile];
                });
            });
        }
        
        cell.tripNameLabel.text = trip.tripName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Trip *trip = [[self.accountManagedObject.trips allObjects] objectAtIndex:[indexPath row]];
 
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:trip, @"trip", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushTripDetailsView object:nil userInfo:userInfo];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
