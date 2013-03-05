//
//  ChaosAgent.m
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosAgent.h"

#import "ChaosConnection.h"

@interface ChaosAgent()
@property (nonatomic, assign) NSMutableArray *connectionQueue;

- (void)scanQueue;
- (void)taskFinished:(NSNotification *)notify;
@end

@implementation ChaosAgent
static ChaosAgent *instance;
@synthesize connectionQueue;

+ (id)sharedAgent
{
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[ChaosAgent alloc] init];
			instance.connectionQueue = [[NSMutableArray alloc] init];
			[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(taskFinished:) name:CONNECTION_FINISHED_NOTIFICATION object:nil];
		}
	}
	return instance;
}

- (void)inqueue:(ChaosRequest *)request
{
	if (request)
	{
		ChaosConnection *connection = [[ChaosConnection alloc] init];
		connection.request = request;
		[connectionQueue addObject:connection];
		[connection release];
	}
	
	[self scanQueue];
}

- (void)scanQueue
{
	for (int i=0; i<connectionQueue.count; i++) {
		ChaosConnection *connection = (ChaosConnection *)[connectionQueue objectAtIndex:i];
		if (connection.status == connectionStatusInitial)
		{
			[connection performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:NO];
		}
	}
}

- (void)cancelRequest:(NSString *)connectionIdentifier {
    if (!connectionIdentifier || [connectionIdentifier isEqualToString:@""]) return;
    for (int i=0; i<connectionQueue.count; i++) {
		ChaosConnection *connection = (ChaosConnection *)[connectionQueue objectAtIndex:i];
		if ([connection.request.connectionIdentifier isEqualToString:connectionIdentifier]) {
			[connection setDelegate:nil];
            [connectionQueue removeObject:connection];
            break;
		}
	}
}

- (void)taskFinished:(NSNotification *)notify
{
	@synchronized(self)
	{
		[connectionQueue removeObject:notify.object];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:instance name:CONNECTION_FINISHED_NOTIFICATION object:nil];
	[connectionQueue release];
	connectionQueue = nil;
	[super dealloc];
}

@end
