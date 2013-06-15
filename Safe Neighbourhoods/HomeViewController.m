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

#define kPreProcessData YES
#define kLoadMap YES

@interface HomeViewController () <MKMapViewDelegate>

@property(nonatomic, strong) MKMapView* mapView;
@property(nonatomic, strong) NSDate *lastLogTime;
@property(nonatomic, strong) KMLParser *kmlParser;
@property(nonatomic, strong) NSArray* overlays;
@property(nonatomic, strong) NSArray* overlayViews;

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
    
    if (kPreProcessData) {
        [self preProcessData];
    }
    
    if (kLoadMap) {
        [self setupMap];
    }
}

-(void) preProcessData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"USA-no-crime" ofType:@"kml"];
  //  NSString *path = [[NSBundle mainBundle] pathForResource:@"rob4" ofType:@"kml"];
    [self logTimeSinceLastLog:@"Start creating polygons"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    
    [self.kmlParser parseKML];
    NSArray *overlays = [self.kmlParser overlays];
    [self logTimeSinceLastLog:@"End creating polygons"];
    
    [self storePolygons:overlays];
}


-(void) setupMap {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, kTopAreaHeight , SCREEN_WIDTH, SCREEN_HEIGHT - kTopAreaHeight - kBottomAreaHeight - kNavBarHeight)];
    self.mapView.backgroundColor = [UIColor blueColor];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    [self logTimeSinceLastLog:@"Start LOADING polygons"];
    self.overlays = [self loadPolygons];
    [self logTimeSinceLastLog:@"END LOADING polygons"];
    
    [self logTimeSinceLastLog:@"Start LOADING polygon views"];
    self.overlayViews = [self loadPolygonViews];
    [self logTimeSinceLastLog:@"END LOADING polygon views"];
    
    [self.mapView addOverlays:self.overlays];

}



-(void) storePolygons:(NSArray*)overlays {
    BDMKPolygonToDataTransformer *myTransformer=[[BDMKPolygonToDataTransformer alloc] init];
    NSMutableArray* polygonData = [NSMutableArray new];
    NSMutableArray* polygonViewData = [NSMutableArray new];
    
    for (MKPolygon *currentPolygon in overlays) {
        [polygonData addObject:[myTransformer transformedValue:currentPolygon]];
        MKPolygonView *polyView = [[MKPolygonView alloc] initWithPolygon:currentPolygon];
        [polygonViewData addObject:polyView];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:polygonData forKey:@"polygonData"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:polygonViewData] forKey:@"polygonViewData"];
    
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

-(NSArray*) loadPolygonViews {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *storedPolgonData = [defaults objectForKey:@"polygonViewData"];
    
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:storedPolgonData];
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
//    MKPolygon* polygon = (MKPolygon*)overlay;
//    for (MKPolygonView* polygonView in self.overlayViews) {
//        
//        if (polygon.points->x == polygonView.polygon.points->x) {
//            NSLog(@"rob");
//        }
//        
//    }
//    return nil;
    
    return [self.kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.kmlParser viewForAnnotation:annotation];
}


@end
