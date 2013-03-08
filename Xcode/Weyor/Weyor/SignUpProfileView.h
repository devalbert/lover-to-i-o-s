//
//  SignUpProfileView.h
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignUpProfileView;
@class SignUpProfilePresenter;
@protocol ISignUpProfileView <NSObject>
- (SignUpProfileView *)viewController;
@end

@interface SignUpProfileView : UIViewController<ISignUpProfileView> {
  @private
    SignUpProfilePresenter *presenter;
}

- (IBAction)backAction:(id)sender;

@end
