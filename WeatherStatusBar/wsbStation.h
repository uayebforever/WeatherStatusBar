//
//  wsbStation.h
//  WeatherStatusBar
//
//  Created by Andy Green on 2/02/13.
//  Copyright (c) 2013 Andy Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wsbStation : NSObject

@property NSString* name;
@property NSString* queryUrl;
@property NSString* xQuery;


- (id) init;

- (id) initWithTitle:(NSString*) stationName queryUrl:(NSString*) url queryString:(NSString*) query;

@end
