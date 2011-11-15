//
//  IGInstagramAuthController.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGAuthDefaultInitialView.h"

@interface IGInstagramAuthController : UIViewController<UIWebViewDelegate> {
  UIWebView *_webView;
  UIActivityIndicatorView *_activityIndicator;
  UILabel *_statusLabel;
  UIView<IGAuthInitialView> *_initialView;
}

- (IBAction)gotoInstagramAuthURL:(id)sender;

@end
