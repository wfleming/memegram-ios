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

- (void)textViewDidChange:(UITextView *)textView {
  //TODO - resize ourself to fit content
}

@end
