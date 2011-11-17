//
//  MemegramTextField.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateMemegramView, MemegramTextViewDelegate;

@interface MemegramTextView : UITextView<UITextViewDelegate, UIGestureRecognizerDelegate> {
  MemegramTextViewDelegate *_delegateReference;
  BOOL _selected;
  CGRect _originalFrame;
}

@property (weak, nonatomic) CreateMemegramView *parentView;
@property (assign, nonatomic) BOOL selected; // determine if gets 'selected' drawing style

@end
