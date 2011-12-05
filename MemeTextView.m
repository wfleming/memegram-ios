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
#import "CreateMemeView.h"
#import <CoreText/CoreText.h>

#define DEFAULT_FONT_SIZE 50.0

NSString * const kMemeTextViewWillChangeKeyboardTypeNotification = @"MemeTextViewWillChangeKeyboardTypeNotification";
NSString * const kMemeTextViewDidChangeKeyboardTypeNotification = @"MemeTextViewDidChangeKeyboardTypeNotification";

@implementation MemeTextView

@synthesize parentView, textView, selected = _selected;

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
    _delegateReference = [MemeTextViewDelegate delegateForMemeTextView:self];
    self.textView = [[UITextView alloc] initWithFrame:self.bounds];
    self.textView.delegate = _delegateReference;
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.textView.inputAccessoryView = [TextViewInputAccessory accessoryForTextView:self.textView];
    
    // this will be helvetica by default - but maybe we should be explicit?
    self.textView.font = [UIFont boldSystemFontOfSize:DEFAULT_FONT_SIZE];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.textView];
    
    // gesture recognizer for dragging
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    dragGesture.delegate = self;
    [self addGestureRecognizer:dragGesture];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
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


#pragma mark - responder chain methods

- (BOOL)isFirstResponder {
  return [self.textView isFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
  if (self == self.textView.superview) {
    return [self.textView canBecomeFirstResponder];
  } else {
    return YES;
  }
}

- (BOOL)becomeFirstResponder {
  if (nil == self.textView.superview) {
    [_strokeView removeFromSuperview];
    _strokeView = nil;
    [self addSubview:self.textView];
  }
  return [self.textView becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
  return [self.textView canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
  BOOL rv = [self.textView resignFirstResponder];
  if (rv) {
    [self setNeedsLayout];
  }
  return rv;
}


#pragma mark - instance methods
// callback for gesture recognizer
- (void) pan:(UIPanGestureRecognizer*)sender {
  CGPoint transform = [sender translationInView:self.superview];
  self.left = _originalFrame.origin.x + transform.x;
  self.top = _originalFrame.origin.y + transform.y;
  return;
}

- (void) tap:(UIPanGestureRecognizer*)sender {
  self.parentView.activeTextView = self;
}

- (CATextLayer*) caTextLayer {
  // set up the attributed string with stroke attributes
  CFMutableAttributedStringRef str = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
  if (nil != str) {
    CFAttributedStringReplaceString(str, CFRangeMake(0, 0), (__bridge CFStringRef)self.textView.text);
  }
  CFRange strRange = CFRangeMake(0, [self.textView.text length]);
  CFAttributedStringSetAttribute(str, strRange, kCTForegroundColorAttributeName, self.textView.textColor.CGColor);
  CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)self.textView.font.fontName, self.textView.font.pointSize, NULL);
  CFAttributedStringSetAttribute(str, strRange, kCTFontAttributeName, ctFont);
  CFAttributedStringSetAttribute(str, strRange, kCTStrokeColorAttributeName, [UIColor blackColor].CGColor);
  CFAttributedStringSetAttribute(str, strRange, kCTStrokeWidthAttributeName, (__bridge CFTypeRef)[NSNumber numberWithFloat:-4.0]); //TODO - set as percentage?
  
  CATextLayer *strokeLayer = [[CATextLayer alloc] init];
  strokeLayer.wrapped = YES;
  strokeLayer.string = (__bridge NSMutableAttributedString*)str;
  CFRelease(str);
  
  /** NB this is a bit rendundant with code in CreateMemeView right now. */
  CGFloat dX = 8.0, dY = (self.textView.font.pointSize / 5.0) + 1;
  strokeLayer.frame = CGRectMake(dX, dY, self.width, self.height);
  
  return strokeLayer;
}


#pragma mark - properties
- (void) setSelected:(BOOL)selected {
  _selected = selected;
  if (selected) {
    [self.superview bringSubviewToFront:self];
    
    [_strokeView removeFromSuperview];
    _strokeView = nil;
    if (nil == self.textView.superview) {
      [self addSubview:self.textView];
      [self removeGestureRecognizer:_tapGesture];
    }
  } else {
    [self.textView removeFromSuperview];
    [self addGestureRecognizer:_tapGesture];
    
    _strokeView = [[UIView alloc] initWithFrame:self.bounds];
    [_strokeView.layer addSublayer:[self caTextLayer]];
    [self addSubview:_strokeView];
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
