//
//  SplashViewController.m
//  Weyor
//
//  Created by Albert Zhao on 1/24/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SplashViewController.h"

#import "WYButton.h"
#import "SplashPresenter.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Presenter
    presenter = [[SplashPresenter alloc] initWithView:self];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];
    WYButton *loginButton = [[WYButton alloc] initWithFrame:CGRectMake(46, 210, 228, 33) defaultImage:@"greenbutton.png" hightlightedImage:@"greenbutton2.png" title:@"Sign In" leftIcon:@"headicon.png"];
    [loginButton addTarget:presenter sel:@selector(signInProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    WYButton *regButton = [[WYButton alloc] initWithFrame:CGRectMake(46, 310, 228, 33) defaultImage:@"regbutton2.png" hightlightedImage:@"regbutton.png" title:@"Sign Ip" leftIcon:@"regicon.png"];
    [regButton addTarget:presenter sel:@selector(signUpProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regButton];
    
    [presenter loadRememberPasswordStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rememberAction:(id)sender {
    presenter.isRememberPassword = !presenter.isRememberPassword;
}

- (IBAction)forgetPasswordAction:(id)sender {
    NSLog(@"forgetPasswordAction");
}

#pragma mark - ISplashView
- (void)setUser:(NSString *)username password:(NSString *)password {
}

- (void)enableRememberPassword:(BOOL)isEnabled {
    if (isEnabled) {
        self.rememberMemberIconView.image = [UIImage imageNamed:@"checked.png"];
    } else {
        self.rememberMemberIconView.image = [UIImage imageNamed:@"unchecked.png"];
    }
}

- (SplashViewController *)viewController {
    return self;
}

- (NSString *)getUsername {
    return self.usernameField.text;
}

- (NSString *)getPassword {
    return self.passwordField.text;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    return YES;
}

@end
