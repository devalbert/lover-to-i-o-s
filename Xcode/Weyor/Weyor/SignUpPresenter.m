//
//  SignUpPresenter.m
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SignUpPresenter.h"

#import "SignUpView.h"
#import "SignUpProfileView.h"

@implementation SignUpPresenter

- (id)initWithView:(id<ISignUpView>)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (void)backToLoginAction {
    [[_view viewController].navigationController popViewControllerAnimated:YES];
}

- (void)continueProcess {
    SignUpProfileView *signProfileView = [[SignUpProfileView alloc] initWithNibName:@"SignUpProfileView" bundle:nil];
    [[_view viewController].navigationController pushViewController:signProfileView animated:YES];
}

@end
