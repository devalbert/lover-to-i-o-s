//
//  ChaosFile.h
//  Chaos
//
//  Created by Albert Zhao on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChaosFile : NSObject {
	NSString	*url;
	NSString	*fileName;
	id<NSObject> identifier;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) id<NSObject> identifier;

@end
