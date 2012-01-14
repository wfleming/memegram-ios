//
//  InstagramMediaDataSource.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KKGridView.h"

@class SelectInstagramMediaController, WFIGMedia;

@interface InstagramMediaDataSource : NSObject

- (id) initWithController:(SelectInstagramMediaController*)controller;

- (BOOL) isLoaded;
- (BOOL) isLoading;
- (BOOL) canLoadMore;
- (void) doLoad;
- (void) doLoadMore:(BOOL)more;

- (NSUInteger) numberOfItemsInGridView:(KKGridView*)gridView;
- (KKGridViewCell*) gridView:(KKGridView*)gridView cellForItemAtIndexPath:(KKIndexPath*)indexPath;
- (WFIGMedia*) objectAtIndexPath:(KKIndexPath*)indexPath;

@end
