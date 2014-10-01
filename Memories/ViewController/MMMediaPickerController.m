//
//  MMMediaPickerController.m
//  Memories
//
//  Created by Zeng Wang on 6/19/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMMediaPickerController.h"
#import "MMImagePickerController.h"
#import "MMSharedClasses.h"

@interface MMMediaPickerController () <MMImagePickerControllerDelegate>

@property (strong, nonatomic) MMImagePickerController *imagePickerController;
@property (strong, nonatomic) MMConfirmMemoryTableViewController* confirmMemoryController;
@property (strong, nonatomic) Memory* theNewMemory;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)presentImagePickerController:(NSInteger)cameraType withImagePickerController:(MMImagePickerController *)imagePickerController;

@end

@implementation MMMediaPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// Function called when tap profile image
- (void)profileImageViewTapDetected
{
    if (nil == self.imagePickerController) {
        self.imagePickerController = [[MMImagePickerController alloc] init];
    }
    if (self.isAccount == YES && nil != self.account) {
        NSString *imageURL = self.account.profileURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            self.imagePickerController.originalImage = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
        }
        // Image not in cache. Read from file
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *accountProfile = [[MMSharedClasses sharedClasses] readFileWithName:self.account.profileURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Save image into cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:accountProfile withImagePath:imageURL];
                    
                    self.imagePickerController.originalImage = accountProfile;
                });
            });
        }
    }
    else if (self.isAccount == NO && nil != self.trip) {
        NSString *imageURL = self.trip.tripProfileURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            self.imagePickerController.originalImage = [[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL];
        }
        // Image not in cache. Read from file
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *tripProfile = [[MMSharedClasses sharedClasses] readFileWithName:self.trip.tripProfileURL];
            
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Save image to cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:tripProfile withImagePath:imageURL];
                    
                    self.imagePickerController.originalImage = tripProfile;
                });
            });
        }
    }
    self.imagePickerController.isMemory = NO;
    
    UIActionSheet* pickProfile = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kAcitonSheetCancelButtonTitle destructiveButtonTitle:kAcitonSheetDestructiveButtonTitle otherButtonTitles:kAcitonSheetOtherButtonTitle, nil];
    [pickProfile showFromToolbar:self.superViewController.navigationController.toolbar];
}

// Function called when tap camera button
- (void)addNewMemory
{
    if (self.imagePickerController == nil) {
        self.imagePickerController = [[MMImagePickerController alloc] init];
    }
    
    Memory* memory = [NSEntityDescription insertNewObjectForEntityForName:EntityMemory inManagedObjectContext:[MMSharedClasses sharedClasses].managedObjectContext];
    self.theNewMemory = memory;
    // Add new memory in rootViewController
    if (self.isAccount == YES && nil != self.account) {
        self.theNewMemory.account = self.account;
    }
    else if (self.isAccount == NO && nil != self.trip) {
        self.theNewMemory.trip = self.trip;
        self.theNewMemory.account = self.trip.account;
    }

    self.imagePickerController.isMemory = YES;
    
    UIActionSheet* addMemory = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kAcitonSheetCancelButtonTitle destructiveButtonTitle:kAcitonSheetDestructiveButtonTitle otherButtonTitles:kAcitonSheetOtherButtonTitle, nil];
    [addMemory showFromToolbar:self.superViewController.navigationController.toolbar];
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex == 0) {
        [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera withImagePickerController:self.imagePickerController];
    }
    else if (buttonIndex == 1) {
        [self presentImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary withImagePickerController:self.imagePickerController];
    }
    else {
        if (self.theNewMemory) {
            [[MMSharedClasses sharedClasses].managedObjectContext deleteObject:self.theNewMemory];
            [[MMSharedClasses sharedClasses] saveManagedContextAgain];
        }
    }
}

- (void)presentImagePickerController:(NSInteger)cameraType withImagePickerController:(MMImagePickerController *)imagePickerController
{
    if (nil == self.imagePickerController) {
        imagePickerController = [[MMImagePickerController alloc] init];
    }
    
    if ((cameraType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePickerController.delegate = imagePickerController;
    imagePickerController.mmImagePickerDelegate = self;
    [self.superViewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma  mark - MMImagePickerControllerDelegate
- (void)imagePickerControllerDidFinishPick:(MMImagePickerController* )imagePickerController withLocation:(CLLocation* )location
{
    // Save picked image into file system
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSString *imageUUID = (__bridge NSString *)string;
    NSData *content = UIImagePNGRepresentation(self.imagePickerController.pickedImage);
    [[MMSharedClasses sharedClasses] writeData:content toFile:imageUUID];
    
    // Finish pick a new profile
    if (self.imagePickerController.isMemory == NO) {
        // Picked new profile for account
        if (self.isAccount == YES && nil != self.account) {
            self.account.profileURL = imageUUID;
        }
        
        // Picked new profile for trip
        else if (self.isAccount == NO && nil != self.trip) {
            self.trip.tripProfileURL = imageUUID;
        }
    }
    // Finish pick a new memory
    else if (self.imagePickerController.isMemory == YES) {
        self.theNewMemory.memoryURL = imageUUID;
        
        // Add available location information to memory
        if (location) {
            self.theNewMemory.lattitude = [[NSNumber alloc] initWithDouble:[location coordinate].latitude];
            self.theNewMemory.longtitude = [[NSNumber alloc] initWithDouble:[location coordinate].longitude];
        }
        if (self.isAccount) {
            if (nil == self.confirmMemoryController) {
                self.confirmMemoryController = [[MMConfirmMemoryTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            }

            self.confirmMemoryController.memoryToConfirm = self.theNewMemory;
            [self.superViewController.navigationController pushViewController:self.confirmMemoryController animated:YES];
        }
    }
    
    // Save data into coreData
    [[MMSharedClasses sharedClasses] saveManagedContext];
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancelPick:(MMImagePickerController* ) imagePickerController;
{
    if (self.imagePickerController.isMemory == YES) {
        if (self.theNewMemory) {
            [[MMSharedClasses sharedClasses].managedObjectContext deleteObject:self.theNewMemory];
            [[MMSharedClasses sharedClasses] saveManagedContextAgain];
        }
    }
    else {
        self.imagePickerController.pickedImage = self.imagePickerController.originalImage;
    }
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // Clean up cache
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
