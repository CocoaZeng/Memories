//
//  MMImageCacheController.h
//  Memories
//
//  Created by Zeng Wang on 7/21/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMImageCacheController : NSObject

@property (strong, nonatomic) NSMutableDictionary *imageCache;

- (BOOL)hasImageInCache:(NSString *)imagePath;
- (UIImage *)getImageFromPath:(NSString *)imageURL;
- (void)setImageCache:(UIImage *)image withImagePath:(NSString *)imageURL;

@end
