//
//  ChaosResponse.m
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosResponse.h"
#import "CJSONDeserializer.h"

@implementation ChaosResponse
@synthesize delegate = delegate_;
@synthesize httpStatusCode = httpStatusCode_;
@synthesize error = error_;
@synthesize responseData = responseData_;
@synthesize supportXML;
@synthesize connectionAction;

- (void)dealloc
{
	delegate_ = nil;
	[error_ release];
	error_ = nil;
	[responseData_ release];
	responseData_ = nil;
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"ChaosResponse, statusCode=%d, error=%@", 
			self.httpStatusCode, self.error];
}

- (void)setResponseData:(NSData *)data
{
	[responseData_ release];
	responseData_ = [data retain];
}

- (NSString *)htmlString {
    NSString *html = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    return [html autorelease];
}

@end
