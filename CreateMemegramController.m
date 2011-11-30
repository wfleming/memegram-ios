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
#import "Memegram.h"
#import "FinishMemegramController.h"
#import "MGConstants.h"


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
  UIImage *compositeImage = [(CreateMemegramView*)self.view compositeMemegramImage];
  Memegram *memegram = [[Memegram alloc] init];
  memegram.image = compositeImage;
  memegram.instagramSourceId = self.sourceMedia.instagramId;
  memegram.instagramSourceLink = self.sourceMedia.instagramURL;
  memegram.createdAt = [NSDate date];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  memegram.shareToTwitter = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnTwitter]];
  memegram.shareToTumblr = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnTumblr]];
  memegram.shareToFacebook = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnFacebook]];
  
  FinishMemegramController *next = [[FinishMemegramController alloc] init];
  next.memegram = memegram;
  
  [self.navigationController pushViewController:next animated:YES];
}
@end
