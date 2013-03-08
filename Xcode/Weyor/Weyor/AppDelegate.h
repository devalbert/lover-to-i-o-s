//
//  AppDelegate.h
//  Weyor
//
//  Created by Albert Zhao on 1/24/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIView *loadingView;
    UIActivityIndicatorView *progressView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *userJID;

- (void)startLoading;
- (void)stopLoading;

+ (AppDelegate *)sharedApp;

@end
