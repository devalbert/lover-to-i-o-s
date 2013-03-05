//
//  ChaosDownload.m
//  Chaos
//
//  Created by Albert Zhao on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosPhotoDownload.h"


@implementation ChaosPhotoDownload
@synthesize delegate;
@synthesize identifier;
@synthesize url;
@synthesize downloadedPhotoData;
@synthesize photoData;
@synthesize photoConnection;
@synthesize httpStatusCode;

- (void)dealloc {
//	TFLog(@"DEALLOC FOR %@", self);
	[url release];
	[downloadedPhotoData release];
	url = nil;
	delegate = nil;
	identifier = nil;
	[super dealloc];
}

- (id)initWithIdentifier:(id)identifierParam withURL:(NSString *)urlParam
{
	self = [super init];
	if ( self )
	{
		identifier = identifierParam;
		url = [urlParam retain];
	}
	return self;
}

- (void)startDownload
{
    self.photoData = [NSMutableData data];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
	
	self.photoConnection = conn;
	[conn release];
}

- (void)cancelDownload
{
    [self.photoConnection cancel];
    self.photoConnection = nil;
    self.photoData = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	expectedSize = [response expectedContentLength];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    httpStatusCode = [httpResponse statusCode];
//	float kLen = (float)expectedSize / 1024.0f;
//	NSLog(@"Expected Size: %.2fK, [url=%@]", kLen, self.url);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.photoData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.delegate)
	{
		[self.delegate photoDidDownload:nil];
	}
    self.photoData = nil;
    self.photoConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (httpStatusCode == 200 && self.photoData) {
		NSUInteger len = [self.photoData length];
		if (len == expectedSize) {
            [downloadedPhotoData release];
            downloadedPhotoData = [self.photoData retain];
        }
	}
    
    if (self.delegate) {
        [self.delegate photoDidDownload:self.identifier];
    }
	
    self.photoData = nil;
    self.photoConnection = nil;
}

@end
