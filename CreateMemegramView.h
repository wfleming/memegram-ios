//
//  CreateMemegramView.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGInstagramMedia, MemegramTextView;

@interface CreateMemegramView : UIView {
  IGInstagramMedia *_originalMedia;
  
  MemegramTextView *_activeTextView;
  UIImageView *_imageView;
  UIView *_container; // contain all text views & the image view
  UIActivityIndicatorView *_activityIndicator; // for loading the image
  UIToolbar *_toolbar, *_fontSizeToolbar;
  UISlider *_fontSizeSlider;
  UIBarButtonItem *_fontSizeButtonItem, *_boldButtomItem;
}

@property (strong, nonatomic) MemegramTextView *activeTextView;
@property (weak, nonatomic) UIViewController *controller;

// designated initializer
- (id) initWithInstagramMedia:(IGInstagramMedia*)media;

- (void) removeTextView:(MemegramTextView*)textView;

- (UIImage*) compositeMemegramImage;

@end
