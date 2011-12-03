//
//  IGInstagramMedia.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramMedia.h"

#import "IGInstagramFunctions.h"
#import "IGConnection.h"
#import "IGResponse.h"

@implementation IGInstagramMedia

@synthesize instagramId, imageURL, thumbnailURL, lowResolutionURL, instagramURL,
  createdTime, caption, comments, tags, userData, locationData;

- (id) init {
  if ((self = [super init])) {
    self.comments = [NSMutableArray array];
  }
  return self;
}

- (id) initWithJSONFragment:(NSDictionary*)json {
  if ((self = [self init])) {
    self.instagramId = [json objectForKey:@"id"];
    
    self.imageURL = [[[json objectForKey:@"images"] objectForKey:@"standard_resolution"] objectForKey:@"url"];
    self.thumbnailURL = [[[json objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
    self.lowResolutionURL = [[[json objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"];
    
    if (![[NSNull null] isEqual:[json objectForKey:@"link"]]) {
      self.instagramURL = [json objectForKey:@"link"];
    }
    
    self.createdTime = IGDateFromJSONString([json objectForKey:@"created_time"]);
    
    // from some requests, caption is just text. others, a dict.
    id captionInfo = [json objectForKey:@"caption"];
    if ([captionInfo isKindOfClass:[NSDictionary class]]) {
      self.caption = [(NSDictionary*)captionInfo objectForKey:@"text"];
    } else {
      self.caption = captionInfo;
    }
    
    //TODO: turn comments into actual comment data
    //TODO: do....something with likes.
    
    self.tags = [json objectForKey:@"tags"];
    self.userData = [json objectForKey:@"user"];
    self.locationData = [json objectForKey:@"location"];
  }
  return self;
}

- (NSString*) iOSURL {
  return [NSString stringWithFormat:@"instagram://media?id=%@", self.instagramId];
}


#pragma mark - Media methods
- (UIImage*) image {
  IGResponse *response = [IGConnection get:self.imageURL];
  return [UIImage imageWithData:response.rawBody];
}

- (void) imageCompletionBlock:(IGInstagramMediaImageCallback)completionBlock {
  __block IGInstagramMedia *blockSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block UIImage *image = [blockSelf image];
    dispatch_async(dispatch_get_main_queue(), ^{
      completionBlock(blockSelf, image);
    });
  });
}

- (UIImage*) thumbnail {
  IGResponse *response = [IGConnection get:self.thumbnailURL];
  return [UIImage imageWithData:response.rawBody];
}

- (void) thumbnailCompletionBlock:(IGInstagramMediaImageCallback)completionBlock {
  __block IGInstagramMedia *blockSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block UIImage *image = [blockSelf thumbnail];
    dispatch_async(dispatch_get_main_queue(), ^{
      completionBlock(blockSelf, image);
    });
  });
}

- (UIImage*) lowResolutionImage {
  IGResponse *response = [IGConnection get:self.lowResolutionURL];
  return [UIImage imageWithData:response.rawBody];
}

- (void) lowResolutionImageWithCompletionBlock:(IGInstagramMediaImageCallback)completionBlock {
  __block IGInstagramMedia *blockSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block UIImage *image = [blockSelf lowResolutionImage];
    dispatch_async(dispatch_get_main_queue(), ^{
      completionBlock(blockSelf, image);
    });
  });
}

@end
