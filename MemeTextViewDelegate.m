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

@synthesize memeTextView;

+ (id) delegateForMemeTextView:(MemeTextView*)memeTextView {
  MemeTextViewDelegate *delegate = [[self alloc] init];
  delegate.memeTextView = memeTextView;
  return delegate;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  // begin editing if no text even if not selecetd - means it's a brand new text view
  BOOL readyToEdit = self.memeTextView.selected || ![textView hasText];
  self.memeTextView.parentView.activeTextView = self.memeTextView;
  return readyToEdit;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  // anything to do here?
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if (![textView hasText]) {
    [self.memeTextView.parentView removeTextView:self.memeTextView];
  }
  [self.memeTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
   * the notifications are so that we don't see an visible jog because of keyboard changes
   */
  if (NSNotFound != [text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMemeTextViewWillChangeKeyboardTypeNotification object:textView];
    textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [textView resignFirstResponder];
    [textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMemeTextViewDidChangeKeyboardTypeNotification object:textView];
  }
  
  
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
  NSString *text = textView.text;
  
  // resize our frame to match our content
  CGSize maxSize = CGSizeMake(self.memeTextView.parentView.width, self.memeTextView.parentView.height);
  CGSize textSize = [text sizeWithFont:textView.font constrainedToSize:maxSize lineBreakMode:UILineBreakModeClip];
  textView.width = textSize.width + 40.0;
  textView.height = textSize.height + 10.0;
  
  /* -sizeWithFont: doesn't include the height of trailing 'empty' lines.
   * so we scan for empty lines at the end and add height for them */
  NSUInteger numEmptyLines = [self _trailingEmptyLines:text];
  if (numEmptyLines > 0) {
    textView.height = textView.height + (numEmptyLines * textView.font.lineHeight);
  }
  
  // resize parent as well. would like to encapsuate this better
  self.memeTextView.width = textView.width;
  self.memeTextView.height = textView.height;
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
