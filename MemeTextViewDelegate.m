//
//  MemegramTextViewDelegate.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemeTextViewDelegate.h"

#import "MemeTextView.h"
#import "CreateMemeView.h"
#import "UIView+WillFleming.h"

@interface MemeTextViewDelegate (Private)
- (NSUInteger) _trailingEmptyLines:(NSString*)text;
@end


#pragma mark -
@implementation MemeTextViewDelegate

@synthesize textView;

+ (id) delegateForTextView:(MemeTextView*)textView {
  MemeTextViewDelegate *delegate = [[self alloc] init];
  delegate.textView = textView;
  return delegate;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)theTextView {
  // begin editing if no text even if not selecetd - means it's a brand new text view
  BOOL readyToEdit = self.textView.selected || ![self.textView hasText];
  self.textView.parentView.activeTextView = self.textView;
  return readyToEdit;
}

- (void)textViewDidBeginEditing:(UITextView *)theTextView {
  // anything to do here?
}

- (BOOL)textViewShouldEndEditing:(UITextView *)theTextView {
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
  if (![self.textView hasText]) {
    [self.textView.parentView removeTextView:self.textView];
  }
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  // do not allow empty lines at the beginning of the text
  if (0 == range.location && [@"\n" isEqual:text]) {
    //TODO - this won't handle copy/paste well
    return NO;
  }
  
  /**
   * change auto-cap if we ever notice you go to lower case:
   * we start in all-caps. But if you do this, shift can no longer be used normally
   * (either caps-lock or lowercase). So if we see any lowercase, then we change the
   * auto-cap style to make shift act normally again.
   * the resign/becomeFirstResponder dance is needed, otherwise the keyboard
   * doesn't actually change.
   *
   * TODO: currently, if you switch to lowercase, there's a bit of visible
   * jog from the responder dance. Should fix if possible.
   */
  if (NSNotFound != [text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location) {
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [self.textView resignFirstResponder];
    [self.textView becomeFirstResponder];
  }
  
  
  return YES;
}

- (void)textViewDidChange:(UITextView *)theTextView {
  NSString *text = self.textView.text;
  
  // resize our frame to match our content
  CGSize maxSize = CGSizeMake(self.textView.parentView.width, self.textView.parentView.height);
  CGSize textSize = [text sizeWithFont:self.textView.font constrainedToSize:maxSize lineBreakMode:UILineBreakModeClip];
  self.textView.width = textSize.width + 40.0;
  self.textView.height = textSize.height + 10.0;
  
  /* -sizeWithFont: doesn't include the height of trailing 'empty' lines.
   * so we scan for empty lines at the end and add height for them */
  NSUInteger numEmptyLines = [self _trailingEmptyLines:text];
  if (numEmptyLines > 0) {
    self.textView.height = self.textView.height + (numEmptyLines * self.textView.font.lineHeight);
  }
}

@end


#pragma mark -
@implementation MemeTextViewDelegate (Private)

- (NSUInteger) _trailingEmptyLines:(NSString*)text {
  if (0 == [text length]) {
    return 0;
  }
  
  BOOL foundContent = NO;
  NSUInteger index = [text length] - 1;
  NSUInteger lines = 0;
  while (!foundContent && index > 0) {
    NSString *ch = [text substringWithRange:NSMakeRange(index, 1)];
    if ([@"\n" isEqual:ch]) {
      lines++;
    }
    if ([ch stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
      foundContent = YES;
    }
    index--;
  }
  return lines;
}

@end
