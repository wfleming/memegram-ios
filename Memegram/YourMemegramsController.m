//
//  YourMemegramsController.m
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "YourMemegramsController.h"

#import "MemegramCell.h"
#import "MGAppDelegate.h"
#import "Memegram.h"
#import "MemegramDetailController.h"

@interface YourMemegramsController (Private)
- (void) _reloadDataForce:(BOOL)force;
@end

@implementation YourMemegramsController {
  KKGridView *_gridView;
  NSArray *_memegrams;
}


#pragma mark - overrides
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Your Lolgramz", @"Your Lolgramz");
    self.tabBarItem.image = [UIImage imageNamed:@"your-lolgramz-tab-icon"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadView {
  _gridView = [[KKGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
  self.view = _gridView;
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view.autoresizesSubviews = YES;
  
  // grid attributes
  _gridView.allowsMultipleSelection = NO;
  _gridView.scrollsToTop = YES;
  _gridView.backgroundColor = [UIColor whiteColor];
  _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _gridView.cellSize = CGSizeMake(74.0, 74.0);
  _gridView.cellPadding = CGSizeMake(5.0, 5.0);
  
  // grid callbacks
  __block typeof(self) blockSelf = self;
  [_gridView setNumberOfItemsInSectionBlock:^(KKGridView *gridView, NSUInteger section) {
    if (blockSelf->_memegrams) {
      return [blockSelf->_memegrams count];
    }
    return 0;
  }];
  
  [_gridView setNumberOfSectionsBlock: ^(KKGridView *gridView) {
    return (NSUInteger)1;
  }];
  
  [_gridView setCellBlock:^(KKGridView *gridView, KKIndexPath *indexPath) {
    MemegramCell *cell = [MemegramCell cellForGridView:gridView];
    cell.memegram = [blockSelf->_memegrams objectAtIndex:indexPath.index];
    
    return cell;
  }];
  
  [_gridView setDidSelectIndexPathBlock:^(KKGridView *gridView, KKIndexPath *indexPath) {
    Memegram *memegram = [blockSelf->_memegrams objectAtIndex:indexPath.index];
    MemegramDetailController *next = [[MemegramDetailController alloc] init];
    next.memegram = memegram;
    [blockSelf.navigationController pushViewController:next animated:YES];
    
    KKGridViewCell *cell = gridView.cellBlock(gridView, indexPath);
    cell.selected = NO;
  }];

}

- (void) viewDidUnload {
  _gridView = nil;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self _reloadDataForce:NO];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [_gridView reloadData];
  // KKGridView is a little odd with how it implements reloadData...
  [_gridView setNeedsLayout];
}


#pragma mark - notification listeners
- (void) _managedObjectContextDidSave:(NSNotification*)notification {
  [self _reloadDataForce:YES];
}

@end


#pragma mark -
@implementation YourMemegramsController (Private)
- (void) _reloadDataForce:(BOOL)force {
  if (force) {
    _memegrams = nil;
  }
  
  // reload data if we just forced or there wasn't any
  if (nil == _memegrams || 0 == [_memegrams count]) {
    MGAppDelegate *appDelegate = (MGAppDelegate*)[UIApplication sharedApplication].delegate;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[Memegram entityDescription]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *err;
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&err];
    if (results && [results count] > 0) {
      _memegrams = results;
    }
    
    [_gridView reloadData];
    // KKGridView is a little odd with how it implements reloadData...
    [_gridView setNeedsLayout];
  }
}
@end
