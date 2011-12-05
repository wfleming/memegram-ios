//
//  MemegramTextViewDelegate.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MemeTextView;

@interface MemeTextViewDelegate : NSObject<UITextViewDelegate>

@property (weak, nonatomic) MemeTextView *memeTextView;

+ (id) delegateForMemeTextView:(MemeTextView*)memeTextView;

@end
