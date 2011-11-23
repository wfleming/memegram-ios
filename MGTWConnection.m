//
//  TWConnection.m
//  Memegram
//
//  Created by William Fleming on 11/22/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGTWConnection.h"

#import <Twitter/Twitter.h>
#import "Memegram.h"

@implementation MGTWConnection

static NSMutableArray *activeRequests = nil;

+ (NSMutableArray *)activeRequests {
  @synchronized(self) {
    if (nil == activeRequests) {
      activeRequests = [NSMutableArray array];
    }
  }
	return activeRequests;
}

+ (void) postRequest:(TWRequest*)request memegram:(Memegram*)memegram {
  @synchronized([self activeRequests]) {
    [[self activeRequests] addObject:request];
  }
  
//  __block TWRequest *blockRequest = request;
  
  // Block handler to manage the response
  [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
    if ([urlResponse statusCode] > 300) {
      DLOG(@"twitter post failed (status %d): data => %@\nerror => %@",
           [urlResponse statusCode],
           [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding],
           error);
    }
    
    // remove it from the current requests array
//    @synchronized([self activeRequests]) {
//      [[self activeRequests] removeObject:blockRequest];
//    }
  }];
  
}

@end
