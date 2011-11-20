//
//  IGInstagramUser.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramUser.h"

#import "IGInstagramAPI.h"
#import "IGConnection.h"
#import "IGResponse.h"
#import "IGInstagramMedia.h"

@interface IGInstagramUser (Private)
- (NSString*) effectiveApiId;
@end

#pragma mark -
@implementation IGInstagramUser

@synthesize username, userId, profilePicture, website, fullName, bio,
  followedByCount, followsCount, mediaCount;

+ (IGInstagramUser*) remoteUserWithId:(NSString*)userId error:(NSError* __autoreleasing*)error {
  IGInstagramUser *user = nil;
  IGResponse *response = [IGInstagramAPI get:[NSString stringWithFormat:@"/users/%@", userId]];
  if ([response isSuccess]) {
    user = [[self alloc] init];
    NSDictionary *data = [[response parsedBody] objectForKey:@"data"];
    user.userId = [data objectForKey:@"id"];
    user.username = [data objectForKey:@"username"];
    user.profilePicture = [data objectForKey:@"profile_picture"];
    user.website = [data objectForKey:@"website"];
    user.bio = [data objectForKey:@"bio"];
    user.fullName = [data objectForKey:@"full_name"];
    
    NSDictionary *counts = [data objectForKey:@"counts"];
    user.followsCount = [counts objectForKey:@"follows"];
    DASSERT([user.followsCount isKindOfClass:[NSNumber class]]);
    user.followedByCount = [counts objectForKey:@"followed_by"];
    DASSERT([user.followedByCount isKindOfClass:[NSNumber class]]);
    user.mediaCount = [counts objectForKey:@"media"];
    DASSERT([user.mediaCount isKindOfClass:[NSNumber class]]);
    
    user->_isCurrentUser = [@"self" isEqual:userId];
  } else {
    if (error) {
      *error = [response error];
    }
    DLOG(@"response error: %@", [response error]);
    DLOG(@"response body: %@", [response parsedBody]);
  }
  return user;
}

- (NSArray*) recentMediaError:(NSError* __autoreleasing*)error; {
  NSArray *media = nil;
  IGResponse *response = [IGInstagramAPI get:[NSString stringWithFormat:@"/users/%@/media/recent", [self effectiveApiId]]];
  if ([response isSuccess]) {
    NSMutableArray *mutableMedia = [NSMutableArray array];
    NSArray *dataChunks = [[response parsedBody] objectForKey:@"data"];
    for(NSDictionary *mediaJSON in dataChunks) {
      [mutableMedia addObject:[[IGInstagramMedia alloc] initWithJSONFragment:mediaJSON]];
    }
    media = [NSArray arrayWithArray:mutableMedia];
  } else {
    if (error) {
      *error = [response error];
    }
    DLOG(@"response error: %@", [response error]);
    DLOG(@"response body: %@", [response parsedBody]);
  }
  
  return media;
}
@end


#pragma mark -
@implementation IGInstagramUser (Private)
- (NSString*) effectiveApiId {
  return (_isCurrentUser ? @"self" : self.userId);
}
@end