//
//  ChaosFileManager.m
//  Chaos
//
//  Created by Albert Zhao on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChaosFileFetcher.h"

#define APP_NAME @"DDY"

@interface ChaosFileFetcher(Private)
- (void)prepareTempPathForApp;
@end

@implementation ChaosFileFetcher
static ChaosFileFetcher *instance;
+ (ChaosFileFetcher *)sharedFetcher
{
	@synchronized(instance)
	{
		if (!instance)
		{
			instance = [[ChaosFileFetcher alloc] init];
			[instance prepareTempPathForApp];
		}
	}
	return instance;
}

- (void)prepareTempPathForApp
{
	NSString *tempPath = NSTemporaryDirectory();
	tempPath = [tempPath stringByAppendingPathComponent:APP_NAME];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = YES;
	if (![fileManager fileExistsAtPath:tempPath isDirectory:&isDirectory])
	{
		[fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	[tempCachePath release];
	tempCachePath = [tempPath retain];
}

- (NSData *)getFile:(ChaosFile *)file
{
	if (!tempCachePath)
	{
		[self prepareTempPathForApp];
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filePath = [tempCachePath stringByAppendingPathComponent:file.fileName];
	if ([fileManager fileExistsAtPath:filePath])
	{
		return [fileManager contentsAtPath:filePath];
	}
	else {
		return nil;
	}
}

- (void)cacheFile:(ChaosFile *)file withData:(NSData *)data
{
	if (!tempCachePath)
	{
		[self prepareTempPathForApp];
	}
	@synchronized( self )
	{
		NSString *filePath = [tempCachePath stringByAppendingPathComponent:file.fileName];
//		TFLog(@"Cached file at %@", filePath);
		[data writeToFile:filePath atomically:YES];
	}
}

@end
