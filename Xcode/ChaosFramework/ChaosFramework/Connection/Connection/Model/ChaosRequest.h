//
//  ChaosRequest.h
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChaosConnectionDelegate;

@interface ChaosRequest : NSObject
{
	NSString		*connectionURLString_;
	NSString		*connectionMessage_;
	NSString		*connectionAction_;
	NSString		*contentType_;
	NSString		*httpMethod_;

	id<ChaosConnectionDelegate> delegate_;
}

@property (nonatomic, assign) id<ChaosConnectionDelegate> delegate;

@property (nonatomic, retain) NSString *connectionURLString;
@property (nonatomic, retain) NSString *connectionMessage;
@property (nonatomic, retain) NSString *connectionAction;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, assign) BOOL supportXML;

@property (nonatomic, retain, readonly) NSString *connectionIdentifier;

@end

