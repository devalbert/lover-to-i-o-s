//
//  SplashPresenter.m
//  Weyor
//
//  Created by Albert Zhao on 3/7/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SplashPresenter.h"

#import "SplashViewController.h"
#import "SignUpView.h"

@implementation SplashPresenter

@synthesize isRememberPassword;

- (id)initWithView:(id<ISplashView>)view {
    self = [super init];
    if (self) {
        _view = view;
        // Load quickly
        self.isRememberPassword = YES;
    }
    return self;
}

- (void)signInProcess {
    NSLog(@"Sign In with %@:%@", [_view getUsername], [_view getPassword]);
}

- (void)signUpProcess {
    NSLog(@"Sign Up Process");
    SignUpView *signUpView = [[SignUpView alloc] initWithNibName:@"SignUpView" bundle:nil];
    [[_view viewController].navigationController pushViewController:signUpView animated:YES];
}

- (void)loadRememberPasswordStatus {
    [_view enableRememberPassword:self.isRememberPassword];
}

- (void)setIsRememberPassword:(BOOL)isRememberPassword_ {
    isRememberPassword = isRememberPassword_;
    [self loadRememberPasswordStatus];
}

@end
