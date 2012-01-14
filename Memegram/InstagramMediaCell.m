//
//  InstagramMediaCell.m
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "InstagramMediaCell.h"

#import "WFIGMedia.h"
#import "UIView+WillFleming.h"

@implementation InstagramMediaCell

static const CGFloat frameSize = 1.0;

@synthesize media=_media;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
  if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])) {
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.width = _imageView.width - (frameSize * 2.0);
    _imageView.height = _imageView.height - (frameSize * 2.0);
    _imageView.top = frameSize;
    _imageView.left = frameSize;
    [self.contentView addSubview:_imageView];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor greenColor];
  }
  return self;
}

#pragma mark - Property override
- (void) setMedia:(__block WFIGMedia *)media {
  _media = media;
  
  __block typeof(self) blockSelf = self;
  [_media thumbnailCompletionBlock:^(WFIGMedia *media, UIImage *image) {
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
}

- (void) prepareForReuse {
  _media = nil;
  _imageView.image = nil;
}
@end
