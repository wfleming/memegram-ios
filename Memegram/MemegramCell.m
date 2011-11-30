//
//  MemegramCell.m
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MemegramCell.h"

#import "Memegram.h"
#import "UIView+WillFleming.h"

@implementation MemegramCell

static const CGFloat frameSize = 1.0;

@synthesize memegram=_memegram;

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
    
    self.accessoryPosition = KKGridViewCellAccessoryPositionTopRight;
  }
  return self;
}

#pragma mark - Property override
- (void) setMemegram:(Memegram*)memegram {
  _memegram = memegram;
  _imageView.image = memegram.image;
  
  UIImageView *newAccessory = nil;
  UIImage *badgeImg = nil;
  
  if ([_memegram isWaitingForUpload]) {
    badgeImg = [UIImage imageNamed:@"waiting-indicator"];
  } else if ([_memegram isUploading]) {
    badgeImg = [UIImage imageNamed:@"upload-indicator"];
  }
  
  if (badgeImg) {
    newAccessory = [[UIImageView alloc] initWithImage:badgeImg];
  }
  
  self.accessoryView = newAccessory;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
}

- (void) prepareForReuse {
  _memegram = nil;
  _imageView.image = nil;
}

@end
