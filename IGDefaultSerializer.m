//
//  IGDefaultSerializer.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGDefaultSerializer.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

@implementation IGDefaultSerializer

+ (id) deserializeJSON:(NSData*)jsonData error:(NSError**)error {
  return [[CJSONDeserializer deserializer] deserialize:jsonData error:error];
}


+ (NSData*) serializeJSON:(id)object error:(NSError**)error {
  return [[CJSONSerializer serializer] serializeObject:object error:error];
}

@end
