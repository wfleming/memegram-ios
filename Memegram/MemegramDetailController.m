//
//  MemegramDetailController.m
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramDetailController.h"

#import "Memegram.h"
#import "ImageCell.h"

@implementation MemegramDetailController

@synthesize memegram;

- (id) init {
  return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    self.title = NSLocalizedString(@"Memegram", @"Memegram");
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // image, web, save
  NSInteger sections = 3;
  
  if (![self.memegram isUploaded]) { // add a section to show status
    sections++;
  }
  
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
  
  NSUInteger offset = ([self.memegram isUploaded] ? 0 : 1);
  
  // Configure the cell...
  if (0 == indexPath.section) {
    ((ImageCell*)cell).image = self.memegram.image;
  } else if (![self.memegram isUploaded] && 1 == indexPath.section) {
    if ([self.memegram isUploading]) {
      cell.textLabel.text = @"Currently Uploading";
    } else if ([self.memegram isWaitingForUpload]) {
      cell.textLabel.text = @"Queued for Upload";
    }
  } else if ((offset + 1) == indexPath.section) {
    cell.textLabel.text = @"See it on the web";
  } else if ((offset + 2) == indexPath.section) {
    cell.textLabel.text = @"Save to your Photo Album";
  }
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSUInteger offset = ([self.memegram isUploaded] ? 0 : 1);
  
  if ((1 + offset) == indexPath.section) { // web
    NSString *url = self.memegram.link;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
  } else if ((2 + offset) == indexPath.section) { // save
    //TODO - FEEDBACK!
    UIImageWriteToSavedPhotosAlbum(self.memegram.image, nil, nil, NULL);
  }
  
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
