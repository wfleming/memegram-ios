//
//  IGInstagramMediaArray.m
//  Memegram
//
//  Created by William Fleming on 12/2/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramMediaCollection.h"

#import "IGInstagramMedia.h"
#import "IGInstagramAPI.h"
#import "IGResponse.h"
#import "IGConnection.h"

@implementation IGInstagramMediaCollection {
  NSMutableArray *_media;
}

@synthesize nextPageURL;

- (id) initWithJSON:(NSDictionary*)json {
  if ((self = [self init])) {
    // the core objects
    _media = [NSMutableArray array];
    NSArray *dataChunks = [json objectForKey:@"data"];
    for(NSDictionary *mediaJSON in dataChunks) {
      [_media addObject:[[IGInstagramMedia alloc] initWithJSONFragment:mediaJSON]];
    }
    
    //pagination metadata
    NSDictionary *pagination = [json objectForKey:@"pagination"];
    self.nextPageURL = [pagination objectForKey:@"next_url"];
  }
  return self;
}

- (BOOL) hasNextPage {
  return  (nil != self.nextPageURL);
}

- (IGInstagramMediaCollection*) nextPageWithError:(NSError* __autoreleasing *)error {
  if (![self hasNextPage]) {
    return nil;
  }
  
  IGInstagramMediaCollection *nextPage = nil;
  IGResponse *response = [IGConnection get:self.nextPageURL];
  if ([response isSuccess]) {
    nextPage = [[IGInstagramMediaCollection alloc] initWithJSON:[response parsedBody]];
  } else {
    if (error) {
      *error = [response error];
    }
    DLOG(@"response error: %@", [response error]);
    DLOG(@"response body: %@", [response parsedBody]);
  }
  
  return nextPage;
}

- (BOOL) loadAndMergeNextPageWithError:(NSError* __autoreleasing *)error {
  IGInstagramMediaCollection *nextPage = [self nextPageWithError:error];
  if (nextPage) {
    for (IGInstagramMedia *m in nextPage) {
      [_media addObject:m];
    }
    
    self.nextPageURL = nextPage.nextPageURL;
    
    return YES;
  }
  
  return NO;
}


#pragma mark - NSArray proxy methods
- (NSUInteger) count {
  return [_media count];
}

- (BOOL) containsObject:(id)object {
  return [_media containsObject:object];
}

- (id) objectAtIndex:(NSUInteger)index {
  return [_media objectAtIndex:index];
}


#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id *)stackbuf count:(NSUInteger)len {
  return [_media countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
