//
//  InstagramAPI.m
//  Locagram
//
//  Created by William Fleming on 11/13/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramAPI.h"
#import "IGInstagramAuthController.h"

//TODO: how does ARC handle globals? Do I need to custom handle these?
static NSString *g_instagramClientId = nil;
static NSString *g_instagramOAuthRedirectURL = nil;
static NSString *g_instagramAccessToken = nil;

@implementation IGInstagramAPI

#pragma mark - configuration
+ (void) setClientId:(NSString*)clientId {
  g_instagramClientId = clientId;
}

+ (NSString*) clientId {
  return g_instagramClientId;
}

+ (void) setOAuthRedirctURL:(NSString*)url {
  g_instagramOAuthRedirectURL = url;
}

+ (NSString*)oauthRedirectURL {
  return g_instagramOAuthRedirectURL;
}

+ (void) setAccessToken:(NSString*)accessToken {
  g_instagramAccessToken = accessToken;
}

+ (NSString*) accessToken {
  return g_instagramAccessToken;
}


#pragma mark - URLs
+ (NSString*) endpoint {
  return @"https://api.instagram.com";
}

+ (NSString*) authURL {
  return [NSString stringWithFormat:@"%@/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&display=touch",
          [self endpoint],
          [self clientId],
          [self oauthRedirectURL]];
}


#pragma mark -
+ (void) authenticateUser {
  // first, if we actually have an access token, check it for validity
  if ([self accessToken]) {
    //TODO
  }
  
  // established that we're not valid yet - show the auth controller
  IGInstagramAuthController *instagramController = [[IGInstagramAuthController alloc] init];
  
  // get the current root controller
  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
  UIViewController *rootController = [window rootViewController];
  [rootController presentModalViewController:instagramController animated:YES];
}

@end
