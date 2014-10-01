//
//  MMRootViewController.m
//  Memories
//
//  Created by Zeng Wang on 4/7/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMRootViewController.h"
#import "MMCollectionView.h"
#import "MMTableView.h"
#import "MMMapViewController.h"
#import "constants.h"
#import "MMSharedClasses.h"
#import "Trip.h"
#import "Account.h"
#import "Memory.h"
#import "MMFetchResultsModel.h"
#import "MMNewTripTableViewController.h"
#import "MMTripDetailViewController.h"
#import "MMMediaPickerController.h"

@interface MMRootViewController ()
@property (strong, nonatomic) UIImageView* profileImage;
@property (strong, nonatomic) UILabel* tripsLabel;
@property (strong, nonatomic) UILabel* locationsLabel;
@property (strong, nonatomic) UILabel* memoriesLabel;
@property (strong, nonatomic) UIView* detailView;
@property (strong, nonatomic) UISegmentedControl* segControl;
@property (strong, nonatomic) MMCollectionView* colView;
@property (strong, nonatomic) MMTableView* tableView;
@property (strong, nonatomic) MMMapViewController* mapView;
@property (strong, nonatomic) Account* accountManagedObject;
@property (strong, nonatomic) MMFetchResultsModel* fetchResultsModel;
@property (strong, nonatomic) MMMediaPickerController* mediaPickerController;

- (void)initProfileViews;
- (void)initSegmentControlAndViews;
- (void)layoutSubviews;
- (void)reloadViewsData;
- (void)addNewTrip;
- (void)addNewMemory;
- (void)switchDetailView;
- (void)viewTripDetails:(NSNotification* )notification;
- (void)profileImageViewTapDetected;
- (void)initMediaPickerController;
- (void)loadProfileImage;
@end

@implementation MMRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Write default profile into file system
        NSString* filePath = [[NSBundle mainBundle] pathForResource:DefaultProfileFileName
                                                             ofType:DefaultProfileFileExtention];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        NSData *content = UIImagePNGRepresentation(image);
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", DefaultProfileFileName, DefaultProfileFileExtention];
        [[MMSharedClasses sharedClasses] writeData:content toFile:fileName];
        
        // Init fetch results model
        self.fetchResultsModel = [[MMFetchResultsModel alloc] init];
        
        // Init account managed object
        self.accountManagedObject = self.fetchResultsModel.account;
        
    }
    return self;
}

#pragma init and layout views
- (void)initProfileViews
{
    // Init profile imageview
    self.profileImage = [[UIImageView alloc] init];
    
    // Add a tap gesture to profile's UIImageView
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewTapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    self.profileImage.userInteractionEnabled = YES;
    [self.profileImage addGestureRecognizer:singleTap];

    // Profile layout setup
    self.tripsLabel = [[UILabel alloc] init];
    self.tripsLabel.numberOfLines = 0;
    self.tripsLabel.textAlignment = NSTextAlignmentCenter;
   
    // Init locations label
    self.locationsLabel = [[UILabel alloc] init];
    self.locationsLabel.numberOfLines = 0;
    self.locationsLabel.textAlignment = NSTextAlignmentCenter;

    // Init memory label
    self.memoriesLabel = [[UILabel alloc] init];
    self.memoriesLabel.numberOfLines = 0;
    self.memoriesLabel.textAlignment = NSTextAlignmentCenter;

    // Add as subviews
    [self.view addSubview:self.profileImage];
    [self.view addSubview:self.tripsLabel];
    [self.view addSubview:self.locationsLabel];
    [self.view addSubview:self.memoriesLabel];
}

- (void)initSegmentControlAndViews
{
    // Init segment controll
    self.segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"CV", @"TB", @"MAP", nil]];

    [self.view addSubview:self.segControl];
    [self.segControl addTarget:self
                        action:@selector(switchDetailView)
              forControlEvents:UIControlEventValueChanged];
    self.segControl.selectedSegmentIndex = 0;

    // Init collection view
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.colView = [[MMCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.colView.accountManagedObject = self.accountManagedObject;
    self.colView.backgroundColor = self.view.backgroundColor;
    
    // Init table view
    self.tableView = [[MMTableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];;
    self.tableView.dataSource = self.tableView;
    self.tableView.delegate = self.tableView;
    self.tableView.accountManagedObject = self.accountManagedObject;

    // Init map view
    self.mapView = [[MMMapViewController alloc] init];
    self.mapView.accountManagedObject = self.accountManagedObject;
    
    [self.view addSubview:self.colView];
    [self.view addSubview:self.tableView];
    [self.colView setHidden:NO];
    [self.tableView setHidden:YES];
}

- (void)layoutSubviews
{
    // Set frames for profile views
    float origin_y = Navigationbar_Height + [UIApplication sharedApplication].statusBarFrame.size.height + Space;
    float itemWidth = (self.view.frame.size.width - 2 * Space)/4;
    [self.profileImage setFrame:CGRectMake(Space, origin_y, itemWidth, Profile_Button_Height)];
    [self.tripsLabel setFrame:CGRectMake(Space + itemWidth, origin_y, itemWidth, Profile_Button_Height)];
    [self.locationsLabel setFrame:CGRectMake(Space + 2 * itemWidth, origin_y, itemWidth, Profile_Button_Height)];
    [self.memoriesLabel setFrame:CGRectMake(Space + 3 * itemWidth, origin_y, itemWidth, Profile_Button_Height)];
    
    // Set frame for segment control
    [self.segControl setFrame:CGRectMake(Space, origin_y + Profile_Button_Height + Space, [UIScreen mainScreen].bounds.size.width - 2 * Space, Detail_Controls_Height)];
    
    // Set frame for collectionview and tableview
    float detailViewHeight = self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - Navigationbar_Height - self.profileImage.frame.size.height - self.segControl.frame.size.height - 4 * Space;
    
    float detailViewWidth = self.view.frame.size.width - 2 * Space;
    float detailVIewOriginY = self.segControl.frame.origin.y + self.segControl.frame.size.height + Space;
    [self.colView setFrame:CGRectMake(Space, detailVIewOriginY, detailViewWidth, detailViewHeight)];
    [self.tableView setFrame:CGRectMake(Space, detailVIewOriginY, detailViewWidth, detailViewHeight)];;
}

- (void)loadProfileImage
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(self.profileImage.frame.size.width / 2, self.profileImage.frame.size.height / 2);

    [self.profileImage addSubview:activityIndicator];
    [self.profileImage bringSubviewToFront:activityIndicator];
    activityIndicator.hidden = NO;
    activityIndicator.hidesWhenStopped = YES;
    
    NSString *imageURL = self.accountManagedObject.profileURL;
    
    // Check whether image is in cache
    BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
    // Image is in cache. Set image
    if (isCached) {
        [self.profileImage setImage:[[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL]];
    }
    // Image is not in cache
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Show spinner
            activityIndicator.hidden = NO;
            [activityIndicator startAnimating];
            UIImage *profile = [[MMSharedClasses sharedClasses] readFileWithName:self.accountManagedObject.profileURL];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Hide spinner
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                // Save to cache
                [[MMSharedClasses sharedClasses].imageCacheController setImageCache:profile withImagePath:imageURL];
                
                self.profileImage.image = profile;
            });
        });
    }
}

// Init mediaPicker Controller
- (void)initMediaPickerController
{
    // If not yet, init mediaPickerController
    if (self.mediaPickerController == nil) {
        self.mediaPickerController = [[MMMediaPickerController alloc] init];
        self.mediaPickerController.superViewController = self;
        self.mediaPickerController.isAccount = YES;
        self.mediaPickerController.account = self.accountManagedObject;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init navigation items
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTrip)];
    UIBarButtonItem* photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addNewMemory)];
    self.navigationItem.leftBarButtonItem = addButton;
    self.navigationItem.rightBarButtonItem = photoButton;

    // Init profile session views
    [self initProfileViews];
    
    // Init views with segment control
    [self initSegmentControlAndViews];

    // Set up frames for subviews
    [self layoutSubviews];

    // Add as observer of account profile change notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewTripDetails:) name:PushTripDetailsView object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadViewsData];
    // Set navigationcontroller title
    self.navigationItem.title = @"Memories";
}

// Reload subview's content
- (void)reloadViewsData
{
    [self.tripsLabel setText:[NSString stringWithFormat:AccountDetailStringFormat, [self.fetchResultsModel numberOfTrips], TripLabel]];
    [self.memoriesLabel setText:[NSString stringWithFormat:AccountDetailStringFormat, [self.fetchResultsModel numberOfMemories], MemoriesLabel]];
    [self.locationsLabel setText:[NSString stringWithFormat:AccountDetailStringFormat, [self.fetchResultsModel numberOfLocations], LocationLabel]];
    
    // Load profile image
    [self loadProfileImage];

    if (self.segControl.selectedSegmentIndex == 0) {
        [self.colView reloadData];
    }
    else if (self.segControl.selectedSegmentIndex == 1) {
        [self.tableView reloadData];
    }
}

// Function called when tap "+" button
- (void)addNewTrip
{
    Trip* newTrip = [NSEntityDescription insertNewObjectForEntityForName:EntityTrip inManagedObjectContext:[MMSharedClasses sharedClasses].managedObjectContext];
    newTrip.account = self.accountManagedObject;
    MMNewTripTableViewController* newTripController = [[MMNewTripTableViewController alloc] init];
    newTripController.trip = newTrip;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:newTripController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addNewMemory
{
    [self initMediaPickerController];
    
    // Call mediaPickerController to handle add new memory
    [self.mediaPickerController addNewMemory];
}

// Tap profile image
- (void)profileImageViewTapDetected
{
    [self initMediaPickerController];
    
    // Call mediaPickerController to handle update profile
    [self.mediaPickerController profileImageViewTapDetected];
}

// Function called when click segoment control
- (void)switchDetailView
{
    if (self.segControl.selectedSegmentIndex == 0) {
        [self.colView setHidden:NO];
        [self.tableView setHidden:YES];
        [self.colView reloadData];
    }
    else if (self.segControl.selectedSegmentIndex == 1) {
        [self.colView setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
    else
    {
        [self.navigationController pushViewController:self.mapView animated:YES];
        self.mapView.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        self.segControl.selectedSegmentIndex = 0;
        [self.tableView setHidden:YES];
        [self.colView setHidden:NO];
    }
}

// Push TripDetailsViewController to show details of a trip
- (void)viewTripDetails:(NSNotification *)notification
{
    Trip* trip = [[notification userInfo] objectForKey:@"trip"];
    MMTripDetailViewController* tripDetailViewController = [[MMTripDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    tripDetailViewController.trip = trip;
    [self.navigationController pushViewController:tripDetailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
