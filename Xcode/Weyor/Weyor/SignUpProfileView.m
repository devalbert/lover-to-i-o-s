//
//  SignUpProfileView.m
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "SignUpProfileView.h"

#import "WYButton.h"
#import "SignUpProfilePresenter.h"

@interface SignUpProfileView ()

@end

@implementation SignUpProfileView

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
    presenter = [[SignUpProfilePresenter alloc] initWithView:self];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:243.0/255.0 blue:238.0/255.0 alpha:1.0];
    
    WYButton *continueButton = [[WYButton alloc] initWithFrame:CGRectMake(46, 260, 228, 33) defaultImage:@"greenbutton.png" hightlightedImage:@"greenbutton2.png" title:@"Submit" leftIcon:@"completeIcon.png"];
    //    [continueButton addTarget:presenter sel:@selector(signInProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [presenter backAction];
}

#pragma mark - ISignUpProfileView
- (SignUpProfileView *)viewController {
    return self;
}

@end
