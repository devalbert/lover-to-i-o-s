//
//  ChaosFileManager.h
//  Chaos
//
//  Created by Albert Zhao on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChaosFile.h"

@interface ChaosFileFetcher : NSObject {
	NSString	*tempCachePath;
}

+ (ChaosFileFetcher *)sharedFetcher;

- (NSData *)getFile:(ChaosFile *)file;
- (void)cacheFile:(ChaosFile *)file withData:(NSData *)data;

@end
