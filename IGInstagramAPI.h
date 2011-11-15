//
//  InstagramAPI.h
//  Locagram
//
//  Created by William Fleming on 11/13/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGInstagramAPI : NSObject

+ (void) setClientId:(NSString*)clientId;
+ (NSString*) clientId;
+ (void) setOAuthRedirctURL:(NSString*)url;
+ (NSString*)oauthRedirectURL;
+ (void) setAccessToken:(NSString*)accessToken;
+ (NSString*) accessToken;

+ (NSString*) endpoint;
+ (NSString*) authURL;

+ (void) authenticateUser; // enter the OAuth flow

@end
