//
//  WYButton.m
//  Weyor
//
//  Created by Albert Zhao on 3/7/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import "WYButton.h"

@implementation WYButton

- (void)dealloc {
    NSLog(@"DEALLOC FOR %@", self);
}

- (id)initWithFrame:(CGRect)frame {
    return nil;
}

- (id)initWithFrame:(CGRect)frame defaultImage:(NSString *)image hightlightedImage:(NSString *)himage title:(NSString *)title leftIcon:(NSString *)icon {
    self = [super initWithFrame:frame];
    if (self) {
        overlapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlapButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [overlapButton setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        if (himage) {
            [overlapButton setBackgroundImage:[UIImage imageNamed:himage] forState:UIControlStateHighlighted];
        }
        [overlapButton setTitle:title forState:UIControlStateNormal];
        [self addSubview:overlapButton];
        
        if (icon) {
            UIImage *leftIconImage = [UIImage imageNamed:icon];
            leftIconView = [[UIImageView alloc] initWithImage:leftIconImage];
            
            CGFloat iconWidth = frame.size.height - 4;
            iconWidth = (iconWidth > leftIconImage.size.width / 2.0) ? leftIconImage.size.width / 2.0 : iconWidth;
            CGFloat margin = (frame.size.height - iconWidth) / 2.0;
            leftIconView.frame = CGRectMake(margin, margin, iconWidth, iconWidth);
            [self addSubview:leftIconView];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame defaultImage:(NSString *)image hightlightedImage:(NSString *)himage title:(NSString *)title {
    self = [self initWithFrame:frame defaultImage:image hightlightedImage:himage title:title leftIcon:nil];
    if (self) {
    }
    return self;
}

- (void)addTarget:(id)target sel:(SEL)sel forControlEvents:(UIControlEvents)event {
    [overlapButton addTarget:target action:sel forControlEvents:event];
}

@end
