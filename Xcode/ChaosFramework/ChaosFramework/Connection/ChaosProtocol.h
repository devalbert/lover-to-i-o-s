//
//  ChaosProtocol.h
//  Chaos
//
//  Created by Albert Zhao on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChaosConnectionDelegate<NSObject>
- (void)response:(ChaosResponse *)resp;
@end
