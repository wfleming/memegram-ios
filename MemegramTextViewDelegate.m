//
//  MemegramTextViewDelegate.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramTextViewDelegate.h"

#import "MemegramTextView.h"
#import "CreateMemegramView.h"
#import "UIView+WillFleming.h"

@interface MemegramTextViewDelegate (Private)
- (NSUInteger) _trailingEmptyLines:(NSString*)text;
@end


#pragma mark -
@implementation MemegramTextViewDelegate

@synthesize textView;

+ (id) delegateForTextView:(MemegramTextView*)textView {
  MemegramTextViewDelegate *delegate = [[self alloc] init];
  delegate.textView = textView;
  return delegate;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  // begin editing if no text even if not selecetd - means it's a brand new text view
  BOOL readyToEdit = self.textView.selected || ![self.textView hasText];
  self.textView.parentView.activeTextView = self.textView;
  return readyToEdit;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  // anything to do here?
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if (![self.textView hasText]) {
    [self.textView.parentView removeTextView:self.textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  // do not allow empty lines at the beginning of the text
  if (0 == range.location && [@"\n" isEqual:text]) {
    //TODO - this won't handle copy/paste well
    return NO;
  }
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
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
@implementation MemegramTextViewDelegate (Private)

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
