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
    // NSString *path = [[NSBundle mainBundle] pathForResource:@"rob4" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self logTimeSinceLastLog:@"Start Parsing"];
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    
    [self.kmlParser parseKML];
    [self logTimeSinceLastLog:@"End Parsing"];
    
    NSArray *overlays = [self.kmlParser overlays];
    [self logTimeSinceLastLog:@"made overlays"];
    
    [self.mapView addOverlays:overlays];
    
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
    NSLog(@"%d", self.x);
    self.x++;
    return [self.kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.kmlParser viewForAnnotation:annotation];
}


@end
