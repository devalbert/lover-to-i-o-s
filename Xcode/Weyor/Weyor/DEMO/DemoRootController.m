//
//  DemoRootController.m
//  Weyor
//
//  Created by Albert.Zhao on 3/1/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "DemoRootController.h"

#import "DemoSignupController.h"
#import "DemoSigninController.h"

@interface DemoRootController ()

@end

@implementation DemoRootController

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

- (IBAction)regUserAction:(id)sender {
    DemoSignupController *viewController = [[DemoSignupController alloc] initWithNibName:@"DemoSignupController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)signInAction:(id)sender {
    DemoSigninController *viewController = [[DemoSigninController alloc] initWithNibName:@"DemoSigninController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
