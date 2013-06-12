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
#import "MKMapView+ZoomLevel.h"
#define MERCATOR_RADIUS 85445659.44705395

#define kTopAreaHeight 44
#define kBottomAreaHeight 44
#define kNavBarHeight 20

@interface HomeViewController () <MKMapViewDelegate>

@property(nonatomic, strong) MKMapView* mapView;
@property(nonatomic, strong) NSDate *lastLogTime;
@property(nonatomic, strong) KMLParser *cityKmlParser;
@property(nonatomic, strong) KMLParser *neighbourhoodKMLParser;
@property(nonatomic, strong) NSArray* cityOverlays;
@property(nonatomic, strong) NSMutableArray* cityOverlayViews;
@property(nonatomic, strong) NSArray* californiaOverlays;
@property(nonatomic) MKMapRect caBounds;
@property (nonatomic) BOOL isNeighbourhoodDetail;
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
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"USA-no-crime" ofType:@"kml"];
     NSString *path = [[NSBundle mainBundle] pathForResource:@"CA-Disolved-002" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self logTimeSinceLastLog:@"Start Parsing"];
    self.cityKmlParser = [[KMLParser alloc] initWithURL:url];
    
    [self.cityKmlParser parseKML];
    [self logTimeSinceLastLog:@"End Parsing"];
    
    self.cityOverlays = [self.cityKmlParser overlays];
    NSLog(@"%d", [self.cityOverlays count]);
    [self logTimeSinceLastLog:@"made overlays"];
    
    self.cityOverlayViews = [NSMutableArray new];
    for (id<MKOverlay> overlay in self.cityOverlays) {
        [self.cityOverlayViews addObject:[self.cityKmlParser viewForOverlay:overlay]];
    }
    
    [self.mapView addOverlays:self.cityOverlays];
    
   // [self.kmlParser addMyOverlaysToMap:self.mapView];
    [self logTimeSinceLastLog:@"added overlays"];
    
  //  NSLog(@"%@", [[[NeighbourhoodData sharedData] states] objectAtIndex:0]);
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
    if(self.isNeighbourhoodDetail) {
        return [self.neighbourhoodKMLParser viewForOverlay:overlay];
    } else {
        //NSArray *results = [self.cityOverlays filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", overlay]];
        return [self.cityKmlParser viewForOverlay:overlay];
        //return [results lastObject];
    }
    
   
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.cityKmlParser viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    double zoomLevel = [self getZoomLevel];
    //[lblCurrentLevel setText:[NSString stringWithFormat:@"%.2f",zoomLevel]];
    
    NSLog(@"zoomlevel-->%f long-->%f lat-->%f",zoomLevel,mapView.region.span.longitudeDelta,mapView.region.span.latitudeDelta);
    if(zoomLevel >= 9.0 && !self.isNeighbourhoodDetail) {
        self.isNeighbourhoodDetail = YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CASimple" ofType:@"kml"];
        NSURL *url = [NSURL fileURLWithPath:path];
        [self logTimeSinceLastLog:@"Start Parsing"];
        self.neighbourhoodKMLParser = [[KMLParser alloc] initWithURL:url];
        
        [self.neighbourhoodKMLParser parseKML];
        [self logTimeSinceLastLog:@"End Parsing"];
        
        self.californiaOverlays = [self.neighbourhoodKMLParser overlays];
        NSLog(@"%d", [self.californiaOverlays count]);
        [self logTimeSinceLastLog:@"made overlays"];
        [self.mapView removeOverlays:self.cityOverlays];
        [self.mapView addOverlays:self.californiaOverlays];

        
        MKMapRect caBounds = MKMapRectNull;
        for (id <MKOverlay> overlay in self.californiaOverlays) {
            if (MKMapRectIsNull(caBounds)) {
                caBounds = [overlay boundingMapRect];
            } else {
                caBounds = MKMapRectUnion(caBounds, [overlay boundingMapRect]);
            }
        }
        [self logTimeSinceLastLog:@"bounds calculated"];
        self.caBounds = caBounds;
    }
    else if(zoomLevel < 9.0 && self.isNeighbourhoodDetail) {
        self.isNeighbourhoodDetail = NO;
        [self.mapView removeOverlays:self.californiaOverlays];
        [self.mapView addOverlays:self.cityOverlays];

    }
}



- (double) getZoomLevel
{
    return 20.00 - log2(self.mapView.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.mapView.bounds.size.width));
}


@end
