//
//  Account.m
//  Memories
//
//  Created by Zeng Wang on 4/25/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "Account.h"
#import "Memory.h"
#import "Trip.h"
#import "constants.h"


@implementation Account

@dynamic accountName;
@dynamic profileURL;
@dynamic trips;
@dynamic memories;

-(void)awakeFromInsert

{
    NSString *profileURL = [NSString stringWithFormat:@"%@.%@", DefaultProfileFileName, DefaultProfileFileExtention];
    [self setProfileURL:profileURL];
    self.accountName = @"";
}

@end



#pragma mark -

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}

- (id)transformedValue:(id)value {
    NSData *data = UIImagePNGRepresentation(value);
    return data;
}

- (id)reverseTransformedValue:(id)value {
    UIImage *uiImage = [[UIImage alloc] initWithData:value];
    return uiImage;
}

@end
