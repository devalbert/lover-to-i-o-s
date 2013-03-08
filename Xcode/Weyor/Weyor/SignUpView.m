//
//  SignUpView.m
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SignUpView.h"

#import "WYButton.h"
#import "SignUpPresenter.h"

@interface SignUpView ()

@end

@implementation SignUpView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    presenter = [[SignUpPresenter alloc] initWithView:self];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];
    WYButton *continueButton = [[WYButton alloc] initWithFrame:CGRectMake(46, 210, 228, 33) defaultImage:@"greenbutton.png" hightlightedImage:@"greenbutton2.png" title:@"Next" leftIcon:@"nextIcon.png"];
    [continueButton addTarget:presenter sel:@selector(continueProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    WYButton *loginButton = [[WYButton alloc] initWithFrame:CGRectMake(46, 310, 228, 33) defaultImage:@"regbutton2.png" hightlightedImage:@"regbutton.png" title:@"Sign In" leftIcon:@"headicon.png"];
    [loginButton addTarget:presenter sel:@selector(backToLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ISignUpView
- (SignUpView *)viewController {
    return self;
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
