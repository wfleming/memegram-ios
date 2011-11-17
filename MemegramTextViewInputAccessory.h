//
//  MemegramTextViewInputAccessory.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemegramTextView;

@interface MemegramTextViewInputAccessory : UIView

@property (weak, nonatomic) MemegramTextView *textView;

+ (id) accessoryForTextView:(MemegramTextView*)textView;

@end
