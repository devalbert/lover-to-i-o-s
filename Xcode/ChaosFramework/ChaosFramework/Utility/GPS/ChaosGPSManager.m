//
//  ChaosGPSManager.m
//  ChaosFramework
//
//  Created by Albert Zhao on 2/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChaosGPSManager.h"

@implementation ChaosGPSManager

@synthesize delegate;

- (void)dealloc {
    [currentLocation release];
    if (gpsLocationMonitor) {
        if ([gpsLocationMonitor isValid]) {
            [gpsLocationMonitor invalidate];
        }
        [gpsLocationMonitor release];
    }
    if (block) {
        Block_release(block);
    }
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        locationManager.delegate = self;
    }
    
    return self;
}

- (BOOL)currentStableLocation:(CHAOSStableLocationBlock)block_ {
    currentLocation = nil;
    Block_release(block);
    block = Block_copy(block_);
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
        return YES;
    }
    return NO;
}

- (void)gpsMonitorDie {
    // Count down ended
    gpsLocationMonitor = nil;
    currentLocation = stableWarmLocation;
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager stopUpdatingLocation];
    }
    // Callblock
    if (block) {
        block(currentLocation);
    }
}

- (void)startGPSMonitor {
    if (gpsLocationMonitor) {
        if ([gpsLocationMonitor isValid]) {
            [gpsLocationMonitor invalidate];
        }
        [gpsLocationMonitor release];
    }
    gpsLocationMonitor = [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gpsMonitorDie) userInfo:nil repeats:NO] retain];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (!newLocation) {
        return;
    }
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) > 0.01) {
        return;
    }
    
    if (stableWarmLocation) {
        if (stableWarmLocation.coordinate.latitude == newLocation.coordinate.latitude && stableWarmLocation.coordinate.longitude == newLocation.coordinate.longitude && stableWarmLocation.horizontalAccuracy == newLocation.horizontalAccuracy) {
            
        } else {
            [stableWarmLocation release];
            stableWarmLocation = [newLocation retain];
            [self startGPSMonitor];
        }
    } else {
        [stableWarmLocation release];
        stableWarmLocation = [newLocation retain];
        [self startGPSMonitor];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (delegate && [delegate respondsToSelector:@selector(locationServiceDisabled)]) {
        [delegate locationServiceDisabled];
        self.delegate = nil;
    }
}

@end
