//
//  InstagramAPI.m
//  Locagram
//
//  Created by William Fleming on 11/13/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramAPI.h"

#import "IGInstagramAuthController.h"
#import "IGInstagramUser.h"
#import "IGConnection.h"

#import "NSString+WillFleming.h"

//TODO: how does ARC handle globals? Do I need to custom handle these?
static NSString *g_instagramClientId = nil;
static NSString *g_instagramOAuthRedirectURL = nil;
static NSString *g_instagramAccessToken = nil;
static Class<IGSerializer> g_instagramSerializer = nil;
static IGInstagramUser *g_instagramCurrentUser = nil;
static UIWindow *g_authWindow = nil;
static IGInstagramAPIErrorHandler g_errorHandler = nil;

@interface IGInstagramAPI (Private)
+ (NSString*) signedURLForPath:(NSString*)path;
@end


#pragma mark -
@implementation IGInstagramAPI

+ (void) initialize {
  g_instagramSerializer = [IGDefaultSerializer class];
}

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

+ (void) setSerializer:(Class<IGSerializer>)serializer {
  g_instagramSerializer = serializer;
}

+ (Class<IGSerializer>) serializer {
  return g_instagramSerializer;
}

+ (UIWindow*) authWindow {
  return g_authWindow;
}

+ (void) setAuthWindow:(UIWindow*)window {
  g_authWindow = window;
}

+ (IGInstagramAPIErrorHandler)globalErrorHandler {
  return g_errorHandler;
}

+ (void) setGlobalErrorHandler:(IGInstagramAPIErrorHandler)block {
  g_errorHandler = [block copy];
}


#pragma mark - URLs
+ (NSString*) endpoint {
  return @"https://api.instagram.com";
}

+ (NSString*) versionedEndpoint {
  return [NSString stringWithFormat:@"%@/v1", [self endpoint]];
}

+ (NSString*) authURL {
  return [NSString stringWithFormat:@"%@/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code&display=touch",
          [self endpoint],
          [self clientId],
          [[self oauthRedirectURL] urlEncodedString]];
}

+ (IGResponse *)post:(NSString *)body to:(NSString *)path {
  return [IGConnection post:body to:[self signedURLForPath:path]];
}

+ (IGResponse *)get:(NSString *)path {
  return [IGConnection get:[self signedURLForPath:path]];
}

+ (IGResponse *)put:(NSString *)body to:(NSString *)path {
  return [IGConnection put:body to:[self signedURLForPath:path]];
}

+ (IGResponse *)delete:(NSString *)path {
  return [IGConnection delete:[self signedURLForPath:path]];
}


#pragma mark -
+ (IGInstagramUser*)currentUser {
  if (!g_instagramCurrentUser) {
    NSError *err = nil;
    g_instagramCurrentUser = [IGInstagramUser remoteUserWithId:@"self" error:&err];
    if (!g_instagramCurrentUser && err) {
      DLOG(@"Error attempting to fetch current user: %@", err);
    }
  }
  return g_instagramCurrentUser;
}


#pragma mark -
+ (void) authenticateUser {
  // first, if we actually have an access token, check it for validity
  if ([self accessToken] && [self currentUser]) {
    // if these two things exist, we're valid
    return;
  }
  
  // nothing more required -- +currentUser will enter flow if needed
}

+ (void) enterAuthFlow {
  // established that we're not valid yet - show the auth controller
  IGInstagramAuthController *authController = [[IGInstagramAuthController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authController];
  navController.navigationBarHidden = YES;
  
  // swap out current window for a window containing our auth view
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
  UIWindow *authWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  authWindow.rootViewController = navController;
  [self setAuthWindow:authWindow];  // otherwise it get's released silently...
  [keyWindow resignKeyWindow];
  keyWindow.hidden = YES;
  [authWindow makeKeyAndVisible];
}

@end




#pragma mark -
@implementation IGInstagramAPI (Private)
+ (NSString*) signedURLForPath:(NSString*)path {
  NSMutableString *url = [NSMutableString stringWithFormat:@"%@%@%@",
                   [self versionedEndpoint],
                   ('/' == [path characterAtIndex:0] ? @"" : @"/"),
                   path];
  // append whichever token we have access to
  // append a ? if there are no query params, otherwise a &
  [url appendString:(NSNotFound == [url rangeOfString:@"?"].location ? @"?" : @"&")];
  if ([IGInstagramAPI accessToken]) {
    [url appendFormat:@"access_token=%@", [IGInstagramAPI accessToken]];
  } else {
    [url appendFormat:@"client_id=%@", [IGInstagramAPI clientId]];
  }
  return [NSString stringWithString:url];
}
@end