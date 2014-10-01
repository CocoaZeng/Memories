#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface CLLocation (EXIFGPS)

- (NSDictionary*) EXIFMetadata;

@end

@interface NSDate (EXIFGPS)

- (NSString*) ISODate;
- (NSString*) ISOTime;

@end