//
//  ChaosConnection.m
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosConnection.h"

#import "ChaosConnectionError.h"
#import "ChaosAgent.h"

@implementation ChaosConnection
@synthesize delegate = delegate_;
@synthesize request = request_;
@synthesize status = status_;

- (void)dealloc
{
    if (timeoutTimer && timeoutTimer.isValid) {
        [timeoutTimer invalidate];
    }
    [timeoutTimer release];
	self.delegate = nil;
    
	[request_ release];
	request_ = nil;
	responseData = nil;
	[super dealloc];
}

- (void)requestTimeout {
    if (status_ == connectionStatusFinished) {
    } else {
        [theConnection cancel];
        NSLog(@"Timeout for the network request");
        [theConnection release];
        ChaosConnectionError *error = [[ChaosConnectionError alloc] initWithDomain:ERROR_DOMAIN code:ERROR_CONNECTION_CODE userInfo:nil];
		response_.error = error;
		[error release];
		if (self.delegate && [self.delegate respondsToSelector:@selector(response:)])
		{
			[self.delegate response:response_];
		}
    }
}

- (void)connect
{
	NSAssert(self.request.delegate != nil, @"ConnectionDelegate of Request is nil");
	if (status_ == connectionStatusRunning || status_ == connectionStatusFinished)
	{
		return;
	}
	
	status_ = connectionStatusRunning;
	NSURL *url = [NSURL URLWithString:[request_.connectionURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	self.delegate = self.request.delegate;
	NSMutableURLRequest *connRequest = [NSMutableURLRequest requestWithURL:url];
	[connRequest setHTTPMethod:request_.httpMethod];
	[connRequest addValue:request_.contentType forHTTPHeaderField:CONNECTION_CONTENT_TYPE];
	if (request_.connectionMessage)
	{
        NSData *bodyData = [request_.connectionMessage dataUsingEncoding:NSUTF8StringEncoding];
        [connRequest addValue:[NSString stringWithFormat:@"%i", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
		[connRequest setHTTPBody:bodyData];
	}
	
	theConnection = [[NSURLConnection alloc] initWithRequest:connRequest delegate:self startImmediately:YES];
	response_ = [[ChaosResponse alloc] init];
	if (theConnection)
	{
        timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO] retain];
		responseData = [[NSMutableData data] retain];
	}
	else
	{
		// Create connection failed.
		ChaosConnectionError *error = [[ChaosConnectionError alloc] initWithDomain:ERROR_DOMAIN code:ERROR_CONNECTION_CODE userInfo:nil];
		response_.error = error;
		[error release];
		if (self.delegate && [self.delegate respondsToSelector:@selector(response:)])
		{
			[self.delegate response:response_];
		}
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//TFLog(@"%@", NSStringFromSelector(_cmd));
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	response_.httpStatusCode = [httpResponse statusCode];
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
        //		if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//TFLog(@"%@", NSStringFromSelector(_cmd));
    if (timeoutTimer && timeoutTimer.isValid) {
        [timeoutTimer invalidate];
    }
    [timeoutTimer release];
    timeoutTimer = nil;
    
	[responseData release];
	[connection release];
    theConnection = nil;
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(response:)])
	{
		response_.error = error;
        response_.connectionAction = request_.connectionAction;
		[self.delegate response:response_];
	}
	status_ = connectionStatusFinished;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//TFLog(@"%@", NSStringFromSelector(_cmd));
    if (timeoutTimer && timeoutTimer.isValid) {
        [timeoutTimer invalidate];
    }
    [timeoutTimer release];
    timeoutTimer = nil;
	status_ = connectionStatusFinished;
    
	[connection release];
    theConnection = nil;
	NSLog(@"%@", self.delegate);
	if (self.delegate && [self.delegate respondsToSelector:@selector(response:)])
	{
		response_.error = nil;
        response_.supportXML = request_.supportXML;
		response_.responseData = responseData;
        response_.connectionAction = request_.connectionAction;
        [responseData release];
        //		NSUInteger len = [responseData length];
        //		float kLen = (float)len / 1024.0f;
        //        NSString *message = [[NSString alloc] initWithData:response_.responseData encoding:NSUTF8StringEncoding];
        //        NSLog(@"--------%@", message);
        //        [message release];
        //        NSLog(@"JSON: %@", response_.jsonDictionary);
		[self.delegate response:response_];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_FINISHED_NOTIFICATION object:self];
}

@end
