//
//  DemoSignupController.m
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "DemoSignupController.h"

#import "User.h"
#import "AppDelegate.h"

@interface DemoSignupController ()

@end

@implementation DemoSignupController

- (void)dealloc {
    self.emailField = nil;
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.emailField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 1. Reguser: http://www.weyor.com/reguser1_1.aspx?EM=a1@aa.com
 Description:
 [[NetworkSDK sharedSDK] regUser:email delegate:self];
 if reg user at weyor.com successful
 reg user at XMPP Server
 if reg successful
 else {
 remove user from weyor.com
 call delegate error
 }
 else
 call delegate error
 3.
 */
- (IBAction)regProcess:(id)sender {
    [self.emailField resignFirstResponder];
    NSString *email = self.emailField.text;
    if (!email || [email isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Email不能为空！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [[AppDelegate sharedApp] startLoading];
    
    regUser = nil;
    regUser = [[RegUserConnection alloc] init];
    User *user = [[User alloc] init];
    user.email = email;
    [regUser reguser:user withPassword:@"111111" withDelegate:self];
}

#pragma mark -
- (void)regUserError:(NSError *)error {
    [[AppDelegate sharedApp] stopLoading];
    NSString *html = nil;
    if (error.userInfo) {
        html = [error.userInfo objectForKey:@"HTML"];
    }
    NSLog(@"regUserError: %@", error);
    NSString *errInfo = [NSString stringWithFormat:@"服务器返回：%@\n%@", html, [error localizedDescription]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册用户失败" message:errInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    return;
}

- (void)regUserSuccessful:(User *)user {
    [[AppDelegate sharedApp] stopLoading];
    NSString *userInfo = [NSString stringWithFormat:@"登录信息：\nWeNo: %@\n密码:111111", user.weno];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册用户成功" message:userInfo delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

@end
