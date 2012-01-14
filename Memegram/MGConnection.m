//
//  MGConnection.m
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGConnection.h"
#import "MemegramAPI.h"

@implementation MGConnection

+ (WFIGResponse *)sendRequest:(NSMutableURLRequest *)request {
  [request setValue:[MemegramAPI apiToken] forHTTPHeaderField:@"X-Auth-Token"];
  return [super sendRequest:request];
}

@end
