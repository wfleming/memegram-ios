//
//  MemegramTextField.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

extern NSString * const kMemeTextViewWillChangeKeyboardTypeNotification;
extern NSString * const kMemeTextViewDidChangeKeyboardTypeNotification;

@class CreateMemeView, MemeTextViewDelegate;

@interface MemeTextView : UIView<UITextViewDelegate, UIGestureRecognizerDelegate> {
  UIView *_strokeView;
  UIGestureRecognizer *_tapGesture;
  
  MemeTextViewDelegate *_delegateReference;
  BOOL _selected;
  CGRect _originalFrame;
}

@property (weak, nonatomic) CreateMemeView *parentView;
@property (strong, nonatomic) UITextView *textView;
@property (assign, nonatomic) BOOL selected; // determine if gets 'selected' drawing style

+ (CGFloat) minimumFontSize;
+ (CGFloat) maximumFontSize;

- (CATextLayer*) caTextLayer;

@end
