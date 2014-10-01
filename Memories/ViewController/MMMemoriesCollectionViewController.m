//
//  MMMemoriesCollectionViewController.m
//  Memories
//
//  Created by Zeng Wang on 6/18/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMMemoriesCollectionViewController.h"
#import "MMMemoryCollectionViewCell.h"
#import "Memory.h"
#import "MMSharedClasses.h"
#import "constants.h"
#import "MMImageCacheController.h"

@interface MMMemoriesCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGPoint recentContentOffset;
@property (strong, nonatomic) MMImageCacheController *imageCacheController;

- (void)doneViewingMemories;
- (void)tapMemoryDetected;
@end

@implementation MMMemoriesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imageCacheController = [[MMImageCacheController alloc] init];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneViewingMemories)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.collectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.collectionView];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionView registerClass:[MMMemoryCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.pagingEnabled = YES;
    
    // Add tap gesture to collection view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMemoryDetected)];
    [self.collectionView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigationBar
    self.navigationController.navigationBarHidden = YES;
    
    // Make navigationBar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    // Scroll to selected memory
    [self.collectionView scrollToItemAtIndexPath:self.scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}


// Finish viewing memories. Return to trip detail viewController
- (void)doneViewingMemories
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Detected tap on collection. Hide/Show UINavigationBar
- (void)tapMemoryDetected
{
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    else {
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.memories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MMMemoryCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    Memory *memory = [self.memories objectAtIndex:[indexPath row]];
    cell.imageView.image = nil;
    
    NSString *imageURL = memory.memoryURL;
    
    // Check whether image is in cache
    BOOL isCached = [self.imageCacheController hasImageInCache:imageURL];
    // Image is in cache. Set image
    if (isCached) {
        cell.imageView.image = [self.imageCacheController getImageFromPath:imageURL];
    }
    // Image not in cache. Read from file and save into cache
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            cell.activityIndicator.hidden = NO;
            [cell.activityIndicator startAnimating];
            UIImage *memoryPic = [[MMSharedClasses sharedClasses] readFileWithName:memory.memoryURL];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Stop spinner
                [cell.activityIndicator stopAnimating];
                
                // Save image into cache
                [self.imageCacheController setImageCache:memoryPic withImagePath:imageURL];
                
                cell.imageView.image = memoryPic;
            });
        });
    }
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = [[UIScreen mainScreen] applicationFrame].size;
    cellSize.height = cellSize.height - 64;
    cellSize.width = cellSize.width - 2 * kLayoutEdgeInsert;
    return cellSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    edgeInsets.left = kLayoutEdgeInsert;
    edgeInsets.right = kLayoutEdgeInsert;
    edgeInsets.top = 64;
    return edgeInsets;
}

// Sets insert betweon two items
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2 * kLayoutEdgeInsert;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
