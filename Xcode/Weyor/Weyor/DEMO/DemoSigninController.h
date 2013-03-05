//
//  DemoSigninController.h
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoSigninController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *wenoField;
@property (nonatomic, strong) IBOutlet UIView *friendsView;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@property (nonatomic, strong) IBOutlet UITextField *userWenoField;
@property (nonatomic, strong) IBOutlet UIView *inviteFriendsView;

- (IBAction)inviteUserAppearAction:(id)sender;

- (IBAction)signInAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)inviteUserAction:(id)sender;
- (IBAction)updateVCardAction:(id)sender;

@end
