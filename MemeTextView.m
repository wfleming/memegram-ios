//
//  MemegramTextField.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemeTextView.h"

#import "TextViewInputAccessory.h"
#import "MemeTextViewDelegate.h"
#import "UIView+WillFleming.h"
#import <CoreText/CoreText.h>

#define DEFAULT_FONT_SIZE 50.0

NSString * const kMemeTextViewWillChangeKeyboardTypeNotification = @"MemeTextViewWillChangeKeyboardTypeNotification";
NSString * const kMemeTextViewDidChangeKeyboardTypeNotification = @"MemeTextViewDidChangeKeyboardTypeNotification";

@implementation MemeTextView

@synthesize parentView, selected = _selected;

#pragma mark - class methods
+ (CGFloat) minimumFontSize {
  return 8.0;
}

+ (CGFloat) maximumFontSize {
  return 125.0;
}


#pragma mark - instance overrides
- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _delegateReference = [MemeTextViewDelegate delegateForTextView:self];
    self.delegate = _delegateReference;
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.inputAccessoryView = [TextViewInputAccessory accessoryForTextView:self];
    
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


#pragma mark - instance methods
// callback for gesture recognizer
- (void) pan:(UIPanGestureRecognizer*)sender {
  CGPoint transform = [sender translationInView:self.superview];
  self.left = _originalFrame.origin.x + transform.x;
  self.top = _originalFrame.origin.y + transform.y;
  return;
}

- (CATextLayer*) caTextLayer {
  // set up the attributed string with stroke attributes
  CFMutableAttributedStringRef str = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
  if (nil != str) {
    CFAttributedStringReplaceString(str, CFRangeMake(0, 0), (__bridge CFStringRef)self.text);
  }
  CFRange strRange = CFRangeMake(0, [self.text length]);
  CFAttributedStringSetAttribute(str, strRange, kCTForegroundColorAttributeName, self.textColor.CGColor);
  CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
  CFAttributedStringSetAttribute(str, strRange, kCTFontAttributeName, ctFont);
  CFAttributedStringSetAttribute(str, strRange, kCTStrokeColorAttributeName, [UIColor blackColor].CGColor);
  CFAttributedStringSetAttribute(str, strRange, kCTStrokeWidthAttributeName, (__bridge CFTypeRef)[NSNumber numberWithFloat:-4.0]); //TODO - set as percentage?
  
  CATextLayer *strokeLayer = [[CATextLayer alloc] init];
  strokeLayer.string = (__bridge NSMutableAttributedString*)str;
  CFRelease(str);
  
  return strokeLayer;
}


#pragma mark - properties
- (void) setSelected:(BOOL)selected {
  _selected = selected;
  if (selected) {
    [self.superview bringSubviewToFront:self];
  }
  
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
