//
//  ChaosModel.h
//  Connection
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class ChaosRequest;

@protocol ChaosModel

- (ChaosRequest *)parseToRequest;
- (id)initWithDict:(NSDictionary *)dict;

@end

