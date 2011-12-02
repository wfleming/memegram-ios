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
#import "UIView+WillFleming.h"

@interface YourMemegramsController (Private)
- (void) _reloadDataForce:(BOOL)force;
- (void) _showEmptyMessage;
- (void) _hideEmptyMessage;
@end

@implementation YourMemegramsController {
  KKGridView *_gridView;
  UIView *_emptyMessageView;
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

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (nil == self.view.superview) { // i.e. if we're not visible
    _memegrams = nil;
  }
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
  [self _hideEmptyMessage];
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
    } else {
      [self _showEmptyMessage];
    }
    
    [_gridView reloadData];
    // KKGridView is a little odd with how it implements reloadData...
    [_gridView setNeedsLayout];
  }
}

- (void) _showEmptyMessage {
  if (_emptyMessageView) {
    [_emptyMessageView removeFromSuperview];
  }
  _emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.width, 0.0)];
  
  CGFloat maxWidth = (_emptyMessageView.width - 30.0), padding = 10.0;
  
  UILabel *topLbl = [[UILabel alloc] init];
  topLbl.text = @"You Haven't Made Any Lolgramz Yet!";
  topLbl.font = [UIFont systemFontOfSize:22.0];
  topLbl.textAlignment = UITextAlignmentCenter;
  topLbl.textColor = [UIColor lightGrayColor];
  topLbl.lineBreakMode = UILineBreakModeWordWrap;
  topLbl.numberOfLines = 0;
  
  CGSize neededSize = [topLbl.text sizeWithFont:topLbl.font
                              constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                  lineBreakMode:topLbl.lineBreakMode];
  neededSize.width = neededSize.width + padding;
  neededSize.height = neededSize.height + padding;
  CGFloat x = (_emptyMessageView.width - neededSize.width) / 2.0;
  topLbl.frame = CGRectMake(x, 0.0, neededSize.width, neededSize.height);
  
  
  UILabel *bottomLbl = [[UILabel alloc] init];
  bottomLbl.text = @"Why don't you go make some?";
  bottomLbl.font = [UIFont systemFontOfSize:14.0];
  bottomLbl.textAlignment = UITextAlignmentCenter;
  bottomLbl.textColor = [UIColor lightGrayColor];
  bottomLbl.lineBreakMode = UILineBreakModeWordWrap;
  bottomLbl.numberOfLines = 0;
  
  neededSize = [bottomLbl.text sizeWithFont:bottomLbl.font
                          constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                              lineBreakMode:bottomLbl.lineBreakMode];
  neededSize.width = neededSize.width + padding;
  neededSize.height = neededSize.height + padding;
  x = (_emptyMessageView.width - neededSize.width) / 2.0;
  bottomLbl.frame = CGRectMake(x, topLbl.height, neededSize.width, neededSize.height);
  
  CGFloat height = topLbl.height + bottomLbl.height;
  _emptyMessageView.frame = CGRectMake(0,
                                       (self.view.height - height) / 2.0,
                                       self.view.width,
                                       height);
  
  [_emptyMessageView addSubview:topLbl];
  [_emptyMessageView addSubview:bottomLbl];
  
  [self.view addSubview:_emptyMessageView];
}

- (void) _hideEmptyMessage {
  [_emptyMessageView removeFromSuperview];
  _emptyMessageView = nil;
}
@end
