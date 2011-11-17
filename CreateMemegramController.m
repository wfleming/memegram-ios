//
//  CreateMemegramController.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "CreateMemegramController.h"

#import "IGInstagramMedia.h"
#import "CreateMemegramView.h"


#pragma mark -
@interface CreateMemegramController (Actions)
- (void) cancel;
- (void) done;
@end


#pragma mark -
@implementation CreateMemegramController

@synthesize sourceMedia;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Create", @"Create");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  }
  return self;
}

- (void) loadView {
  self.view = [[CreateMemegramView alloc] initWithInstagramMedia:self.sourceMedia];
  ((CreateMemegramView*)self.view).controller = self;
}

@end


#pragma mark -
@implementation CreateMemegramController (Actions)
- (void) cancel {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) done {
  //TODO - get the composite image, construct a Memegram instance, move on to upload/sharing
}
@end
