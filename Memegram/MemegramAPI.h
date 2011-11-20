//
//  MemegramAPI.h
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemegramAPI : NSObject

+ (NSString*) apiToken;

+ (NSString*) urlForEndpoint:(NSString*)endpoint;

@end
