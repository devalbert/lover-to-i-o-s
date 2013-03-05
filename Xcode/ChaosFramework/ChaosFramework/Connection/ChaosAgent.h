//
//  ChaosAgent.h
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONNECTION_FINISHED_NOTIFICATION @"Connection_task_finished_notification"
@class ChaosRequest;

@interface ChaosAgent : NSObject {
	NSMutableArray	*connectionQueue;
}

+ (id)sharedAgent;

- (void)inqueue:(ChaosRequest *)request;
- (void)cancelRequest:(NSString *)connectionIdentifier;

@end
