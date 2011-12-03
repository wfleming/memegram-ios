//
//  IGInstagramMediaArray.h
//  Memegram
//
//  Created by William Fleming on 12/2/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGInstagramMediaCollection : NSObject<NSFastEnumeration>

@property (strong, nonatomic) NSString *nextPageURL;

- (id) initWithJSON:(NSDictionary*)json;

- (BOOL) hasNextPage;
- (IGInstagramMediaCollection*) nextPageWithError:(NSError* __autoreleasing *)error;
- (BOOL) loadAndMergeNextPageWithError:(NSError* __autoreleasing *)error;

// NSArray proxy methods
- (NSUInteger) count;
- (BOOL) containsObject:(id)object;
- (id) objectAtIndex:(NSUInteger)index;

@end
