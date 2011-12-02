//
//  MemegramDetailController.m
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramDetailController.h"

#import "Meme.h"
#import "ImageCell.h"

@implementation MemegramDetailController {
  BOOL _savedToPhotoAlbum;
}

@synthesize memegram;

- (id) init {
  return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    self.title = NSLocalizedString(@"Memegram", @"Memegram");
    _savedToPhotoAlbum = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
  }
  return self;
}

- (void) _managedObjectContextDidSave:(NSNotification*)notification {
  [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // image, (web | state if not uploaded), save
  NSInteger sections = 3;
  
  return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // eventually a sharing option will show more
  return 1;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (0 == indexPath.section) {
    // this is a crappy separation of concerns as well
    return 300.0; // this should make it square...
  }
  return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"Cell";
    
  if (0 == indexPath.section) {
    cellIdentifier = NSStringFromClass([ImageCell class]);
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    if (0 == indexPath.section) {
      cell = [[ImageCell alloc] init];
    } else {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
  }
  
  // Configure the cell...
  if (0 == indexPath.section) {
    ((ImageCell*)cell).image = self.memegram.image;
  } else if (![self.memegram isUploaded] && 1 == indexPath.section) {
    if ([self.memegram isUploading]) {
      cell.textLabel.text = @"Currently Uploading";
    } else if ([self.memegram isWaitingForUpload]) {
      cell.textLabel.text = @"Queued for Upload";
    }
  } else if ([self.memegram isUploaded] && 1 == indexPath.section) {
    cell.textLabel.text = @"See it on the web";
  } else if (2 == indexPath.section) {
    if (_savedToPhotoAlbum) {
      cell.textLabel.text = @"Saved in your Photo Album";
    } else {
      cell.textLabel.text = @"Save to your Photo Album";
    }
  }
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([self.memegram isUploaded] && 1 == indexPath.section) { // web
    NSString *url = self.memegram.link;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
  } else if (2 == indexPath.section) { // save
    UIImageWriteToSavedPhotosAlbum(self.memegram.image, nil, nil, NULL);
    _savedToPhotoAlbum = YES;
    [self.tableView reloadData];
  }
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
