//
//  MemegramTextViewInputAccessory.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewInputAccessory : UIView

@property (weak, nonatomic) UITextView *textView;

+ (id) accessoryForTextView:(UITextView*)textView;

@end
