//
//  State.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "State.h"

@implementation State

- (id)init
{
    self = [super init];
    if (self) {
        self.cities = [[NSArray alloc] init];
    }
    return self;
}

@end
