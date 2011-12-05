//
//  CreateMemegramController.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "CreateMemeController.h"

#import "IGInstagramMedia.h"
#import "CreateMemeView.h"
#import "Meme.h"
#import "FinishMemeController.h"
#import "MGConstants.h"


#pragma mark -
@interface CreateMemeController (Actions)
- (void) cancel;
- (void) done;
@end


#pragma mark -
@implementation CreateMemeController

static NSString * const kDidShowHelpKey = @"didShowHelp";

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
  self.view = [[CreateMemeView alloc] initWithInstagramMedia:self.sourceMedia];
  ((CreateMemeView*)self.view).controller = self;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

//  Turned off because we auto-add text now.
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//  BOOL didShowHelp = [defaults boolForKey:kDidShowHelpKey];
//  if (!didShowHelp) {
//    [defaults setBool:YES forKey:kDidShowHelpKey];
//    [((CreateMemeView*)self.view) showHelpBubble];
//    [self.view performSelector:@selector(hideHelpBubble) withObject:nil afterDelay:2.25];
//  }
}

@end


#pragma mark -
@implementation CreateMemeController (Actions)
- (void) cancel {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) done {
  UIImage *compositeImage = [(CreateMemeView*)self.view compositeMemeImage];
  Meme *memegram = [[Meme alloc] init];
  memegram.image = compositeImage;
  memegram.instagramSourceId = self.sourceMedia.instagramId;
  memegram.instagramSourceLink = self.sourceMedia.instagramURL;
  memegram.createdAt = [NSDate date];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  memegram.shareToTwitter = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnTwitter]];
  memegram.shareToTumblr = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnTumblr]];
  memegram.shareToFacebook = [NSNumber numberWithBool:[defaults boolForKey:kDefaultsShareOnFacebook]];
  
  FinishMemeController *next = [[FinishMemeController alloc] init];
  next.meme = memegram;
  
  [self.navigationController pushViewController:next animated:YES];
}
@end
