//
//  MMImagePickerViewController.m
//  Memories
//
//  Created by Zeng Wang on 5/1/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMSharedClasses.h"
#import "constants.h"
#import "Memory.h"
#import "MMMemoryLocation.h"

@interface MMImagePickerController ()
@property (strong, nonatomic) MMMemoryLocation *memoryLocation;
@end

@implementation MMImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        self.pickedImage = [[UIImage alloc] init];
        self.thumbnailImage = [[UIImage alloc] init];
        self.originalImage = [[UIImage alloc] init];
        self.isMemory = YES;
        self.memoryLocation = [[MMMemoryLocation alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (nil != self.mmImagePickerDelegate && [self.mmImagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancelPick:)])
    {
        [self.mmImagePickerDelegate imagePickerControllerDidCancelPick:self];
    }
}

// Use picked picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block CLLocation *imageLocation;
    // selected image
    self.pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!self.pickedImage) {
        self.pickedImage = [info objectForKey:UIImagePickerControllerMediaType];
    }
    else if (self.pickedImage && self.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [self.memoryLocation.locationManager startUpdatingLocation];
        [self.memoryLocation.locationManager startUpdatingHeading];
    }
    
    ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error)
    {
        if (error)
            NSLog(@"%@", error);
    };
    
    // If it is a new picture, save to camera roll
    if (!(self.sourceType == UIImagePickerControllerSourceTypePhotoLibrary))
    {
        // Location info is unavaible, save image without location info
        if (nil == self.memoryLocation.currentLocation) {
            ALAssetsLibrary *library = [[MMSharedClasses sharedClasses] assetsLibrary];
            [library writeImageToSavedPhotosAlbum:[self.pickedImage CGImage]
                                      orientation:(ALAssetOrientation)[self.pickedImage imageOrientation]
                                  completionBlock:completeBlock];
        }
        // Location info is available, save image with locaiton information
        else {
            ALAssetsLibrary *library = [[MMSharedClasses sharedClasses] assetsLibrary];
            NSMutableDictionary *metaDic = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
            NSDictionary *gpsDic = [self.memoryLocation.locationManager.location EXIFMetadata];
            [metaDic setValue:gpsDic forKey:(NSString *)kCGImagePropertyGPSDictionary];
            [library writeImageToSavedPhotosAlbum:[self.pickedImage CGImage] metadata:metaDic completionBlock:completeBlock];
            imageLocation = self.memoryLocation.locationManager.location;
        }
        if (nil != self.mmImagePickerDelegate && [self.mmImagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidFinishPick:withLocation:)])
        {
            [self.mmImagePickerDelegate imagePickerControllerDidFinishPick:self withLocation:imageLocation];
        }
    }
    else
    {
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset)
        {
            if (asset) {
                id assetLocation = [asset valueForProperty:ALAssetPropertyLocation];
                if (assetLocation) {
                    imageLocation = (CLLocation *) assetLocation;
                }
                if (nil != self.mmImagePickerDelegate && [self.mmImagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidFinishPick:withLocation:)]) {
                    [self.mmImagePickerDelegate imagePickerControllerDidFinishPick:self withLocation:imageLocation];
                }
            }
        };
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            NSLog(@"%@", error);
        };
        ALAssetsLibrary *library = [[MMSharedClasses sharedClasses] assetsLibrary];
        [library assetForURL:assetURL resultBlock:resultBlock failureBlock:failureBlock];
        NSLog(@"%@", assetURL);
    }
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

- (void) dealloc
{
    self.delegate = nil;
    self.mmImagePickerDelegate = nil;
}

@end
