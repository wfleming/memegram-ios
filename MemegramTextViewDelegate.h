//
//  MemegramTextViewDelegate.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MemegramTextView;

@interface MemegramTextViewDelegate : NSObject<UITextViewDelegate>

@property (weak, nonatomic) MemegramTextView *textView;

+ (id) delegateForTextView:(MemegramTextView*)textView;

@end
