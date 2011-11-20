//
//  MemegramAPI.m
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramAPI.h"
#import "MGConstants.h"

@implementation MemegramAPI

+ (NSString*) apiToken {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:kDefaultsMemegramToken];
}

+ (NSString*) urlForEndpoint:(NSString*)endpoint {
  return [NSString stringWithFormat:@"%@%@", API_BASE_URL, endpoint];
}

@end
