//
//  MGAccountHelper.h
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>


@interface MGAccountHelper : NSObject

+ (ACAccount*) __attribute__((ns_returns_autoreleased)) defaultTwitterAccount;

@end
