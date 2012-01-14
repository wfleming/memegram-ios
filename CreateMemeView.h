//
//  CreateMemegramView.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFIGMedia, MemeTextView;

@interface CreateMemeView : UIView

@property (strong, nonatomic) MemeTextView *activeTextView;
@property (weak, nonatomic) UIViewController *controller;

// designated initializer
- (id) initWithInstagramMedia:(WFIGMedia*)media;

- (void) removeTextView:(MemeTextView*)textView;

- (UIImage*) compositeMemeImage;

- (void) showHelpBubble;
- (void) hideHelpBubble;

@end
