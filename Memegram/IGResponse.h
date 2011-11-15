//
//  IGResponse.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGResponse : NSObject {
  NSData *_rawBody;
  NSDictionary *_body; // parsed JSON
	NSDictionary *_headers;
	NSInteger _statusCode;
	NSError *_error;
}

@property (nonatomic, readonly) NSDictionary *body;
@property (nonatomic, readonly) NSDictionary *headers;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSError *error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError;
- (id)initFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError;
- (BOOL)isSuccess;
- (BOOL)isError;
- (NSString*)debugDescription;


@end
