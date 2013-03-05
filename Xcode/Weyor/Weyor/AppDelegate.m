//
//  AppDelegate.m
//  Weyor
//
//  Created by Albert Zhao on 1/24/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "AppDelegate.h"

#import "SplashViewController.h"
#import "XMPPManager.h"

// Demo
#import "DemoRootController.h"


#import "User.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    DemoRootController *mainController = [[DemoRootController alloc] initWithNibName:@"DemoRootController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
    
    loadingView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    progressView.center = CGPointMake(loadingView.frame.size.width / 2.0, loadingView.frame.size.height / 2.0);
    [loadingView addSubview:progressView];
    [self.window addSubview:loadingView];
    loadingView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persenceArrived:) name:@"PERSENSE_ARRIVED" object:nil];
    
    return YES;
}

- (void)persenceArrived:(NSNotification *)notify {
    if (notify && notify.object) {
        XMPPPresence *presence = notify.object;
        NSLog(@"[Presence] %@", presence);
        if ([presence.type isEqualToString:@"subscribe"]) {
            self.userJID = presence.fromStr;
            NSString *inviteInfo = [NSString stringWithFormat:@"%@邀请你成为TA的朋友", presence.from.full];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"好友邀请" message:inviteInfo delegate:self cancelButtonTitle:@"暂不处理" otherButtonTitles:@"接受请求", @"拒绝请求", nil];
            [alertView show];
        } else if ([presence.type isEqualToString:@"unsubscribe"]) {
            NSString *inviteInfo = [NSString stringWithFormat:@"%@拒绝成为你的朋友", presence.from.full];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"对方决绝了你的邀请" message:inviteInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else if ([presence.type isEqualToString:@"unsubscribed"]) {
            NSString *inviteInfo = [NSString stringWithFormat:@"%@没有成为你的朋友", presence.from.full];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"对方决绝了你的邀请" message:inviteInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else if ([presence.type isEqualToString:@"subscribed"]) {
            NSString *inviteInfo = [NSString stringWithFormat:@"%@已经成为你的朋友", presence.from.full];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"对方接受了你的邀请" message:inviteInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            NSString *inviteInfo = [NSString stringWithFormat:@"%@发了一条Presence", presence.from.full];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未处理的Presence" message:inviteInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        // subscribe: manual
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"Accept");
        [[XMPPManager sharedManager] acceptInvitation:self.userJID];
    } else if (buttonIndex == 2) {
        NSLog(@"Reject");
        [[XMPPManager sharedManager] rejectInvitation:self.userJID];
    } else {
        NSLog(@"Cancel");
    }
}

- (void)startLoading {
    loadingView.hidden = NO;
    [self.window bringSubviewToFront:loadingView];
    [progressView startAnimating];
}

- (void)stopLoading {
    [progressView stopAnimating];
    loadingView.hidden = YES;
}

+ (AppDelegate *)sharedApp {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
