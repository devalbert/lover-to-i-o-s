//
//  SplashPresenter.h
//  Weyor
//
//  Created by Albert Zhao on 3/7/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ISplashView;

@interface SplashPresenter : NSObject {
  @private
    id<ISplashView> _view;
}

@property (nonatomic, assign) BOOL isRememberPassword;

- (id)initWithView:(id<ISplashView>)view;
- (void)signInProcess;
- (void)loadRememberPasswordStatus;

@end

