//
//  Memegram.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//


#import "BaseModel.h"

@interface Memegram : BaseModel

@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSString * instagramSourceId;
@property (nonatomic, strong) NSString * instagramSourceLink;
@property (nonatomic, strong) NSNumber * memegramId;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSNumber * shareToTwitter;
@property (nonatomic, strong) NSNumber * shareToTumblr;
@property (nonatomic, strong) NSNumber * shareToFacebook;
@property (nonatomic, strong) NSDate *createdAt;


- (BOOL) uploadError:(NSError* __autoreleasing*)error;

- (NSData*) uploadRepresentation; // does not include image data
- (void) updateFromJSON:(NSDictionary*)json;

- (BOOL) isUploaded;
- (BOOL) isUploading;
- (BOOL) isWaitingForUpload;

@end
