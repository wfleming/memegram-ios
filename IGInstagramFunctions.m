//
//  IGInstagramFunctions.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <stdio.h>
#import "IGInstagramFunctions.h"

NSDate* IGDateFromJSONString(NSString* str) {
  NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterNoStyle];
  double timestamp = [[f numberFromString:str] doubleValue];
  return [NSDate dateWithTimeIntervalSince1970:timestamp];
}