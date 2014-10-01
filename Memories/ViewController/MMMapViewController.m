//
//  MMMapViewController.m
//  Memories
//
//  Created by Zeng Wang on 4/16/14.
//  Copyright (c) 2014 Zeng Wang. All rights reserved.
//

#import "MMMapViewController.h"
#import "MapAnnotation.h"
#import "constants.h"
#import "MMTripDetailViewController.h"
#import "MMSharedClasses.h"

@interface MMMapViewController ()
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *mapAnnotations;

- (void)addAnnotationsToMap;
@end

@implementation MMMapViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.mapView = [[MKMapView alloc] init];
        self.mapView.mapType = MKMapTypeStandard;
        self.mapView.delegate = self;
        self.mapAnnotations = [[NSMutableArray alloc] init];
    }
    return self;
}

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
    [self.mapView setFrame:self.view.frame];
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (nil != self.mapAnnotations) {
        [self.mapView removeAnnotations:self.mapAnnotations];
        self.mapAnnotations = nil;
        [self addAnnotationsToMap];
    }
}

// Add an annotation for each memory
- (void)addAnnotationsToMap
{
    BOOL setRegion = NO;
    if (nil == self.mapAnnotations ) {
        self.mapAnnotations = [[NSMutableArray alloc] init];
    }
    if (nil != self.accountManagedObject)
    {
        // For each asset in userAssert array, if asset has location information, add an annotation for it in map.
        for (int i = 0; i < [[self.accountManagedObject.memories allObjects] count]; i++)
        {
            Memory *memory = [[self.accountManagedObject.memories allObjects] objectAtIndex:i];
            MapAnnotation *mapAnnotation = [[MapAnnotation alloc] initWithMemory:memory];
            if (mapAnnotation.coordinate.latitude != 0 && mapAnnotation.coordinate.longitude != 0)
            {
                [self.mapAnnotations addObject:mapAnnotation];
                // Set the region of map to the first memory in array
                if (NO == setRegion)
                {
                    MKCoordinateRegion mapRegion = MKCoordinateRegionMake([mapAnnotation coordinate], MKCoordinateSpanMake(2.0, 2.0));
                    [self.mapView setRegion:mapRegion animated:YES];
                    setRegion = YES;
                }
            }
        }
    }
    [self.mapView addAnnotations:self.mapAnnotations];
}

// Add MKPinAnnotationView for mapAnnotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
#warning add spinner
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = kAnnotationIdentifier;
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pinAnnotationView == nil)
    {
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        UIImageView *thumbnailImageView = [[UIImageView alloc] init];
        pinAnnotationView.leftCalloutAccessoryView = thumbnailImageView;
    }
    
    pinAnnotationView.pinColor = MKPinAnnotationColorRed;
    pinAnnotationView.animatesDrop = YES;
    pinAnnotationView.canShowCallout = YES;
    
    // add left callout accessory view
    Memory *memory = [(MapAnnotation *)annotation memory];
    if (nil != memory) {
        NSString *imageURL = memory.memoryURL;
        
        // Check whether image is in cache
        BOOL isCached = [[MMSharedClasses sharedClasses].imageCacheController hasImageInCache:imageURL];
        // Image is in cache. Set image
        if (isCached) {
            [(UIImageView *)pinAnnotationView.leftCalloutAccessoryView setImage:[[MMSharedClasses sharedClasses].imageCacheController getImageFromPath:imageURL]];
        }
        // Image is not in cache
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *memoryImage = [[MMSharedClasses sharedClasses] readFileWithName:memory.memoryURL];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    // Save to cache
                    [[MMSharedClasses sharedClasses].imageCacheController setImageCache:memoryImage withImagePath:imageURL];
                
                    [(UIImageView *)pinAnnotationView.leftCalloutAccessoryView setImage:memoryImage];
                });
            });
        }
        
        CGRect newBounds = CGRectMake(0.0, 0.0, 32.0, 32.0);
        [(UIImageView *)pinAnnotationView.leftCalloutAccessoryView setBounds:newBounds];
    }
   
    // add right callout accessory view
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pinAnnotationView.rightCalloutAccessoryView = detailButton;
    
    return pinAnnotationView;
}

// Set callOutAccessoryControl
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    Memory *memory = [(MapAnnotation *)view.annotation memory];
    [self didSelectTrip:memory.trip];
}

// User selects a memory. Show the details of the trip that memory belongs to
- (void)didSelectTrip:(Trip *)trip
{
    MMTripDetailViewController *tripDetail = [[MMTripDetailViewController alloc] init];
    tripDetail.trip = trip;
    [self.navigationController pushViewController:tripDetail animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
