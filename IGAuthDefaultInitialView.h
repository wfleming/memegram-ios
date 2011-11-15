//
//  IGAuthInitialView.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGInstagramAuthController;

@protocol IGAuthInitialView
- (id) initWithController:(IGInstagramAuthController*)controller;
@end


#pragma mark -
@interface IGAuthDefaultInitialView : UIView <IGAuthInitialView> {
  IGInstagramAuthController *_controller;
}

@end
