//
//  wsbAppDelegate.m
//  WeatherStatusBar
//
//  Created by Andy Green on 18/01/13.
//  Copyright (c) 2013 Andy Green. All rights reserved.
//

#import "wsbAppDelegate.h"

#import "wsbStation.h"

@implementation wsbAppDelegate

@synthesize statusBar = _statusBar;

@synthesize currentStation;

@synthesize stationList;



//@synthesize textView;

//@synthesize alertSheet;

- (id)init {
    self = [super init];
/*    if (self) {
        // Create an alert sheet used to show connection and parse errors
        alertSheet = [[NSAlert alloc] init];
        [alertSheet addButtonWithTitle:@"OK"];
        [alertSheet setAlertStyle:NSWarningAlertStyle];
    } */
    
    
    stationList = [NSMutableArray array];

    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Sydney Observatory Hill"
                            queryUrl:@"http://www.bom.gov.au/nsw/observations/sydney.shtml"
                            queryString:@"data(//td[contains(@headers, \"station-sydney-observatory-hill\")][contains(@headers, \"-tmp\")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Sydney Olympic Park"
                            queryUrl:@"http://www.bom.gov.au/nsw/observations/sydney.shtml"
                            queryString:@"data(//td[contains(@headers, \"station-sydney-olympic-park\")][contains(@headers, \"-tmp\")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Coonabarabran Airport"
                            queryUrl:@"http://www.bom.gov.au/nsw/observations/nswall.shtml"
                            queryString:@"data(//td[contains(@headers, \"tCWS-station-coonabarabran-airport\")][contains(@headers, \"tCWS-tmp \")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Melbourne Airport"
                            queryUrl:@"http://www.bom.gov.au/vic/observations/melbourne.shtml"
                            queryString:@"data(//td[contains(@headers, \"station-melbourne\")][contains(@headers, \"-tmp \")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Rhyll"
                            queryUrl:@"http://www.bom.gov.au/vic/observations/melbourne.shtml"
                            queryString:@"data(//td[contains(@headers, \"station-rhyll\")][contains(@headers, \"-tmp \")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Macleod Community Garden"
                            queryUrl:@"https://www.wunderground.com/personal-weather-station/dashboard?ID=IMELBOUR428"
//                            queryUrl:@"https://postman-echo.com/get?foo1=bar1&foo2=bar2"
                            queryString:@"data(//span[@data-station=\"IMELBOUR428\"][@data-variable=\"temperature\"]/span[@class=\"wx-value\"])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Hatcher Resevoir"
                            queryUrl:@"https://www.wunderground.com/weather/us/co/pagosa-springs/KCOPAGOS87"
                            //                            queryUrl:@"https://postman-echo.com/get?foo1=bar1&foo2=bar2"
                            queryString:@"data(//div[@class=\"current-temp\"]//span[contains(@class, \"wu-value\")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Canberra"
                            queryUrl:@"http://www.bom.gov.au/act/observations/canberra.shtml"
                            queryString:@"data(//td[contains(@headers, \"station-canberra\")][contains(@headers, \"-tmp \")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Moruya Airport"
                            queryUrl:@"http://www.bom.gov.au/nsw/observations/nswall.shtml"
                            queryString:@"data(//td[contains(@headers, \"tSC-station-moruya-airport\")][contains(@headers, \"tSC-tmp \")])"]];
    [stationList addObject:[[wsbStation alloc]
                            initWithTitle:@"Denver"
                            queryUrl:@"http://www.crh.noaa.gov/bou/include/webmstr.php?product=webmstr.txt"
                            queryString:@"substring-after(data(//table//table/tr[td[1]/font/strong=\"Denver Int'l Airport\"]/td[2]),\"\n\")"]];
    
    // Set the default station
    self.currentStation = [stationList objectAtIndex:0];

    // Register for wake notification so we know to refresh
    NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [center addObserver:self
               selector:@selector(machineDidWake:)
                   name:NSWorkspaceDidWakeNotification 
                 object:NULL];

    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:360 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];

    [self refresh:(id) nil];
    
    
    
}

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.title = @"wsb";
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    
    for (int i = 0; i < [[self stationList] count]; i++) {
        wsbStation * station = [[self stationList] objectAtIndex: i];
        NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:station.name action:@selector(changeStation:) keyEquivalent:@""];
        [item setTarget:self];
        [item setTag:i];
//        [item setOnStateImage:[NSImage imageNamed:@"NSMenuRadio"]];
        [[self statusMenu] insertItem:item atIndex:2+i ];
        

    }

}

/* The machineDidWake notification is received when the system is no longer
 sleeping. We delete the old timer and start a new one. */

- (void) machineDidWake:(NSNotification *)notification
{
    [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:360 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
//    NSLog(@"WeatherStatusBar Refresh timer state (after wakeup): %c %@", [self.refreshTimer isValid], [[self.refreshTimer fireDate] description]);
    
    [self refresh:(id) nil];

}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    NSString * name = [item title];
    [item setState:((name == [self.currentStation name]) ? NSOnState : NSOffState)];
    return YES;
}


- (void) changeStation:(id) sender {
    NSInteger stationId = [sender tag];
    self.currentStation = [self.stationList objectAtIndex:stationId];
    [self refresh:nil];
}


- (IBAction)refresh:(id)sender
{
    NSString* url = [[self currentStation] queryUrl];
    NSString* query = [[self currentStation] xQuery];
    
    NSArray *result = [self getURLData:url xqueryString:query];
    
    //NSData *data = [result objectAtIndex:0];
    //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ((result) && ([result count] > 0)) {
        NSString *string = [[result objectAtIndex:0] description];
        //[textView setString:string];
        
        // Format the temperature
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormat:@"###0.#"];
        NSNumber* temp = [formatter numberFromString:string];
        temp = [NSNumber numberWithDouble:round([temp doubleValue])];
        string = [formatter stringFromNumber:temp];
        
        // Append degree symbol
        string = [string stringByAppendingString:@"°"];
        
        // Reset timer to standard update rate if the error has just cleared
        if ([self.statusBar.title  isEqual: @"--°"]) {
            [self.refreshTimer invalidate];
        }
        
        self.statusBar.title = string;
        self.statusBar.toolTip = nil;
    } else {
        // No valid result, display error in status bar
        self.statusBar.title = @"--°";
        
        // Increase the refresh rate
        [self.refreshTimer invalidate];
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    }
        
        
//    NSLog(@"WeatherStatusBar Refresh timer state: %c %@", [self.refreshTimer isValid], [[self.refreshTimer fireDate] description]);
    
    if (![self.refreshTimer isValid]){
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:360 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    }
    
//    [string dealloc];

}

- (NSArray *) getURLData:(NSString *) urlString xqueryString:(NSString *) query
{

    NSURL* url;
    url = [NSURL URLWithString:urlString];
    
//    NSLog(@"WeatherStatusBar URL: %@", [url absoluteString]);
    
    // Synchronously grab the data
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Set the useragent becaus some websites barf (e.g. Weather Underground)
    [request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
    
    NSError *error;
    NSURLResponse *response;
    NSData *rawhtml = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *result;
    
    if (!rawhtml) {
        // Change the text of the alert sheet to contain the connection error, then display it
/*        [alertSheet setMessageText:@"Request error"];
        [alertSheet setInformativeText:[error localizedDescription]];
        [alertSheet beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
 */
        NSLog(@"WeatherStatusBar web request error: %@",[error localizedDescription]);
        // clear out old value
        self.statusBar.toolTip = [error localizedDescription];
    }
    else {
        // Parse the document with NSXMLDocument
        
//        NSLog(@"WeatherStatusBar Raw HTML: %@",
//              [[NSString alloc] initWithData:rawhtml encoding:NSASCIIStringEncoding]);
        
        NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:rawhtml options:NSXMLDocumentTidyHTML error:&error];
        if (doc) {
            [doc setURI:[url absoluteString]];
        } else {
            
            if (error) {
                // Change the text of the alert sheet to contain the parse error, then display it
                /*            [alertSheet setMessageText:@"Parse error"];
                 [alertSheet setInformativeText:[error localizedDescription]];
                 [alertSheet beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
                 // Don't allow the user to switch from the Source tab
                 // NSAssert(NO, @"Invalid XML");
                 */
                NSLog(@"WeatherStatusBar XML Parse error: %@",[error localizedDescription]);
            }
        }
        result = [doc objectsForXQuery:query constants:nil error:&error];
        
//        NSLog(@"WeatherStatusBar XQuery Result: %@", result);
        
        self.statusBar.toolTip = [error localizedDescription];

    }

    return result;
    
}

@end
