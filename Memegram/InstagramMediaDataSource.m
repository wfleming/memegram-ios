//
//  InstagramMediaDataSource.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "InstagramMediaDataSource.h"

#import "SelectInstagramMediaController.h"
#import "InstagramMediaCell.h"
#import "WFInstagramAPI.h"
#import "WFIGMedia.h"
#import "WFIGUser.h"
#import "WFIGMediaCollection.h"

#pragma mark -
@interface InstagramMediaDataSource ()
@property (strong, nonatomic) WFIGMediaCollection *mediaItems;
@end

#pragma mark -
@implementation InstagramMediaDataSource {
  __weak SelectInstagramMediaController *_controller; 
  BOOL _isLoading;
  BOOL _isLoaded;
  WFIGMediaCollection *_mediaItems;
}


@synthesize mediaItems=_mediaItems;

- (id) initWithController:(SelectInstagramMediaController*)controller {
  if ((self = [super init])) {
    _controller = controller;
    _isLoaded = NO;
    _isLoading = NO;
  }
  return self;
}


#pragma mark - instance methods
- (BOOL) isLoaded {
  return _isLoaded;
}

- (BOOL) isLoading {
  return _isLoading;
}

- (BOOL) canLoadMore {
  return (_mediaItems && [_mediaItems hasNextPage]);
}

- (void) doLoad {
  [self doLoadMore:NO];
}

- (void) doLoadMore:(BOOL)more {
  // attempt nothing if there's no access token or we're already loading
  if (_isLoading) {
    return;
  }
  
  _isLoading = YES;
  
  __block InstagramMediaDataSource *blockSelf = self;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block NSError *error = nil;
    
    if (!more) {
      blockSelf.mediaItems = [[WFInstagramAPI currentUser] recentMediaError:&error];
    } else if (blockSelf.mediaItems && [blockSelf.mediaItems hasNextPage]) {
      [blockSelf.mediaItems loadAndMergeNextPageWithError:&error];
    }
    
    blockSelf->_isLoaded = (blockSelf.mediaItems && [blockSelf.mediaItems count] > 0);
    blockSelf->_isLoading = NO;
 
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!blockSelf.mediaItems && error) {
        [blockSelf->_controller datasourceDidFailLoad];
      } else {
        [blockSelf->_controller datasourceDidFinishLoad];
      }
    });
  });
}

#pragma mark - AQGridViewDataSource implementations
- (NSUInteger) numberOfItemsInGridView:(KKGridView*)gridView {
  return [_mediaItems count];
}

- (KKGridViewCell*) gridView:(KKGridView*)gridView cellForItemAtIndexPath:(KKIndexPath*)indexPath; {
  WFIGMedia *media = [self objectAtIndexPath:indexPath]; 
  InstagramMediaCell *cell = [InstagramMediaCell cellForGridView:gridView];
  cell.media = media;
  
  return cell;
}

- (WFIGMedia*) objectAtIndexPath:(KKIndexPath*)indexPath {
  return [self.mediaItems objectAtIndex:indexPath.index];
}

@end
