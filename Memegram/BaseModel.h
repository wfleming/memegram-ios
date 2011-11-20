//
//  BaseModel.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BaseModel : NSManagedObject

+ (NSUInteger) countAllLocal;
+ (NSArray*) findAllLocal;
+ (NSEntityDescription*) entityDescription;

@end
