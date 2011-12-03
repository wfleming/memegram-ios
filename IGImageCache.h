//
//  IGImageCacher.h
//  Memegram
//
//  Created by William Fleming on 12/3/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGImageCache : NSObject

+ (NSURL*) cacheDirectory;
+ (UIImage*) getImageAtURL:(NSString*)url;

@end
