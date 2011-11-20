//
//  InstagramAPI.h
//  Locagram
//
//  Created by William Fleming on 11/13/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IGDefaultSerializer.h"

@class IGInstagramUser, IGResponse;

@interface IGInstagramAPI : NSObject

+ (void) setClientId:(NSString*)clientId;
+ (NSString*) clientId;
+ (void) setOAuthRedirctURL:(NSString*)url;
+ (NSString*)oauthRedirectURL;
+ (void) setAccessToken:(NSString*)accessToken;
+ (NSString*) accessToken;
+ (void) setSerializer:(Class<IGSerializer>)serializer;
+ (Class<IGSerializer>) serializer;
+ (UIWindow*) authWindow;
+ (void) setAuthWindow:(UIWindow*)window;

+ (NSString*) endpoint;
+ (NSString*) versionedEndpoint;
+ (NSString*) authURL;
+ (IGResponse *)post:(NSString *)body to:(NSString *)path;
+ (IGResponse *)get:(NSString *)path;
+ (IGResponse *)put:(NSString *)body to:(NSString *)path;
+ (IGResponse *)delete:(NSString *)path;

+ (IGInstagramUser*)currentUser;

+ (void) authenticateUser; // enter the OAuth flow

@end
