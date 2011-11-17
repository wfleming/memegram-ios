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


#pragma mark -
@interface CreateMemegramView (KeybardNotifications)
- (void) keyboardWillShow:(id)sender;
- (void) keyboardDidShow:(id)sender;
- (void) keyboardWillHide:(id)sender;
- (void) keyboardDidHide:(id)sender;
@end

@interface CreateMemegramView (Actions)
- (void) addTextView;
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
    _toolbar.items = [NSArray arrayWithObjects:
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTextView)],
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
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = _imageView.center;
    _activityIndicator.hidesWhenStopped = YES;
    
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
    [_activityIndicator startAnimating];
    [self addSubview:_activityIndicator];
    
    __block typeof(self) blockSelf = self;
    [_originalMedia imageCompletionBlock:^(IGInstagramMedia *media, UIImage *image) {
      __block UIImage *blockImage = image;
      dispatch_async(dispatch_get_main_queue(), ^{
        blockSelf->_toolbar.enabled = YES;
        [blockSelf->_activityIndicator stopAnimating];
        [blockSelf->_activityIndicator removeFromSuperview];
        blockSelf->_imageView.image = blockImage;
      });
    }];
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
  //TODO
  return nil;
}


#pragma mark - property implementations
- (void) setActiveTextView:(MemegramTextView*)textView {
  if (self.activeTextView) {
    self.activeTextView.selected = NO;
  }
  _activeTextView = textView;
  self.activeTextView.selected = YES;
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

- (void) handleImageTap:(id)sender {
  self.activeTextView = nil;
}

@end
