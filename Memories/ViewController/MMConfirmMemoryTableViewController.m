//
//  MMConfirmMemoryTableViewController.m
//  Memories
//
//  Created by Zeng Wang on 5/31/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMConfirmMemoryTableViewController.h"
#import "MMTripDetailMemoryCell.h"
#import "MMSharedClasses.h"
#import "Account.h"
#import "Trip.h"
#import "MMChooseTripsTableViewController.h"
#import "MMImageCacheController.h"

@interface MMConfirmMemoryTableViewController ()
@property BOOL canSelect;
@property (strong, nonatomic) MMImageCacheController* imageCacheController;
@end

@implementation MMConfirmMemoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.canSelect = FALSE;
        self.imageCacheController = [[MMImageCacheController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableCell"];
    UINib *memoryDetail = [UINib nibWithNibName:@"MMTripDetailMemoryCell" bundle:nil];
    [self.tableView registerNib:memoryDetail forCellReuseIdentifier:@"memoryCell"];
    
    self.navigationItem.title = @"Confirm";
    self.navigationController.navigationBar.backItem.title = @"";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveMemory)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationController.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMemory)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0)
    {
        MMTripDetailMemoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memoryCell" forIndexPath:indexPath];
        
        NSString *imageURL = self.memoryToConfirm.memoryURL;
        
        // Check whether image is in cache
        BOOL isCached = [self.imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            [cell.memoryView setImage:[self.imageCacheController getImageFromPath:imageURL]];
        }
        // Image is not in cache
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // Show spinner
                cell.activityIndicator.hidden = NO;
                [cell.activityIndicator startAnimating];
                UIImage *memoryPic = [[MMSharedClasses sharedClasses] readFileWithName:self.memoryToConfirm.memoryURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Stop spinner
                    [cell.activityIndicator stopAnimating];
                    [cell.memoryView setImage:memoryPic];
                    
                    // Add image into cache
                    [self.imageCacheController setImageCache:memoryPic withImagePath:imageURL];
                });
            });
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([indexPath section] == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
        if (self.memoryToConfirm.trip) {
            cell.textLabel.text = self.memoryToConfirm.trip.tripName;
            if (self.canSelect == FALSE) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        else {
            cell.textLabel.text = @"Select a trip";
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            self.canSelect = TRUE;
        }
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        MMChooseTripsTableViewController *selectTrip = [[MMChooseTripsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        selectTrip.memoryToConfirm = self.memoryToConfirm;
        [self.navigationController pushViewController:selectTrip animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 140;
    }
    else {
        return 40;
    }
}

// Save memory
- (void)saveMemory
{
    if (self.memoryToConfirm.trip == nil) {
        UIAlertView *altView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select a trip before you save memory." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [altView show];
    }
    else {
        [[MMSharedClasses sharedClasses] saveManagedContextAgain];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Cancel memory
- (void)cancelMemory
{
    [[MMSharedClasses sharedClasses].managedObjectContext deleteObject:self.memoryToConfirm];
    [[MMSharedClasses sharedClasses] saveManagedContext];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
