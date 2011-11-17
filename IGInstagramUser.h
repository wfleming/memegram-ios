//
//  IGInstagramUser.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGInstagramUser : NSObject {
  BOOL _isCurrentUser; // used to track effective 'id' for API calls
}

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *profilePicture;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSNumber *followedByCount;
@property (strong, nonatomic) NSNumber *followsCount;
@property (strong, nonatomic) NSNumber *mediaCount;

+ (IGInstagramUser*) remoteUserWithId:(NSString*)userId error:(NSError**)error;

- (NSArray*) recentMediaError:(NSError**)error;

@end