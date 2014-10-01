//
//  MMImagePickerViewController.h
//  Memories
//
//  Created by Zeng Wang on 5/1/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Memory.h"

@class MMImagePickerController;

@protocol MMImagePickerControllerDelegate <NSObject>

- (void)imagePickerControllerDidFinishPick:(MMImagePickerController* ) imagePickerController withLocation:(CLLocation *)location;
- (void)imagePickerControllerDidCancelPick:(MMImagePickerController* ) imagePickerController;

@end

@interface MMImagePickerController : UIImagePickerController <UINavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) UIImage *originalImage;
@property BOOL isMemory;
@property (assign, nonatomic) id <MMImagePickerControllerDelegate> mmImagePickerDelegate;


@end