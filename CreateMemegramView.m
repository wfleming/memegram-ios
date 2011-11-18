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
#import <CoreText/CoreText.h>


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
    
    _fontSizeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"font size" style:UIBarButtonItemStylePlain target:self action:@selector(toggleFontSize)];
    
    _boldButtomItem = [[UIBarButtonItem alloc] initWithTitle:@"Bold Is On" style:UIBarButtonItemStylePlain target:self action:@selector(toggleBold)];
    
    _toolbar.items = [NSArray arrayWithObjects:
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTextView)],
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
  // hide things that shouldn't be visible
  [_fontSizeToolbar removeFromSuperview];
  
  // begin the real work
  UIGraphicsBeginImageContext(_imageView.image.size);
  CGContextRef g = UIGraphicsGetCurrentContext();
  [_imageView.image drawAtPoint:CGPointZero];
  
  // translate the context, or all text will be Y inverted.
  CGContextTranslateCTM(g, 0.0, _imageView.image.size.height);
  CGContextScaleCTM(g, 1.0, -1.0);
  
  for(UIView *v in _container.subviews) {
    if ([v isKindOfClass:[MemegramTextView class]]) {
      // TODO - multiline text gets shifted to one line here. FIXME.
      MemegramTextView *tv = (MemegramTextView*)v;
      CGFontRef cgFont = CGFontCreateWithFontName((__bridge CFStringRef)tv.font.fontName);
      CGContextSetFont(g, cgFont);
      
      // translate coordinates and font size
      CGFloat scale = (_imageView.image.size.width / _imageView.width);
      // TODO these values are still sliggggghtly off, and need testing with other font sizes
      // You might ask, "Why 8?". Go fuck yourself, that's why 8.
      CGFloat x = (tv.left * scale) + (8.0 * scale),
              y = _imageView.image.size.height - (tv.top * scale) - (tv.font.lineHeight * scale);  // because we inverted the y scale
      CGFloat fontSize = (tv.font.pointSize * scale);
      
      CGContextSetFontSize(g, fontSize);
      CGContextSetFillColorWithColor(g, tv.textColor.CGColor);
      
      // alternative to glyph capturing...it seems to be worse with characters
      //CGContextSelectFont(g, [tv.font.fontName UTF8String], fontSize, kCGEncodingFontSpecific);
      //CGContextShowTextAtPoint(g, x, y, [tv.text UTF8String], [tv.text length]);

      
      // we need a CTFont to get glyphs
      CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)tv.font.fontName, fontSize, NULL);
      unichar *utf8str = malloc(sizeof(unichar) * [tv.text length]);
      [tv.text getCharacters:utf8str range:NSMakeRange(0, [tv.text length])];
      CGGlyph *glyphs = malloc(sizeof(CGGlyph) * [tv.text length]);
      BOOL result = CTFontGetGlyphsForCharacters(ctFont, utf8str, glyphs, [tv.text length]);
      if (!result) {
        DLOG(@"OH GOD OH GOD OH GOD");
      }
      
      // lets see if we can for reals write this to the image context...
      CGContextShowGlyphsAtPoint(g, x, y, glyphs, [tv.text length]);
      
      // malloc & free in ARC code... FUN!
      free(utf8str);
      free(glyphs);
    }
  }
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  
  //DEBUGGING - set image on the imageView & delete all textviews
  _imageView.image = result;
  for(UIView *v in _container.subviews) {
    if ([v isKindOfClass:[MemegramTextView class]]) {
      [v removeFromSuperview];
    }
  }
  //END DEBUGGING
  
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
