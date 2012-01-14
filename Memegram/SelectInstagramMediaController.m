//
//  MGMasterViewController.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "SelectInstagramMediaController.h"

#import "InstagramMediaDataSource.h"
#import "WFInstagramAPI.h"
#import "CreateMemeController.h"
#import "UIView+WillFleming.h"

@interface SelectInstagramMediaController (Private)
- (KKGridView*) gridView;
- (UIView*) loadingView;

-(void) displayLoadingView;
-(void) displayErrorView;
-(void) displayGridView;

- (void) windowDidBecomeKey:(id)sender;

- (void) setGridFooter;
- (void) loadMore:(id)sender;
@end

@implementation SelectInstagramMediaController {
  InstagramMediaDataSource *_dataSource;
  KKGridView *_gridView;
  UIView *_overlayView; // for loading & errors
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Your Instagrams", @"Your Instagrams");
    self.tabBarItem.image = [UIImage imageNamed:@"your-instagrams-tab-icon"];
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
  if (nil == self.view.superview) { // i.e. if we're not visible
    _dataSource = nil;
  }
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - data source handling
- (void) datasourceDidFinishLoad {
  [self setGridFooter];
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
  _gridView = nil;
  _overlayView = nil;
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
      WFIGMedia *media = [[self dataSource] objectAtIndexPath:indexPath];
      CreateMemeController *controller = [[CreateMemeController alloc] init];
      controller.sourceMedia = media;
      [self.navigationController pushViewController:controller animated:YES];
      KKGridViewCell *cell = self.gridView.cellBlock(gridView, indexPath);
      cell.selected = NO;
    }];
  }
  return _gridView;
}

- (UIView*) loadingView {
  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 30.0)];
  v.backgroundColor = [UIColor clearColor];
  
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [spinner startAnimating];
  [v addSubview:spinner];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(spinner.width + 10.0,
                                                             0.0,
                                                             v.width - spinner.width - 10.0,
                                                             spinner.height)];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textColor = [UIColor darkGrayColor];
  label.backgroundColor = [UIColor clearColor];
  label.text = @"Loading...";
  label.width = [label.text sizeWithFont:label.font].width;
  [v addSubview:label];
  
  v.width = spinner.width + 10.0 + label.width;
  v.height = spinner.height;
  
  return v;
}

-(void) displayLoadingView {
  if (_overlayView) {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
  }
  
  _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
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

- (void) setGridFooter {
  UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
  if (self.dataSource && [self.dataSource canLoadMore]) {
    v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)];
    
    if ([self.dataSource isLoading]) {
      UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      activityIndicator.center = CGPointMake((activityIndicator.width / 2.0) + 10.0, (v.height / 2.0));
      [activityIndicator startAnimating];
      
      UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(activityIndicator.right + 10.0, 0, 150.0, v.height)];
      lbl.textColor = [UIColor darkGrayColor];
      lbl.text = @"Loading...";
      
      lbl.width = [lbl.text sizeWithFont:lbl.font].width;
      
      UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, activityIndicator.width + 10.0 + lbl.width, v.height)];
      [wrapper addSubview:activityIndicator];
      [wrapper addSubview:lbl];
      
      [v addSubview:wrapper];
      wrapper.center = v.center;
    } else {        
      UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
      btn.frame = v.bounds;
      [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
      btn.tintColor = [UIColor lightGrayColor];
      [btn setTitle:@"Tap to Load More" forState:UIControlStateNormal];
      UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMore:)];
      [btn addGestureRecognizer:gesture];
      [v addSubview:btn];
    }
  }

  self.gridView.gridFooterView = v;
}

- (void) loadMore:(id)sender {
  [self.dataSource doLoadMore:YES];
  [self.gridView reloadData];
  [self setGridFooter];
  [self.gridView setNeedsLayout];
}

@end
