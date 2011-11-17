//
//  InstagramMediaCell.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "InstagramMediaCell.h"

#import "IGInstagramMedia.h"
#import "UIView+WillFleming.h"

@implementation InstagramMediaCell

@synthesize media=_media;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
  if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])) {
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.width = _imageView.width - 10.0;
    _imageView.height = _imageView.height - 10.0;
    _imageView.top = 5.0;
    _imageView.left = 5.0;
    [self.contentView addSubview:_imageView];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor greenColor];
  }
  return self;
}

#pragma mark - Property override
- (void) setMedia:(__block IGInstagramMedia *)media {
  DLOG(@"cell %@", self);
  _media = media;
  
  __block typeof(self) blockSelf = self;
  [_media thumbnailCompletionBlock:^(IGInstagramMedia *media, UIImage *image) {
    if (media == blockSelf.media) {
      blockSelf->_imageView.image = image;
    } else {
      DLOG(@"OOPS - wrong media for this cell %@", blockSelf);
    }
  }];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  DLOG(@"%@ layoutSubviews", self.media.instagramId);
  DLOG(@"contentView Frame = %@", NSStringFromCGRect(self.contentView.frame));
  DLOG(@"contentView bounds = %@", NSStringFromCGRect(self.contentView.bounds));
  DLOG(@"imageView Frame = %@", NSStringFromCGRect(_imageView.frame));
  DLOG(@"imageView bounds = %@", NSStringFromCGRect(_imageView.bounds));
  DLOG(@"\n\n");
}

- (void) prepareForReuse {
//  _imageView.image = nil;
}
@end
