//
//  HomeViewController.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "HomeViewController.h"
#import "NeighbourhoodData.h"
#import <MapKit/MapKit.h>
#import "KMLParser.h"
#import "BDMKPolygonToDataTransformer.h"

#define kTopAreaHeight 44
#define kBottomAreaHeight 44
#define kNavBarHeight 20

@interface HomeViewController () <MKMapViewDelegate>

@property(nonatomic, strong) MKMapView* mapView;
@property(nonatomic, strong) NSDate *lastLogTime;
@property(nonatomic, strong) KMLParser *kmlParser;
@property (nonatomic) int x;
@end

@implementation HomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Safe Neighbourhoods";
        self.view.backgroundColor = [UIColor redColor];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, kTopAreaHeight , SCREEN_WIDTH, SCREEN_HEIGHT - kTopAreaHeight - kBottomAreaHeight - kNavBarHeight)];
    self.mapView.backgroundColor = [UIColor blueColor];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"USA-no-crime" ofType:@"kml"];
        [self logTimeSinceLastLog:@"Start creating polygons"];
    // NSString *path = [[NSBundle mainBundle] pathForResource:@"CA-Disolved-002" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];

    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    
    [self.kmlParser parseKML];
    
    NSArray *overlays = [self.kmlParser overlays];
    [self logTimeSinceLastLog:@"End creating polygons"];

    [self storePolygons:overlays];

    
            [self logTimeSinceLastLog:@"Start LOADING polygons"];
     NSArray *loadedOverlays = [self loadPolygons];
            [self logTimeSinceLastLog:@"END LOADING polygons"];
    int i = 4;
//    NSLog(@"%d", [overlays count]);
//    [self logTimeSinceLastLog:@"made overlays"];
//    
//    [self.mapView addOverlays:overlays];
//    
//   // [self.kmlParser addMyOverlaysToMap:self.mapView];
//    [self logTimeSinceLastLog:@"added overlays"];
    
  //  NSLog(@"%@", [[[NeighbourhoodData sharedData] states] objectAtIndex:0]);
}


-(void) storePolygons:(NSArray*)overlays {
    BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
    NSMutableArray* polygonData = [NSMutableArray new];
    for (MKPolygon *currentPolygon in overlays) {
        [polygonData addObject:[myTransformer transformedValue:currentPolygon]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:polygonData forKey:@"polygonData"];

//    
//    
//    For (MKOv)
//    
//	NSData *theData=[myTransformer transformedValue:myPolgon];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:theData forKey:@"myPolgon"];
//    
//    [defaults synchronize];
//    
//    NSUserDefaults *defaults2 = [NSUserDefaults standardUserDefaults];
//    NSData *storedPolgonData = [defaults2 objectForKey:@"myPolgon"];
//    
//    MKPolygon* storedMyPolygon = [myTransformer reverseTransformedValue:theData];
}
-(NSArray*) loadPolygons {
    BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *storedPolgonData = [defaults objectForKey:@"polygonData"];
    NSMutableArray *loadedPolygonData = [NSMutableArray new];
    for (NSData *currentPolygonData in storedPolgonData) {
        [loadedPolygonData addObject:[myTransformer reverseTransformedValue:currentPolygonData]];
    }
    return loadedPolygonData;
}


-(void) logTimeSinceLastLog:(NSString*) message {
    NSLog(@"%@ %f", message, [[NSDate date] timeIntervalSinceDate:self.lastLogTime]);
    self.lastLogTime = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"mem warn here");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    //NSLog(@"%d", self.x);
  //  self.x++;
    return [self.kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.kmlParser viewForAnnotation:annotation];
}


@end
