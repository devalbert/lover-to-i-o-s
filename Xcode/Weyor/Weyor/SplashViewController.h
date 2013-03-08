//
//  SplashViewController.h
//  Weyor
//
//  Created by Albert Zhao on 1/24/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplashPresenter;
@class SplashViewController;

@protocol ISplashView<NSObject>
- (void)setUser:(NSString *)username password:(NSString *)password;
- (void)enableRememberPassword:(BOOL)isEnabled;
- (SplashViewController *)viewController;
- (NSString *)getUsername;
- (NSString *)getPassword;
@end

@interface SplashViewController : UIViewController<ISplashView> {
  @private
    SplashPresenter *presenter;
}

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIImageView *rememberMemberIconView;

- (IBAction)rememberAction:(id)sender;
- (IBAction)forgetPasswordAction:(id)sender;

@end