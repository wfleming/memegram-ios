//
//  BaseModel.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "BaseModel.h"
#import "MGAppDelegate.h"


@interface BaseModel (Private)

+ (MGAppDelegate*) _appDelegate;

@end


@implementation BaseModel

#pragma mark - NSObject & ObjectiveResource overrides

// make a normal init work
- (id) init {
  NSEntityDescription *ed = [[self class] entityDescription];
  if ((self = [self initWithEntity:ed insertIntoManagedObjectContext:nil])) {
  }
  return self;
}


#pragma mark - class methods
+ (NSFetchRequest*) _findAllFetchRequest {
  NSEntityDescription *ed = [self entityDescription];
  NSFetchRequest *fr = [[NSFetchRequest alloc] init];
  [fr setEntity:ed];
  
  return fr;
}

+ (NSUInteger) countAllLocal {
  DASSERT([NSThread isMainThread]);
  NSManagedObjectContext *ctx = [self _appDelegate].managedObjectContext;
  NSFetchRequest *fr = [self _findAllFetchRequest];
  return [ctx countForFetchRequest:fr error:NULL];
}

+ (NSArray*) findAllLocal {
  DASSERT([NSThread isMainThread]);
  NSManagedObjectContext *ctx = [self _appDelegate].managedObjectContext;
  NSFetchRequest *fr = [self _findAllFetchRequest];
  
  NSArray *res = [ctx executeFetchRequest:fr error:NULL];
  
  return res;
}

+ (NSEntityDescription*) entityDescription {
  NSEntityDescription *e = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                       inManagedObjectContext:[self _appDelegate].managedObjectContext];
  return e;
}

@end


#pragma mark -
@implementation BaseModel (Private)

+ (MGAppDelegate*) _appDelegate {
  return (MGAppDelegate*)[UIApplication sharedApplication].delegate;
}

@end
