//
//  ImageToDataTransformer.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "ImageToDataTransformer.h"

@implementation ImageToDataTransformer

+ (Class)transformedValueClass 
{
  return [NSData class]; 
}

+ (BOOL)allowsReverseTransformation 
{
  return YES; 
}

- (id)transformedValue:(id)value 
{
  if (value == nil)
    return nil;
  
  // I pass in raw data when generating the image, save that directly to the database
  if ([value isKindOfClass:[NSData class]])
    return value;
  
  return UIImagePNGRepresentation((UIImage *)value);
}

- (id)reverseTransformedValue:(id)value
{
  return [UIImage imageWithData:(NSData *)value];
}

@end
