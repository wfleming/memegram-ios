//
//  IGInstagramMedia.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "IGInstagramMedia.h"

@implementation IGInstagramMedia

@synthesize instagramId=_instagramId,
            instagramURL=_instagramURL,
            imageURL=_imageURL;

- (NSString*) iOSURL {
  return [NSString stringWithFormat:@"instagram://media?id=%@", self.instagramId];
}

@end
