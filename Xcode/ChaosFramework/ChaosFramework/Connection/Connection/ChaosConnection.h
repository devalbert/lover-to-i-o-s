//
//  ChaosConnection.h
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChaosRequest.h"
#import "ChaosResponse.h"
#import "ChaosProtocol.h"

#define CONNECTION_CONTENT_TYPE @"Content-Type"

typedef enum {
	connectionStatusInitial = 0,
	connectionStatusRunning = 1,
	connectionStatusFinished = 2,
} connectionStatus;

@interface ChaosConnection : NSObject
{
	id<ChaosConnectionDelegate> delegate_;
	
	connectionStatus			status_;
	
	// Response from Network
	NSMutableData	*responseData;
	
	// Cached request
	ChaosRequest	*request_;
	// Response
	ChaosResponse	*response_;
    
    // Timeout control
    NSTimer *timeoutTimer;
    
    NSURLConnection *theConnection;
}

@property (nonatomic, assign) id<ChaosConnectionDelegate> delegate;
@property (nonatomic, retain) ChaosRequest *request;
@property (nonatomic, readonly) connectionStatus status;

- (void)connect;

@end

