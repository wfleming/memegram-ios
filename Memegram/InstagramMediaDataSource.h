//
//  InstagramMediaDataSource.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KKGridView.h"

@class SelectInstagramMediaController, IGInstagramMedia;

@interface InstagramMediaDataSource : NSObject {
  __weak SelectInstagramMediaController *_controller; 
  BOOL _isLoading;
  BOOL _isLoaded;
  NSMutableArray *_mediaItems;
}

- (id) initWithController:(SelectInstagramMediaController*)controller;

- (BOOL) isLoaded;
- (BOOL) isLoading;
- (void) doLoad;

- (NSUInteger) numberOfItemsInGridView:(KKGridView*)gridView;
- (KKGridViewCell*) gridView:(KKGridView*)gridView cellForItemAtIndexPath:(KKIndexPath*)indexPath;
- (IGInstagramMedia*) objectAtIndexPath:(KKIndexPath*)indexPath;

@end
