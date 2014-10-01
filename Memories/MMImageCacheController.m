//
//  MMImageCacheController.m
//  Memories
//
//  Created by Zeng Wang on 7/21/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMImageCacheController.h"

@implementation MMImageCacheController

- (id)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)hasImageInCache:(NSString *)imagePath
{
    if ([[self.imageCache allKeys] containsObject:imagePath]) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}

- (UIImage *)getImageFromPath:(NSString *)imageURL
{
    if ([[self.imageCache allKeys] containsObject:imageURL]) {
        UIImage *image = [self.imageCache objectForKey:imageURL];
        return image;
    }
    else {
        return nil;
    }
}

- (void)setImageCache:(UIImage *)image withImagePath:(NSString *)imageURL
{
    [self.imageCache setObject:image forKey:imageURL];
}
@end
