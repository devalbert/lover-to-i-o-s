//
//  RegUserConnection.h
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Chaos.h"
#import "XMPPManager.h"

@class User;
@protocol RegUserConnectionDelegate;
/*
 1. Reguser: http://www.weyor.com/reguser1_1.aspx?EM=a1@aa.com
    Description:
        [[NetworkSDK sharedSDK] regUser:email delegate:self];
            if reg user at weyor.com successful
                reg user at XMPP Server
                    if reg successful
                        call delegate ok
                    else {
                        remove user from weyor.com
                        call delegate error
                    }
            else
                call delegate error
 
 User
 */
@interface RegUserConnection : NSObject<ChaosConnectionDelegate> {
}

@property (nonatomic, assign) id<RegUserConnectionDelegate> delegate;
@property (strong, nonatomic) User *theUser;
@property (strong, nonatomic) NSString *password;

- (void)reguser:(User *)user withPassword:(NSString *)password withDelegate:(id<RegUserConnectionDelegate>)delegate;

@end

@protocol RegUserConnectionDelegate <NSObject>
- (void)regUserError:(NSError *)error;
- (void)regUserSuccessful:(User *)user;
@end