//
//  TWConnection.h
//  Memegram
//
//  Created by William Fleming on 11/22/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWRequest, Memegram;

@interface MGTWConnection : NSObject

+ (void) postRequest:(TWRequest*)request memegram:(Memegram*)memegram;

@end
