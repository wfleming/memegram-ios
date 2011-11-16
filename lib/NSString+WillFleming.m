//
//  NSString+WillFleming.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "NSString+WillFleming.h"

@implementation NSString (WillFleming)

// from http://mesh.typepad.com/blog/2007/10/url-encoding-wi.html
- (NSString*) urlEncodedString {
  NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                          @"@" , @"&" , @"=" , @"+" ,
                          @"$" , @"," , @"[" , @"]",
                          @"#", @"!", @"'", @"(", 
                          @")", @"*", @" ", nil];
  
  NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
                           @"%3A" , @"%40" , @"%26" ,
                           @"%3D" , @"%2B" , @"%24" ,
                           @"%2C" , @"%5B" , @"%5D", 
                           @"%23", @"%21", @"%27",
                           @"%28", @"%29", @"%2A", @"%20", nil];
  
  int len = [escapeChars count];
  
  NSMutableString *temp = [self mutableCopy];
  
  int i;
  for(i = 0; i < len; i++)
  {
    
    [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                          withString:[replaceChars objectAtIndex:i]
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [temp length])];
  }
  
  NSString *out = [NSString stringWithString: temp];
  
  return out;
}

@end
