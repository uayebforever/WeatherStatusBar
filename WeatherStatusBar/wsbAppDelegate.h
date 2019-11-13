//
//  wsbAppDelegate.h
//  WeatherStatusBar
//
//  Created by Andy Green on 18/01/13.
//  Copyright (c) 2013 Andy Green. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "wsbStation.h"

@interface wsbAppDelegate : NSObject <NSApplicationDelegate>


@property IBOutlet NSMenu *statusMenu;

//@property IBOutlet NSTextView *textView;

@property (strong, nonatomic) NSStatusItem *statusBar;

//@property NSAlert *alertSheet;

- (NSArray *) getURLData:(NSString *) urlString xqueryString:(NSString *) query;

- (IBAction)refresh:(id)sender;

@property NSTimer *refreshTimer;

@property NSMutableArray *stationList;

@property wsbStation *currentStation;

@end
