//
//  DemoSigninController.m
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "DemoSigninController.h"
#import "XMPPManager.h"

#import "AppDelegate.h"

@interface DemoSigninController ()

@end

@implementation DemoSigninController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMPP_AUTHENTICATE_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMPP_AUTHENTICATE_ERROR" object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppAutheticateSuccess:) name:@"XMPP_AUTHENTICATE_SUCCESS" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppAutheticateError:) name:@"XMPP_AUTHENTICATE_ERROR" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *user = [[XMPPManager sharedManager] loginedUser];
    if (user) {
        NSLog(@"login-ed user: %@", user);
        self.wenoField.text = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPP_AUTHENTICATE_SUCCESS" object:nil];
    }
}

- (void)xmppAutheticateSuccess:(NSNotification *)notify {
    [[AppDelegate sharedApp] stopLoading];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
    self.friendsView.hidden = NO;
    // Update VCard
//    [[XMPPManager sharedManager] requestUserVcard:@"29059@weyor.com"];
    [[XMPPManager sharedManager] updateMyVcard];
    [[XMPPManager sharedManager] removeInvitation:@"29097@weyor.com"];
}

- (void)xmppAutheticateError:(NSNotification *)notify {
    [[AppDelegate sharedApp] stopLoading];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    self.friendsView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInAction:(id)sender {
    [self.wenoField resignFirstResponder];
    NSString *weno = self.wenoField.text;
    if (!weno || [weno isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"微号不能为空！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSString *myJID = [NSString stringWithFormat:@"%@@weyor.com", weno];
    [[XMPPManager sharedManager] connect:myJID password:@"111111"];
    [[AppDelegate sharedApp] startLoading];
}

- (IBAction)backAction:(id)sender {
    [self.wenoField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteUserAppearAction:(id)sender {
    self.inviteFriendsView.hidden = NO;
    self.friendsView.hidden = YES;
}

- (IBAction)inviteUserAction:(id)sender {
    [self.userWenoField resignFirstResponder];
    NSString *userWeno = self.userWenoField.text;
    if (!userWeno || [userWeno isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"对方微号不能为空！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSString *userJID = [NSString stringWithFormat:@"%@@weyor.com", userWeno];
    [[XMPPManager sharedManager] inviteUser:userJID];
    
    self.inviteFriendsView.hidden = YES;
    self.friendsView.hidden = NO;
    
    /*
     <iq xmlns="jabber:client" type="set" id="87-694" to="29054@weyor.com/99815dae"><query xmlns="jabber:iq:roster"><item jid="12@weyor.com" ask="subscribe" subscription="none"/></query></iq>
     
     <iq xmlns="jabber:client" type="set" id="666-697" to="29054@weyor.com/9976fab3"><query xmlns="jabber:iq:roster"><item jid="29053@weyor.com" ask="subscribe" subscription="none"/></query></iq>
     */
}

- (IBAction)updateVCardAction:(id)sender {
    [[XMPPManager sharedManager] updateMyVcard];
}

@end
