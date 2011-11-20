//
//  IGConnection.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGResponse;

@interface IGConnection : NSObject

+ (IGResponse *)post:(NSString *)body to:(NSString *)url;
+ (IGResponse *)get:(NSString *)url;
+ (IGResponse *)put:(NSString *)body to:(NSString *)url;
+ (IGResponse *)delete:(NSString *)url;

// public so it can be overriden
+ (IGResponse *)sendRequest:(NSMutableURLRequest *)request;
+ (NSMutableURLRequest*) requestForMethod:(NSString *)method to:(NSString *)url;

+ (void) cancelAllActiveConnections;


@end
