//
//  ChaosFile.m
//  Chaos
//
//  Created by Albert Zhao on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosFile.h"


@implementation ChaosFile
@synthesize url, fileName, identifier;

- (void)dealloc
{
	[url release];
	[fileName release];
	[identifier release];
	[super dealloc];
}

@end
