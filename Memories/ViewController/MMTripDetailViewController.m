//
//  MMTripDetailViewController.m
//  Memories
//
//  Created by Zeng Wang on 5/30/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMTripDetailViewController.h"
#import "MMTripDetailProfileCell.h"
#import "MMTripDetailDescriptionCell.h"
#import "MMTripDetailMemoryCell.h"
#import "constants.h"
#import "MMFetchResultsModel.h"
#import "Memory.h"
#import "MMChooseTripsTableViewController.h"
#import "MMImagePickerController.h"
#import "MMMemoriesCollectionViewController.h"
#import "MMSharedClasses.h"
#import "MMMediaPickerController.h"

@interface MMTripDetailViewController () <UINavigationBarDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSMutableArray* memories;
@property (strong, nonatomic) MMMediaPickerController* mediaPickerController;
@property (strong, nonatomic) UITextField *titleFiled;

- (void)profileImageViewTapDetected;
- (void)addNewMemory;
- (void)descriptionCellTextViewTapped;

@end

@implementation MMTripDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

// Init mediaPickerController
- (void)initMediaPickerController
{
    if (nil == self.mediaPickerController) {
        self.mediaPickerController = [[MMMediaPickerController alloc] init];
        self.mediaPickerController.trip = self.trip;
        self.mediaPickerController.superViewController = self;
        self.mediaPickerController.isAccount = NO;
    }
}

// Register UITableViewCell classes
- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *nibProfileCell = [UINib nibWithNibName:@"MMTripDetailProfileCell" bundle:nil];
    [self.tableView registerNib:nibProfileCell forCellReuseIdentifier:@"TripDetailProfileCellReuseIdentifier"];
    
    UINib *nibDescriptionCell = [UINib nibWithNibName:@"MMTripDetailDescriptionCell" bundle:nil];
    [self.tableView registerNib:nibDescriptionCell forCellReuseIdentifier:@"TripDetailDescriptionCellReuseIdentifier"];
    
    UINib *nibMemoryCell = [UINib nibWithNibName:@"MMTripDetailMemoryCell" bundle:nil];
    [self.tableView registerNib:nibMemoryCell forCellReuseIdentifier:@"TripDetailMemoryCellReuseIdentifier"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Add UITextFiled as navigation title
    self.titleFiled = [[UITextField alloc]initWithFrame:CGRectMake(105, 11, 110, 25)];
    self.titleFiled.backgroundColor = [UIColor clearColor];
    
    // Set title font bold
    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self.titleFiled setFont:boldFont];
    [self.titleFiled setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.titleFiled.textAlignment = NSTextAlignmentCenter;
    self.titleFiled.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.memories = [NSMutableArray arrayWithArray:[self.trip.memories allObjects]];
    self.titleFiled.text = self.trip.tripName;
    [self.navigationController.navigationBar addSubview:self.titleFiled];

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // If user clicks back button without 'Done' editing, cancel all the changes
    if (YES == self.tableView.editing) {
        [[MMSharedClasses sharedClasses].managedObjectContext rollback];
        [[MMSharedClasses sharedClasses] saveManagedContext];
    }
    [self.titleFiled removeFromSuperview];
}

// Tap profile to change trip profile
- (void)profileImageViewTapDetected
{
    [self initMediaPickerController];
    
    // Call mediaPickerController to handle update profile
    [self.mediaPickerController profileImageViewTapDetected];
}

// Add new memory
- (void)addNewMemory
{
    [self initMediaPickerController];
    
    // Call mediaPickerController to handle add new meory
    [self.mediaPickerController addNewMemory];
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
    
    // First section is trip profile
    if (section == 0) {
        return 1;
    }
    
    // Second secion is trip description
    else if (section == 1) {
        return 1;
    }
    
    // Third secion is list of memories
    else {
        return [self.memories count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Trip profile
    if ([indexPath section] == 0) {
        MMTripDetailProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripDetailProfileCellReuseIdentifier" forIndexPath:indexPath];
        [cell.locationsLabel setText:[NSString stringWithFormat:AccountDetailStringFormat, (unsigned long)[self.memories count], LocationLabel]];
        [cell.memoriesLabel setText:[NSString stringWithFormat:AccountDetailStringFormat, (unsigned long)[self.memories count], MemoriesLabel]];
       
        NSString *imageURL = self.trip.tripProfileURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            cell.profileImageView.image = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
        }
        // Image not in cache. Read from file and save into cache
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                cell.activityIndicator.hidden = NO;
                [cell.activityIndicator startAnimating];
                UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:self.trip.tripProfileURL];
           
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Stop spinner
                    [cell.activityIndicator stopAnimating];
                    
                    // Save to cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];
                    
                    cell.profileImageView.image = tripProfile;
                });
            });
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Add a tap gesture to profile's UIImageView
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewTapDetected)];
        singleTap.numberOfTapsRequired = 1;
        
        cell.profileImageView.userInteractionEnabled = YES;
        [cell.profileImageView addGestureRecognizer:singleTap];
        
        return cell;
    }
    
    // Trip description
    else if ([indexPath section] == 1) {
        MMTripDetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripDetailDescriptionCellReuseIdentifier" forIndexPath:indexPath];
        cell.textView.text = self.trip.tripDescription;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textView.delegate = self;

        return cell;
    }
    
    // List of memories
    else {
        if ([indexPath row] == [self.memories count]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Add a new memory";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        MMTripDetailMemoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripDetailMemoryCellReuseIdentifier" forIndexPath:indexPath];
        
        // Set image to nil in case it is resued
        cell.memoryView.image = nil;
        Memory *memory = [self.memories objectAtIndex:[indexPath row]];
        
        NSString *imageURL = memory.memoryURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            cell.memoryView.image = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
        }
        // Image not in cache. Read from file and save into cache
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // Show spinner
                cell.activityIndicator.hidden = NO;
                [cell.activityIndicator startAnimating];
                UIImage *memoryPic = [[MMSharedClasses sharedClasses] readFileWithName:memory.memoryURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Hide spinner
                    [cell.activityIndicator stopAnimating];
                    // Save to cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:memoryPic withImagePath:imageURL];
                    
                    cell.memoryView.image = memoryPic;
                });
            });
        }

        return cell;
    }
}

// Commit a delete of memory
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Memory *memoryToDelete = [self.memories objectAtIndex:[indexPath row]];
        
        // Delete from self.trip.memories
        [self.memories removeObjectAtIndex:[indexPath row]];
        
        // Delete memory object from managedObjectContext
        [[MMSharedClasses sharedClasses].managedObjectContext deleteObject:memoryToDelete];
    
        // Delete row from tableView
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion >= 7.0) {
            [tableView cellForRowAtIndexPath:indexPath].alpha = 0.0;
        }
        
        NSArray *rowToDelete = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationMiddle];
        
        [[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 0)] withRowAnimation:UITableViewRowAnimationNone];

    }
}

// Only Allow edit memories
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 2 && [indexPath row] != [self.memories count]){
        return YES;
    }
    else {
        return NO;
    }
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 80;
    }
    else if ([indexPath section] == 1) {
        return 100;
    }
    else if ([indexPath section] == 2 && [indexPath row] != [self.memories count]) {
        return 140;
    }
    else {
        return 40;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If user selects a memory, push collection view controller to show memories
    if ([indexPath section] == 2 && [indexPath row] != [self.memories count]) {
        // Create collection view to present memories
        MMMemoriesCollectionViewController *memoryCollectionViewController = [[MMMemoriesCollectionViewController alloc] init];
        memoryCollectionViewController.memories = self.memories;
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[indexPath row] inSection:0];
        memoryCollectionViewController.scrollToIndexPath = selectedIndexPath;
    
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:memoryCollectionViewController];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else if ([indexPath section] == 2 && [indexPath row] == [self.memories count])
    {
        [self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
        [self addNewMemory];
    }
}

// Sets whether the view controllers shows an editable view
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // Save changes when user done editing
    if (self.tableView.editing == YES) {
        [[MMSharedClasses sharedClasses] saveManagedContext];
    }
}

#pragma UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleFiled resignFirstResponder];
    self.trip.tripName = self.titleFiled.text;
    [[MMSharedClasses sharedClasses] saveManagedContext];
    return YES;
}

#pragma UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // Set inputAccessoryView for keyboard
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar setBarStyle:UIBarStyleDefault];
    keyboardToolbar.backgroundColor = [UIColor clearColor];
    [keyboardToolbar sizeToFit];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(descriptionCellTextViewTapped)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
    [keyboardToolbar setItems:itemsArray];
    [textView setInputAccessoryView:keyboardToolbar];
    
    return YES;
}

- (void)descriptionCellTextViewTapped
{
    NSIndexPath *descriptionCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITextView *textView = [(MMTripDetailDescriptionCell *)[self.tableView cellForRowAtIndexPath:descriptionCellIndexPath] textView];
    if (textView.isFirstResponder == YES) {
        // Dismiss keyboard
        [textView resignFirstResponder];
        
        // Save updated description
        self.trip.tripDescription = textView.text;
        [[MMSharedClasses sharedClasses] saveManagedContext];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
