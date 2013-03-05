//
//  DemoSignupController.h
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RegUserConnection.h"

@interface DemoSignupController : UIViewController<RegUserConnectionDelegate> {
    RegUserConnection *regUser;
}

@property (nonatomic, strong) IBOutlet UITextField *emailField;

- (IBAction)backAction:(id)sender;
- (IBAction)regProcess:(id)sender;

@end
