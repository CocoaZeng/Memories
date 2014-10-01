//
//  MMSharedClasses.h
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMImageCacheController.h"

@interface MMSharedClasses : NSObject

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) MMImageCacheController* imageCacheController;

+ (MMSharedClasses *)sharedClasses;
- (void)saveManagedContext;
- (void)saveManagedContextAgain;
- (NSString *)stringFormattedFromDate:(NSDate *)date;
- (NSDate *)dateFormattedFromString:(NSString *)dateString;
- (void)listAllLocalFiles;
- (void)createFileWithName:(NSString *)fileName;
- (void)deleteFileWithName:(NSString *)fileName;
- (UIImage *)readFileWithName:(NSString *)fileName;
- (void)writeData:(NSData *)content toFile:(NSString *)fileName;
@end
