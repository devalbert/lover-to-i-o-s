//
//  SignUpProfilePresenter.m
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SignUpProfilePresenter.h"
#import "SignUpProfileView.h"

@implementation SignUpProfilePresenter

- (id)initWithView:(id<ISignUpProfileView>)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (void)backAction {
    [[_view viewController].navigationController popViewControllerAnimated:YES];
}

@end
