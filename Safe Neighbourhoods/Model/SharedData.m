//
//  SharedData.m
//  Safe Neighbourhoods
//
//  Created by Robert Wagstaff on 3/06/13.
//  Copyright (c) 2013 Automagical. All rights reserved.
//

#import "SharedData.h"

@interface SharedData ()

@end

static SharedData *data = nil;

@implementation SharedData
+ (SharedData *)sharedData
{
    if (!data)
    {
        data = [[SharedData alloc] init];
    }
    return data;
}

@end

