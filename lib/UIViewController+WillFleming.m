//
//  UIViewController+WillFleming.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "UIViewController+WillFleming.h"

@implementation UIViewController (WillFleming)

- (CGRect) availableViewFrame {
  UIViewController *parent = self.parentViewController;
  if (parent && parent.view) {
    return [parent.view bounds];
  } else {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return window.bounds;
  }
}

@end
