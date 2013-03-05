//
//  RegUserConnection.m
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "RegUserConnection.h"

#import "User.h"

@implementation RegUserConnection

@synthesize delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMPP_REGUSER_SUCCESS_NOTIFICATION" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMPP_REGUSER_ERROR_NOTIFICATION" object:nil];
    self.theUser = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRegUserSuccessful:) name:@"XMPP_REGUSER_SUCCESS_NOTIFICATION" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRegUserError:) name:@"XMPP_REGUSER_ERROR_NOTIFICATION" object:nil];
    }
    return self;
}

- (void)reguser:(User *)user withPassword:(NSString *)password_ withDelegate:(id<RegUserConnectionDelegate>)delegate_ {
    self.delegate = delegate_;
    self.theUser = user;
    self.password = password_;
    ChaosRequest *request = [[ChaosRequest alloc] init];
    request.connectionURLString = [NSString stringWithFormat:@"http://www.weyor.com/reguser1_1.aspx?EM=%@", user.email];
    request.httpMethod = @"GET";
    request.delegate = self;
    [[ChaosAgent sharedAgent] inqueue:request];
}

#pragma mark - ChaosConnectionDelegate
- (void)response:(ChaosResponse *)resp {
    if (!resp.error) {
        NSString *regHtml = [resp htmlString];
        NSLog(@"%@", regHtml);
        NSArray *params = [regHtml componentsSeparatedByString:@";"];
        if (params && params.count == 3) {
            NSString *status = [params objectAtIndex:0];
            if ([status isEqualToString:@"0"]) {
                NSString *weNo = [params objectAtIndex:1];
                NSString *userJID = [NSString stringWithFormat:@"%@@weyor.com", weNo];
                NSLog(@"reg %@, and jid=%@", self.theUser.email, userJID);
                self.theUser.weno = userJID;
                [[XMPPManager sharedManager] regUser:userJID password:self.password];
                [self.delegate regUserSuccessful:self.theUser];
            } else {
                [self.delegate regUserError:[NSError errorWithDomain:@"" code:1010101 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:regHtml, @"HTML", nil]]];
            }
        } else {
            [self.delegate regUserError:[NSError errorWithDomain:@"" code:1010101 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:regHtml, @"HTML", nil]]];
        }
        // Reg User on web ok, should reg on xmpp
    } else {
        [self.delegate regUserError:resp.error];
    }
    
}

- (void)xmppRegUserSuccessful:(NSNotification *)notification {
    [self.delegate regUserSuccessful:self.theUser];
}

- (void)xmppRegUserError:(NSNotification *)notification {
    NSError *xmpperror = nil;
    if (notification && notification.object) {
        xmpperror = notification.object;
    } else {
        xmpperror = [NSError errorWithDomain:@"XMPP" code:102213 userInfo:nil];
    }
    [self.delegate regUserError:xmpperror];
}

@end
