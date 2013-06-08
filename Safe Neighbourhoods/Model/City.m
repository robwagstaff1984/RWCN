//
//  City.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "City.h"

@implementation City


- (id)init
{
    self = [super init];
    if (self) {
        self.neighbourhoods = [[NSArray alloc] init];
    }
    return self;
}
@end
