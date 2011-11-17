//
//  IGDefaultSerializer.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IGSerializer

/**
 * expected to return an NSArray or NSDictionary
 */
+ (id) deserializeJSON:(NSData*)jsonData error:(NSError**)error;

//+ (id) deserializeJSONString:(NSString*) error:(NSError**)error;

/**
 * object should be an NSArray or NSDictionary
 */
+ (NSData*) serializeJSON:(id)object error:(NSError**)error;

//+ (id) serializeJSONString:(NSString*) error:(NSError**)error;

@end

@interface IGDefaultSerializer : NSObject <IGSerializer>

@end
