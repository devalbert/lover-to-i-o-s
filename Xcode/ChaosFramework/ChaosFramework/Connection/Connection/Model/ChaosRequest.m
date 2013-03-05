//
//  ChaosRequest.m
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosRequest.h"

@interface ChaosRequest()
@property (nonatomic, retain, readwrite) NSString *connectionIdentifier;
@end

@implementation ChaosRequest

@synthesize connectionURLString = connectionURLString_;
@synthesize connectionMessage = connectionMessage_;
@synthesize connectionAction = connectionAction_;
@synthesize contentType = contentType_;
@synthesize httpMethod = httpMethod_;
@synthesize supportXML;

@synthesize delegate = delegate_;

@synthesize connectionIdentifier;

- (void)dealloc
{
	delegate_ = nil;
	[connectionURLString_ release];
	connectionURLString_ = nil;
	[connectionMessage_ release];
	connectionMessage_ = nil;
	[connectionAction_ release];
	connectionAction_ = nil;
	[contentType_ release];
	contentType_ = nil;
	[httpMethod_ release];
	httpMethod_ = nil;
	[super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.connectionIdentifier = [NSString stringWithFormat:@"Connection_%.12f_%ld", [[NSDate date] timeIntervalSince1970], random() / 200];
    }
    
    return self;
}

@end
