//
//  ChaosResponse.h
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChaosResponseDelegate

@end

@interface ChaosResponse : NSObject
{
	id<ChaosResponseDelegate> delegate_;
	
	NSInteger		httpStatusCode_;
	NSError			*error_;
	NSData			*responseData_;
}

@property (nonatomic, assign) id<ChaosResponseDelegate> delegate;
@property (nonatomic, assign) BOOL supportXML;
@property (nonatomic, readwrite) NSInteger httpStatusCode;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSString *connectionAction;

- (NSString *)htmlString;

@end

