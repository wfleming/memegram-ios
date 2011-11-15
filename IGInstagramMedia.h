//
//  IGInstagramMedia.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGInstagramMedia : NSObject {
  NSString *_instagramId;
  NSString *_imageURL; // S3 - don't trust persisted
  NSString *_instagramURL; // web URL
}

@property (strong, nonatomic) NSString *instagramId;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *instagramURL;

/**
 * An instagram:// URL to view the photo in the local client
 */
- (NSString*) iOSURL;

@end
