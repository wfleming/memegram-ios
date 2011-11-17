//
//  MGMasterViewController.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGridView.h"

@class InstagramMediaDataSource;

@interface SelectInstagramMediaController : UIViewController {
  InstagramMediaDataSource *_dataSource;
  KKGridView *_gridView;
  UIView *_overlayView; // for loading & errors
}

@property (readonly, nonatomic) InstagramMediaDataSource *dataSource;

- (void) datasourceDidFinishLoad;
- (void) datasourceDidFailLoad;

@end
