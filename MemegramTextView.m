//
//  MemegramTextField.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramTextView.h"

#import "MemegramTextViewInputAccessory.h"
#import "MemegramTextViewDelegate.h"
#import "UIView+WillFleming.h"

#define DEFAULT_FONT_SIZE 20.0

@implementation MemegramTextView

@synthesize parentView, selected = _selected;

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _delegateReference = [MemegramTextViewDelegate delegateForTextView:self];
    self.delegate = _delegateReference;
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.inputAccessoryView = [MemegramTextViewInputAccessory accessoryForTextView:self];
    
    // this will be helvetica by default - but maybe we should be explicit?
    self.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    
    // gesture recognizer for dragging
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    dragGesture.delegate = self;
    [self addGestureRecognizer:dragGesture];
  }
  return self;
}

- (void) layoutSubviews {
  if (self.selected && ![self isFirstResponder]) {
    self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
  } else {
    self.backgroundColor = [UIColor clearColor];
  }
}

// callback for gesture recognizer
- (void) pan:(UIPanGestureRecognizer*)sender {
  DLOG(@"pan size: %@", NSStringFromCGPoint([sender translationInView:self.superview]));
  CGPoint transform = [sender translationInView:self.superview];
  CGRect oldFrame = self.frame;
  self.left = _originalFrame.origin.x + transform.x;
  self.top = _originalFrame.origin.y + transform.y;
  DLOG(@"self frame %@ -> %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(self.frame));
  return;
}


#pragma mark - properties

- (void) setSelected:(BOOL)selected {
  _selected = selected;
  [self.superview bringSubviewToFront:self];
  [self setNeedsLayout];
}


#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    _originalFrame = self.frame;
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return NO;
}
@end
