//
//  MemegramTextViewInputAccessory.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramTextViewInputAccessory.h"

#import "MemegramTextView.h"
#import "UIView+WillFleming.h"

@implementation MemegramTextViewInputAccessory

@synthesize textView;

+ (id) accessoryForTextView:(MemegramTextView*)textView {
  MemegramTextViewInputAccessory *accessory = [[self alloc] initWithFrame:CGRectMake(0, 0, 0, 40.0)];
  accessory.textView = textView;
  return accessory;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.frame];
      toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
      toolbar.barStyle = UIBarStyleBlackTranslucent;
      toolbar.items = [NSArray arrayWithObjects:
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)],
                       nil];
      [self addSubview:toolbar];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
  if (newSuperview) {
    self.frame = CGRectMake(self.left, self.top, newSuperview.width, self.height);
  }
}

- (void) done {
  [self.textView resignFirstResponder];
}
@end
