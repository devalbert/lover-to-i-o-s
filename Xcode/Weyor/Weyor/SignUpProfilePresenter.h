//
//  SignUpProfilePresenter.h
//  Weyor
//
//  Created by Albert Zhao on 3/8/13.
//  Copyright (c) 2013 Albert Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ISignUpProfileView;

@interface SignUpProfilePresenter : NSObject {
  @private
    id<ISignUpProfileView> _view;
}

- (id)initWithView:(id<ISignUpProfileView>)view;

- (void)backAction;

@end
