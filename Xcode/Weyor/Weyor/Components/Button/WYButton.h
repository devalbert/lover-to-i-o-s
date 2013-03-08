//
//  WYButton.h
//  Weyor
//
//  Created by Albert Zhao on 3/7/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Introduction
 [WYButton buttonWithDefaultImage:hightlitedImage:title:leftIcon:]
 [WYButton buttonWithDefaultImage:hightlitedImage:title:]
 */
@interface WYButton : UIView {
  @private
    UIButton *overlapButton;
    UIImageView *leftIconView;
    
    NSString *defaultImage;
    NSString *hightlitedImage;
    NSString *leftIcon;
}

@property (nonatomic, strong) NSString *title;

- (id)initWithFrame:(CGRect)frame defaultImage:(NSString *)image hightlightedImage:(NSString *)himage title:(NSString *)title leftIcon:(NSString *)icon;
- (id)initWithFrame:(CGRect)frame defaultImage:(NSString *)image hightlightedImage:(NSString *)himage title:(NSString *)title;

- (void)addTarget:(id)target sel:(SEL)sel forControlEvents:(UIControlEvents)event;

@end
