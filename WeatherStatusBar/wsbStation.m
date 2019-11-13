//
//  wsbStation.m
//  WeatherStatusBar
//
//  Created by Andy Green on 2/02/13.
//  Copyright (c) 2013 Andy Green. All rights reserved.
//

#import "wsbStation.h"

@implementation wsbStation

@synthesize name;
@synthesize queryUrl;
@synthesize xQuery;



- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithTitle:(NSString *)stationName queryUrl:(NSString *)url queryString:(NSString *) query {
    if (self = [super init]) {
        [self setQueryUrl:url];
        [self setXQuery:query];
        [self setName:stationName];
    }
    return self;
}


@end
