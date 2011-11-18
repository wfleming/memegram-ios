//
//  CreateMemegramView.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "CreateMemegramView.h"

#import "IGInstagramMedia.h"
#import "MemegramTextView.h"
#import "UIView+WillFleming.h"
#import "UIToolbar+WillFleming.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
@interface CreateMemegramView (KeybardNotifications)
- (void) keyboardWillShow:(id)sender;
- (void) keyboardDidShow:(id)sender;
- (void) keyboardWillHide:(id)sender;
- (void) keyboardDidHide:(id)sender;
@end

@interface CreateMemegramView (Actions)
- (void) addTextView;
- (void) toggleFontSize;
- (void) toggleBold;
- (void) fontSizeSliderValueChanged:(UISlider*)slider;
- (void) handleImageTap:(id)sender;
@end


#pragma mark -
@implementation CreateMemegramView

@synthesize activeTextView=_activeTextView, controller;

#pragma mark - overrides
- (id) initWithInstagramMedia:(IGInstagramMedia*)media {
  //TODO - handle figuring out our frame size on iPad
  // this is the size we have to work with with a nav bar, status bar, tab bar on iPhone
  CGRect frame = CGRectMake(0.0, 0.0, 320.0, 367.0);
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor blackColor];
    
    _originalMedia = media;
    
    // set up subviews
    
    //TODO: on first launch, do a quick popup to demonstrate button use
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, 47.0)];
    _toolbar.barStyle = UIBarStyleBlack;
    
    _addTextViewButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTextView)];
    _addTextViewButtonItem.enabled = NO;
    
    _fontSizeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"font size" style:UIBarButtonItemStylePlain target:self action:@selector(toggleFontSize)];
    _fontSizeButtonItem.enabled = NO;
    
    _boldButtomItem = [[UIBarButtonItem alloc] initWithTitle:@"Bold Is On" style:UIBarButtonItemStylePlain target:self action:@selector(toggleBold)];
    _fontSizeButtonItem.enabled = NO;
    
    _toolbar.items = [NSArray arrayWithObjects:
                      _addTextViewButtonItem,
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      _boldButtomItem,
                      _fontSizeButtonItem,
                      nil];
    _toolbar.enabled = NO;
    [self addSubview:_toolbar];
    
    _container = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          _toolbar.height,
                                                          self.width,
                                                          (self.height - _toolbar.height))];
    _container.backgroundColor = [UIColor clearColor];
    [self addSubview:_container];
    
    _imageView = [[UIImageView alloc] initWithFrame:_container.bounds];
    _imageView.image = nil; //to make sure.
    _imageView.backgroundColor = [UIColor clearColor];
    [_container addSubview:_imageView];
    
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    [_imageView addGestureRecognizer:imageTapRecognizer];
    _imageView.userInteractionEnabled = YES;
    
    // views that aren't immediately shown
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = _imageView.center;
    _activityIndicator.hidesWhenStopped = YES;
    
    _fontSizeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _toolbar.height, _toolbar.width, 44.0)];
    _fontSizeToolbar.barStyle = UIBarStyleBlackTranslucent;
    _fontSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 0, _fontSizeToolbar.width - 20.0, 20.0)];
    _fontSizeSlider.minimumValue = [MemegramTextView minimumFontSize];
    _fontSizeSlider.maximumValue = [MemegramTextView maximumFontSize];
    [_fontSizeSlider addTarget:self action:@selector(fontSizeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    _fontSizeToolbar.items = [NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithCustomView:_fontSizeSlider]];
    
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
  }
  return self;
}

- (void) dealloc {
  // unregister keyboard callbacks
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// not allowed on this class
- (id)initWithFrame:(CGRect)frame
{
  DASSERT(NO);
  return nil;
}

- (void) layoutSubviews {
  // first, start loading the image in if it's not already loaded
  if (!_imageView.image) {
    _addTextViewButtonItem.enabled = NO;
    [_activityIndicator startAnimating];
    [self addSubview:_activityIndicator];
    
    __block typeof(self) blockSelf = self;
    [_originalMedia imageCompletionBlock:^(IGInstagramMedia *media, UIImage *image) {
      __block UIImage *blockImage = image;
      dispatch_async(dispatch_get_main_queue(), ^{
        blockSelf->_addTextViewButtonItem.enabled = YES;
        [blockSelf->_activityIndicator stopAnimating];
        [blockSelf->_activityIndicator removeFromSuperview];
        blockSelf->_imageView.image = blockImage;
      });
    }];
  } else {
    _addTextViewButtonItem.enabled = YES;
  }
  
  //TODO do...other work? if needed?
}


#pragma mark - custom instance methods
- (void) removeTextView:(MemegramTextView*)textView {
  if (textView == self.activeTextView) {
    self.activeTextView = nil;
  }
  [textView removeFromSuperview];
}

- (UIImage*) compositeMemegramImage {
  // hide things that shouldn't be visible
  [_fontSizeToolbar removeFromSuperview];
  self.activeTextView = nil;
  
  // begin the real work
  UIGraphicsBeginImageContext(_imageView.image.size);
  CGContextRef g = UIGraphicsGetCurrentContext();
  [_imageView.image drawAtPoint:CGPointZero];
  
  // scale the coordinate size (image/context is bigger than actual view)
  CGFloat scale = (_imageView.image.size.width / _imageView.width);
  CGContextScaleCTM(g, scale, scale);
  
  for(UIView *v in _container.subviews) {
    if ([v isKindOfClass:[MemegramTextView class]]) {
      MemegramTextView *tv = (MemegramTextView*)v;
      
      /* We translate the origin because CALayer draws at (0,0) all the time otherwise.
       * Then we translate back so the next view gets the right coords.
       * (I'm not sure why Y needs a static offset & X doesn't. Rounding error?) */
      CGFloat dX = tv.left, dY = (tv.top - 2.0);
      CGContextTranslateCTM(g, dX, dY);
      [tv.layer renderInContext:g];
      CGContextTranslateCTM(g, -dX, -dY);
    } // end if for subview class
  } // end loop over subviews
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  /* DEBUGGING - set image on the imageView & delete all textviews *
  _imageView.image = result;
  for(UIView *v in _container.subviews) {
    if ([v isKindOfClass:[MemegramTextView class]]) {
      [v removeFromSuperview];
    }
  }
  // END DEBUGGING */
  
  return result;
}


#pragma mark - property implementations
- (void) setActiveTextView:(MemegramTextView*)textView {
  if (self.activeTextView) {
    self.activeTextView.selected = NO;
  }
  _activeTextView = textView;
  self.activeTextView.selected = YES;
  
  if (nil == textView) {
    _fontSizeButtonItem.enabled = NO;
    _boldButtomItem.enabled = NO;
  } else {
    _fontSizeButtonItem.enabled = YES;
    _boldButtomItem.enabled = YES;
    _fontSizeSlider.value = self.activeTextView.font.pointSize;
  }
}

@end


#pragma mark -
@implementation CreateMemegramView (KeybardNotifications)
- (void) keyboardWillShow:(id)sender {
  // hide toolbar, move image view up
  //TODO - animate, hide nav bar controller as well?
  _toolbar.hidden = YES;
  self.controller.navigationController.navigationBarHidden = YES;
  _container.top = _toolbar.top;
}

- (void) keyboardDidShow:(id)sender {
  // TODO
}

- (void) keyboardWillHide:(id)sender {
  // move image view down, show toolbar
  //TODO - animate, re-show nav bar controller as well?
  _container.top = _toolbar.top + _toolbar.height;
  _toolbar.hidden = NO;
  self.controller.navigationController.navigationBarHidden = NO;
}

- (void) keyboardDidHide:(id)sender {
  //TODO
}
@end


#pragma mark -
@implementation CreateMemegramView (Actions)

- (void) addTextView {
  CGRect defaultFrame = CGRectMake(10.0, 10.0, (self.width / 2.0), 30.0);
  MemegramTextView *newTextView = [[MemegramTextView alloc] initWithFrame:defaultFrame];
  newTextView.parentView = self;
  [_container addSubview:newTextView];
  [newTextView becomeFirstResponder];
}

- (void) toggleFontSize {
  if (self == [_fontSizeToolbar superview]) {
    [_fontSizeToolbar removeFromSuperview];
  } else {
    [self addSubview:_fontSizeToolbar];
  }
}
        
- (void) toggleBold {
  NSString *fontName = [self.activeTextView.font fontName];
  if (NSNotFound == [fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch|NSBackwardsSearch].location) {
    // currently not bold. switch to bold.
    self.activeTextView.font = [UIFont boldSystemFontOfSize:self.activeTextView.font.pointSize];
    _boldButtomItem.title = @"Bold Is On";
  } else {
    // already bold. go not-bold.
    self.activeTextView.font = [UIFont systemFontOfSize:self.activeTextView.font.pointSize];
    _boldButtomItem.title = @"Bold Is Off";
  }
  // this needs to be manually triggered to resize
  [self.activeTextView.delegate textViewDidChange:self.activeTextView];
}

- (void) fontSizeSliderValueChanged:(UISlider*)slider {
  NSString *fontName = [self.activeTextView.font fontName];
  self.activeTextView.font = [UIFont fontWithName:fontName size:slider.value];
  // this needs to be manually triggered to resize
  [self.activeTextView.delegate textViewDidChange:self.activeTextView];
}

- (void) handleImageTap:(id)sender {
  self.activeTextView = nil;
}

@end
