//
//  ChaosGPSManager.h
//  ChaosFramework
//
//  Created by Albert Zhao on 2/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CHAOSStableLocationBlock)(CLLocation * location);

@protocol ChaosGPSManagerDelegate;

@interface ChaosGPSManager : NSObject<CLLocationManagerDelegate> {
  @private
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSTimer *gpsLocationMonitor;
    CLLocation *stableWarmLocation;
    CHAOSStableLocationBlock block;
}

@property (nonatomic, assign) id<ChaosGPSManagerDelegate> delegate;

- (BOOL)currentStableLocation:(CHAOSStableLocationBlock)block;

@end

@protocol ChaosGPSManagerDelegate<NSObject>
- (void)locationServiceDisabled;
@end
