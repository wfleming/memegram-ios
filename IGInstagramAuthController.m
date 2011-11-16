//
//  IGInstagramAuthController.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramAuthController.h"
#import "IGInstagramAPI.h"

@interface IGInstagramAuthController (Private)
- (UIWebView*) webView;
- (UIActivityIndicatorView*) activityIndicator;
- (UILabel*) statusLabel;
- (UIView*) statusContainerView;
@end

#pragma mark -
@implementation IGInstagramAuthController

Class initialViewClass = NULL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  if (NULL != initialViewClass) {
    self.view = [[initialViewClass alloc] initWithController:self];
  } else {
    self.view = [[IGAuthDefaultInitialView alloc] initWithController:self];
  }
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
  [super viewDidUnload];
  _webView = nil;
  _activityIndicator = nil;
  _statusLabel = nil;
  _initialView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - action handling

- (IBAction)gotoInstagramAuthURL:(id)sender {
  // rebuild view for webview
  UIView *newView = [[UIView alloc] initWithFrame:self.view.frame];
  [newView addSubview:[self statusContainerView]];
  [newView addSubview:[self webView]];
  self.view = newView;
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[IGInstagramAPI authURL]]];
  [[self webView] loadRequest:request];
}

#pragma mark - UIWebViewDelegate Implementations
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  // Determine if we want the system to handle it.
  NSURL *url = request.URL;
  if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
      [[UIApplication sharedApplication]openURL:url];
      return NO;
    }
  }
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  [_activityIndicator startAnimating];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  _statusLabel.text = @"Loading...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [_activityIndicator stopAnimating];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  _statusLabel.text = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  // Ignore NSURLErrorDomain error -999.
  if (error.code == NSURLErrorCancelled) return;
  
  // Ignore "Frame Load Interrupted" errors. Seen after app URLs
  if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
  
  // normal error response
  [_activityIndicator stopAnimating];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  _statusLabel.text = @"ERROR";
  
  //TODO - give the user some way to restart the flow or get out of here
}


#pragma mark - properties

- (UIWebView*) webView {
  if (!_webView) {
    CGRect webFrame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height);
    _webView = [[UIWebView alloc] initWithFrame:webFrame];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
  }
  return _webView;
}

- (UIActivityIndicatorView*) activityIndicator {
  if (!_activityIndicator) {
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.frame = CGRectMake(10, 10, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
    _activityIndicator.hidesWhenStopped = YES;
  }
  return _activityIndicator;
}

- (UILabel*) statusLabel {
  if (!_statusLabel) {
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 200, 20)];
    _statusLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.backgroundColor = [UIColor clearColor];
  }
  return _statusLabel;
}

- (UIView*) statusContainerView {
  UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];
  v.backgroundColor = [UIColor blackColor];
  [v addSubview:[self activityIndicator]];
  [v addSubview:[self statusLabel]];
  return v;
}

@end
