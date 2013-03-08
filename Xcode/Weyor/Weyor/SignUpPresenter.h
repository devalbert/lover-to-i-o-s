//
//  SignUpPresenter.h
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ISignUpView;

@interface SignUpPresenter : NSObject {
  @private
    id<ISignUpView> _view;
}

- (id)initWithView:(id<ISignUpView>)view;

- (void)backToLoginAction;
- (void)continueProcess;

@end
