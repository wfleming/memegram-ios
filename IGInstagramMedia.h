//
//  IGInstagramMedia.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGInstagramMedia;

typedef void (^IGInstagramMediaImageCallback)(IGInstagramMedia *media, UIImage *image);

@interface IGInstagramMedia : NSObject {
}

@property (strong, nonatomic) NSString *instagramId;
@property (strong, nonatomic) NSString *imageURL; // S3 - don't trust persisted
@property (strong, nonatomic) NSString *thumbnailURL; // S3 - don't trust persisted
@property (strong, nonatomic) NSString *lowResolutionURL; // S3 - don't trust persisted
@property (strong, nonatomic) NSString *instagramURL;  // web url
@property (strong, nonatomic) NSDate *createdTime;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSMutableArray *comments; // array of IGInstagramComment instances
@property (strong, nonatomic) NSMutableArray *tags; // array of strings
@property (strong, nonatomic) NSDictionary *userData;
@property (strong, nonatomic) NSDictionary *locationData;

- (id) initWithJSONFragment:(NSDictionary*)json;

/**
 * An instagram:// URL to view the photo in the local client
 */
- (NSString*) iOSURL;


/**
 * media methods. Variants with a completion block argument execute
 * asynchronously on a background thread: your block will get called on the
 * main thread when the image is ready.
 *
 * variants without the completion block are synchronous
 *
 * //TODO - local caching.
 */
- (UIImage*) image;
- (void) imageCompletionBlock:(IGInstagramMediaImageCallback)completionBlock;
- (UIImage*) thumbnail;
- (void) thumbnailCompletionBlock:(IGInstagramMediaImageCallback)completionBlock;
- (UIImage*) lowResolutionImage;
- (void) lowResolutionImageWithCompletionBlock:(IGInstagramMediaImageCallback)completionBlock;

@end
