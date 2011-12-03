//
//  MemegramTextField.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kMemeTextViewWillChangeKeyboardTypeNotification;
extern NSString * const kMemeTextViewDidChangeKeyboardTypeNotification;

@class CreateMemeView, MemeTextViewDelegate;

@interface MemeTextView : UITextView<UITextViewDelegate, UIGestureRecognizerDelegate> {
  MemeTextViewDelegate *_delegateReference;
  BOOL _selected;
  CGRect _originalFrame;
}

@property (weak, nonatomic) CreateMemeView *parentView;
@property (assign, nonatomic) BOOL selected; // determine if gets 'selected' drawing style

+ (CGFloat) minimumFontSize;
+ (CGFloat) maximumFontSize;

@end
