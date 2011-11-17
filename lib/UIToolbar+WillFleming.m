//
//  UIToolbar+WillFleming.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "UIToolbar+WillFleming.h"

@implementation UIToolbar (WillFleming)

@dynamic enabled;

- (BOOL) enabled {
  for(UIBarButtonItem *item in self.items) {
    if (item.enabled) {
      return YES;
    }
  }
  return NO;
}

- (void) setEnabled:(BOOL)enabled {
  for(UIBarButtonItem *item in self.items) {
    item.enabled = enabled;
  }
}

@end
