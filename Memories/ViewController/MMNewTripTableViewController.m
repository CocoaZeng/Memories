//
//  MMNewTripTableViewController.m
//  Memories
//
//  Created by Zeng Wang on 4/29/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMNewTripTableViewController.h"
#import "MMImagePickerController.h"
#import "MMTableViewCellTripProfile.h"
#import "MMTableViewCellTripDates.h"
#import "MMTripDetailDescriptionCell.h"
#import "MMSharedClasses.h"
#import "MMDateViewController.h"
#import "MMSharedClasses.h"
#import "constants.h"
#import "MMTripDetailViewController.h"
#import "MMMediaPickerController.h"
#import "MMTripDetailMemoryCell.h"
#import "MMMemoriesCollectionViewController.h"
#import "MMImageCacheController.h"

#define TripDetailMemoryCellIdentifier "TripDetailMemoryCellIdentifier"
#define AddMemoryCellIdentifier "MMTableViewCellIdentifier"

@interface MMNewTripTableViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) MMTableViewCellTripProfile *tripProfileCell;
@property (strong, nonatomic) MMTableViewCellTripDates *tripDatesCell;
@property (strong, nonatomic) MMTripDetailDescriptionCell *tripDescriptionCell;
@property (strong, nonatomic) MMImagePickerController *imagePickerController;
@property (strong, nonatomic) MMDateViewController *pickDateController;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) MMMediaPickerController* mediaPickerController;
@property (strong, nonatomic) NSMutableArray *memories;

- (void)profileImageViewTapDetected;
- (void)saveNewTrip;
- (void)descriptionCellTextViewTapped;

@end

@implementation MMNewTripTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

// Init mediaPickerController
- (void)initMediaPickerController
{
    if (nil == self.mediaPickerController) {
        self.mediaPickerController = [[MMMediaPickerController alloc] init];
        self.mediaPickerController.isAccount = NO;
        self.mediaPickerController.trip = self.trip;
        self.mediaPickerController.superViewController = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UINavigationController items
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNewTrip)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewTrip)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.title = @"New Trip";
    
    // Register UITableViewCell classes
    UINib *nibTripProfile = [UINib nibWithNibName:@"MMTableViewCellTripProfile" bundle:nil];
    [[self tableView] registerNib:nibTripProfile forCellReuseIdentifier:TripProfileCellIdentifier];
    
    UINib *nibTripDates = [UINib nibWithNibName:@"MMTableViewCellTripDates" bundle:nil];
    [self.tableView registerNib:nibTripDates forCellReuseIdentifier:TripDatesCellIdentifier];
    
    UINib *nibTripDescription = [UINib nibWithNibName:@"MMTripDetailDescriptionCell" bundle:nil];
    [self.tableView registerNib:nibTripDescription forCellReuseIdentifier:TripDescriptionCellIdentifier];
    
    UINib *nibTripMemory = [UINib nibWithNibName:@"MMTripDetailMemoryCell" bundle:nil];
    [self.tableView registerNib:nibTripMemory forCellReuseIdentifier:@TripDetailMemoryCellIdentifier];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@AddMemoryCellIdentifier];
    
    // Init MMDateViewController
    self.pickDateController = [[MMDateViewController alloc] init];
    self.pickDateController.trip = self.trip;
    
    // Add default dates
    NSString *startDateString = [[MMSharedClasses sharedClasses] stringFormattedFromDate:[NSDate date]]
    ;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:5];
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSString *endDateString = [[MMSharedClasses sharedClasses] stringFormattedFromDate:endDate];
    self.pickDateController.startDate = [NSString stringWithString:startDateString];
    self.pickDateController.endDate = [NSString stringWithString:endDateString];
    
    // Assign dates to trip
    self.trip.tripStartDate = startDateString;
    self.trip.tripEndDate = endDateString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *imageURL = self.trip.tripProfileURL;
    
    // Check whether image is in cache
    BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
    // Image is in cache. Set image
    if (isCached) {
        self.tripProfileCell.tripProfile.image = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
    }
    // Image not in cache. Read from file and save into cache
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Show spinner
            self.tripProfileCell.activityIndicator.hidden = NO;
            [self.tripProfileCell.activityIndicator startAnimating];

            UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:self.trip.tripProfileURL];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Stop spinner
                [self.tripProfileCell.activityIndicator stopAnimating];
                // Save to cache
                [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];
                
                self.tripProfileCell.tripProfile.image = tripProfile;
            });
        });
    }
    
    self.tripDatesCell.startDate.text = self.trip.tripStartDate;
    self.tripDatesCell.endDate.text = self.trip.tripEndDate;
    
    // Get a copy of memories of trip
    self.memories = [NSMutableArray arrayWithArray:[self.trip.memories allObjects]];
    [self.tableView reloadData];
}

// Tap "Done" navigationItem to save new trip
#warning need to understand this function more
- (void)saveNewTrip
{
    NSString *imageURL = self.trip.tripProfileURL;
    
    // Check whether image is in cache
    BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
    // Image is in cache. Set image
    if (isCached) {
        self.tripProfileCell.tripProfile.image = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
    }
    // Image not in cache. Read from file and save into cache
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Show spinner
            self.tripProfileCell.activityIndicator.hidden = NO;
            UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:self.trip.tripProfileURL];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Hide spinner
                self.tripProfileCell.activityIndicator.hidden = NO;
                // Save to cache
                [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];
                
                self.tripProfileCell.tripProfile.image = tripProfile;
            });
        });
    }

    self.trip.tripName = self.tripProfileCell.tripName.text;
    self.trip.tripStartDate = self.tripDatesCell.startDate.text;
    self.trip.tripEndDate = self.tripDatesCell.endDate.text;
    self.trip.tripDescription = self.tripDescriptionCell.textView.text;

    [[MMSharedClasses sharedClasses] saveManagedContextAgain];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Tap "Cancel" navigationItem to cancel saving new trip
- (void)cancelNewTrip
{
    [[MMSharedClasses sharedClasses].managedObjectContext deleteObject:self.trip];
    [[MMSharedClasses sharedClasses] saveManagedContextAgain];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Function called when received dates changed notification
- (void)updateDates
{
    self.tripDatesCell.startDate.text = self.pickDateController.startDate;
    self.tripDatesCell.endDate.text = self.pickDateController.endDate;
}

// Add new memory
- (void)addNewMemory
{
    [self initMediaPickerController];
    
    // Call mediaPickerController to handle add new meory
    [self.mediaPickerController addNewMemory];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section != 3) {
        return 1;
    }
    else {
        return [self.memories count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        self.tripProfileCell = [self.tableView dequeueReusableCellWithIdentifier:TripProfileCellIdentifier forIndexPath:indexPath];
        self.tripProfileCell.tripName.placeholder = @"Trip Name";
        self.tripProfileCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tripProfileCell.tripName.delegate = self;
        //self.tripProfileCell.tripProfile.image = self.trip.tripProfile;
        
        // Add singleTap gesture to profile's imageView
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewTapDetected)];
        singleTap.numberOfTapsRequired = 1;
        self.tripProfileCell.tripProfile.userInteractionEnabled = YES;
        [self.tripProfileCell.tripProfile addGestureRecognizer:singleTap];
        
        return self.tripProfileCell;
    }
    else if ([indexPath section] == 1)
    {
        self.tripDatesCell = [self.tableView dequeueReusableCellWithIdentifier:TripDatesCellIdentifier forIndexPath:indexPath];
       
        self.tripDatesCell.startDate.text = self.pickDateController.startDate;
        self.tripDatesCell.endDate.text = self.pickDateController.endDate;
        self.tripDatesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return self.tripDatesCell;
    }
    else if ([indexPath section] == 2)
    {
        self.tripDescriptionCell = [self.tableView dequeueReusableCellWithIdentifier:TripDescriptionCellIdentifier forIndexPath:indexPath];
        self.tripDescriptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.tripDescriptionCell.textView.delegate = self;
        return self.tripDescriptionCell;
    }
    else
    {
        if ([indexPath row] == [self.memories count]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@AddMemoryCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Add a new memory";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        MMTripDetailMemoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@TripDetailMemoryCellIdentifier forIndexPath:indexPath];
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
                UIImage *memoryPic = [[MMSharedClasses sharedClasses] readFileWithName:memory.memoryURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Hide spinner
                    cell.activityIndicator.hidden = YES;
                    
                    // Save into cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:memoryPic withImagePath:imageURL];
                    cell.memoryView.image = memoryPic;
                });
            });
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 65;
    }
    else if ([indexPath section] == 1) {
        return 60;
    }
    else if ([indexPath section] == 2) {
        return 150;
    }
    else if ([indexPath section] == 3 && [indexPath row] != [self.memories count]) {
        return 140;
    }
    else {
        return 40;
    }
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.pickDateController];
        [self presentViewController:nav animated:YES completion:nil];
    }
    // If user selects a memory, push collection view controller to show memories
    if ([indexPath section] == 3 && [indexPath row] != [self.memories count]) {
        // Create collection view to present memories
        MMMemoriesCollectionViewController *memoryCollectionViewController = [[MMMemoriesCollectionViewController alloc] init];
        memoryCollectionViewController.memories = self.memories;
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[indexPath row] inSection:0];
        memoryCollectionViewController.scrollToIndexPath = selectedIndexPath;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:memoryCollectionViewController];
        [self presentViewController:nav animated:NO completion:nil];
    }

    // User select to add a new memory
    else if ([indexPath section] == 3 && [indexPath row] == [self.memories count])
    {
        [self addNewMemory];
    }
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex == 0)
        [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera];
    else if (buttonIndex == 1)
        [self presentImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    //[self dismissKeyBoard];
}

- (void)presentImagePickerController:(NSInteger)cameraType
{
    if ((cameraType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.parentViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)profileImageViewTapDetected
{
    [self initMediaPickerController];
    [self.mediaPickerController profileImageViewTapDetected];
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.tripProfileCell.tripName) {
        self.trip.tripName = self.tripProfileCell.tripName.text;
        [textField resignFirstResponder];
    }
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

// Method to help show/dismiss keyboard for textView
- (void)descriptionCellTextViewTapped
{
    NSIndexPath *descriptionCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    UITextView *textView = [(MMTripDetailDescriptionCell *)[self.tableView cellForRowAtIndexPath:descriptionCellIndexPath] textView];
    if (textView.isFirstResponder == YES) {
        // Dismiss keyboard
        [textView resignFirstResponder];
    }
}

- (void)dealloc
{
    self.tripDescriptionCell.textView.delegate = nil;
    self.tripProfileCell.tripName.delegate = nil;
}
@end
