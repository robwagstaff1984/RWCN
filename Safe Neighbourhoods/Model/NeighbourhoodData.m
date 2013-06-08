//
//  SharedData.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "NeighbourhoodData.h"
#import "State.h"
#import "City.h"
#import "Neighbourhood.h"

@interface NeighbourhoodData ()

@end

static NeighbourhoodData *data = nil;

@implementation NeighbourhoodData
+ (NeighbourhoodData *)sharedData
{
    if (!data)
    {
        data = [[NeighbourhoodData alloc] init];
        [data loadData];
    }
    return data;
}

-(void) loadData {
    State *california = [[State alloc] init];
    california.name = @"California";
    
    City* sanfrancisco = [[City alloc] init];
    sanfrancisco.name = @"San Francisco";
    
    Neighbourhood* soma = [[Neighbourhood alloc] init];
    soma.name = @"Soma";
    soma.crimeIndex = 393.5;
    soma.population = 11130;
    
    sanfrancisco.Neighbourhoods = @[soma];
    california.cities = @[sanfrancisco];
    self.states = @[california];
}

@end

