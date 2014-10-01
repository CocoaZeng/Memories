#import "CLLocation+EXIFGPS.h"
#import "constants.h"

NSString * const ISODateFormat = kDateFormat;
NSString * const ISOTimeFormat = kTimeFormat;

@implementation CLLocation (EXIFGPS)

- (NSDictionary*) EXIFMetadata
{
  NSMutableDictionary *GPSMetadata = [NSMutableDictionary dictionary];
  
  NSNumber *altitudeRef = [NSNumber numberWithInteger: self.altitude < 0.0 ? 1 : 0];
  NSString *latitudeRef = self.coordinate.latitude < 0.0 ? @"S" : @"N";
  NSString *longitudeRef = self.coordinate.longitude < 0.0 ? @"W" : @"E";
  //NSString *headingRef = @"T"; // T: true direction, M: magnetic
  
  // GPS metadata
  
  [GPSMetadata setValue:[NSNumber numberWithDouble:ABS(self.coordinate.latitude)] forKey:(NSString*)kCGImagePropertyGPSLatitude];
  [GPSMetadata setValue:[NSNumber numberWithDouble:ABS(self.coordinate.longitude)] forKey:(NSString*)kCGImagePropertyGPSLongitude];
  
  [GPSMetadata setValue:latitudeRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
  [GPSMetadata setValue:longitudeRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
  
  [GPSMetadata setValue:[NSNumber numberWithDouble:ABS(self.altitude)] forKey:(NSString*)kCGImagePropertyGPSAltitude];
  [GPSMetadata setValue:altitudeRef forKey:(NSString*)kCGImagePropertyGPSAltitudeRef];
  
  [GPSMetadata setValue:[self.timestamp ISOTime] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
  [GPSMetadata setValue:[self.timestamp ISODate] forKey:(NSString*)kCGImagePropertyGPSDateStamp];
    
  return [GPSMetadata copy];
}

@end

#pragma mark - NSDate

@implementation NSDate (EXIFGPS)

- (NSString*) ISODate
{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:kTimeZone]];
  [f setDateFormat:ISODateFormat];
  return [f stringFromDate:self];
}

- (NSString*) ISOTime
{
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:kTimeZone]];
  [f setDateFormat:ISOTimeFormat];
  return [f stringFromDate:self];
}

@end