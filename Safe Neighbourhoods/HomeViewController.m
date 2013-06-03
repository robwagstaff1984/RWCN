//
//  HomeViewController.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "HomeViewController.h"
#import <MapKit/MapKit.h>

#define kTopAreaHeight 44
#define kBottomAreaHeight 44
#define kNavBarHeight 20

@interface HomeViewController () <MKMapViewDelegate>

@property(nonatomic, strong) MKMapView* mapView;
@end

@implementation HomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Safe Neighbourhoods";
        self.view.backgroundColor = [UIColor redColor];
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, kTopAreaHeight , SCREEN_WIDTH, SCREEN_HEIGHT - kTopAreaHeight - kBottomAreaHeight - kNavBarHeight)];
        self.mapView.backgroundColor = [UIColor blueColor];
        self.mapView.delegate = self;
        [self.view addSubview:self.mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
