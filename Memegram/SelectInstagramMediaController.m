//
//  MGMasterViewController.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "SelectInstagramMediaController.h"

#import "InstagramMediaDataSource.h"
#import "IGInstagramAPI.h"
#import "IGInstagramMedia.h"
#import "CreateMemegramController.h"
#import "UIView+WillFleming.h"

@interface SelectInstagramMediaController (Private)
- (KKGridView*) gridView;
- (UIView*) loadingView;

-(void) displayLoadingView;
-(void) displayErrorView;
-(void) displayGridView;

- (void) windowDidBecomeKey:(id)sender;
@end

@implementation SelectInstagramMediaController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Your Instagrams", @"Your Instagrams");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:UIWindowDidBecomeKeyNotification object:self.view.window];
  }
  return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //TODO - tell datasource to release memory if it can.
}


#pragma mark - data source handling
- (void) datasourceDidFinishLoad {
  [self displayGridView];
}

- (void) datasourceDidFailLoad {
  [self displayErrorView];
}

#pragma mark - View lifecycle

- (void) loadView {
  CGRect frame = CGRectMake(0, 0, 320, 480);
  self.view = [[UIView alloc] initWithFrame:frame];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view.autoresizesSubviews = YES;
  [self.view addSubview:[self gridView]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (![self dataSource].isLoaded) {
    [[self dataSource] doLoad];
    [self displayLoadingView];
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation == UIInterfaceOrientationPortrait);
  } else {
      return YES;
  }
}


#pragma mark - AQGridViewDelegate implementations


#pragma mark - Property Implementations
- (InstagramMediaDataSource*) dataSource {
  if (!_dataSource) {
    _dataSource = [[InstagramMediaDataSource alloc] initWithController:self];
  }
  return _dataSource;
}

@end


@implementation SelectInstagramMediaController (Private)

- (KKGridView*) gridView {
  if (!_gridView) {
    // grid properties
    _gridView = [[KKGridView alloc] initWithFrame:self.view.bounds];
    _gridView.allowsMultipleSelection = NO;
    _gridView.scrollsToTop = YES;
    _gridView.backgroundColor = [UIColor whiteColor];
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _gridView.cellSize = CGSizeMake(74.0, 74.0);
    _gridView.cellPadding = CGSizeMake(5.0, 5.0);
    
    // set up delegate/datasource handlers
    __block typeof(self) blockSelf = self;
    
    [self.gridView setNumberOfItemsInSectionBlock:^(KKGridView *gridView, NSUInteger section) {
      return [[blockSelf dataSource] numberOfItemsInGridView:gridView];
    }];
    
    [self.gridView setNumberOfSectionsBlock: ^(KKGridView *gridView) {
      return (NSUInteger)1;
    }];
    
    [self.gridView setCellBlock:^(KKGridView *gridView, KKIndexPath *indexPath) {
      return [[blockSelf dataSource] gridView:gridView cellForItemAtIndexPath:indexPath];
    }];
    
    [self.gridView setDidSelectIndexPathBlock:^(KKGridView *gridView, KKIndexPath *indexPath) {
      IGInstagramMedia *media = [[self dataSource] objectAtIndexPath:indexPath];
      CreateMemegramController *controller = [[CreateMemegramController alloc] init];
      controller.sourceMedia = media;
      [self.navigationController pushViewController:controller animated:YES];
      KKGridViewCell *cell = self.gridView.cellBlock(gridView, indexPath);
      cell.selected = NO;
    }];
  }
  return _gridView;
}

- (UIView*) loadingView {
  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
  v.backgroundColor = [UIColor clearColor];
  
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [spinner startAnimating];
  [v addSubview:spinner];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(spinner.width + 10.0, 0, 200, 50)];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textColor = [UIColor darkGrayColor];
  label.backgroundColor = [UIColor clearColor];
  label.text = @"Loading...";
  [v addSubview:label];
  
  return v;
}

-(void) displayLoadingView {
  if (_overlayView) {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
  }
  
  _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
  _overlayView.backgroundColor = [UIColor orangeColor]; //DEBUG
  _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleHeight;
  _overlayView.autoresizesSubviews = YES;
  
  UIView *content = [self loadingView];
  content.center = _overlayView.center;
  content.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
  content.autoresizesSubviews = NO;
  [_overlayView addSubview:content];
  
  [self.view addSubview:_overlayView];
  [self.view bringSubviewToFront:_overlayView];
}

-(void) displayErrorView {
  if (_overlayView) {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
  }
  
  //TODO - generate & show the error view
  
  [self.view addSubview:_overlayView];
  [self.view bringSubviewToFront:_overlayView];
}

-(void) displayGridView {
  if (_overlayView) {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
  }
   
  [self.gridView reloadData];
  [self.view bringSubviewToFront:self.gridView];
  // KKGridView is a little odd with how it implements reloadData...
  [self.gridView setNeedsLayout];
}

- (void) windowDidBecomeKey:(NSNotification*)notification {
  // gets called after user finishes auth flow
  if ([self isViewLoaded] && self.view.window == notification.object) {
    if (![self dataSource].isLoaded) {
      [[self dataSource] doLoad];
      [self displayLoadingView];
    }
  }
}

@end
