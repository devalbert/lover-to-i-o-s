//
//  SignUpView.h
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpPresenter;
@class SignUpView;
@protocol ISignUpView <NSObject>
- (SignUpView *)viewController;
@end

@interface SignUpView : UIViewController<ISignUpView> {
  @private
    SignUpPresenter *presenter;
}

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

@end
