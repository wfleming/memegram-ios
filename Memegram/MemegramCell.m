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

@synthesize memegram=_memegram;

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
    
    self.accessoryPosition = KKGridViewCellAccessoryPositionTopRight;
  }
  return self;
}

#pragma mark - Property override
- (void) setMemegram:(Memegram*)memegram {
  _memegram = memegram;
  _imageView.image = memegram.image;
  
  //TODO - render real accessory views
  if ([_memegram isWaitingForUpload]) {
    self.accessoryType = KKGridViewCellAccessoryTypeUnread;
  } else if ([_memegram isUploading]) {
    self.accessoryType = KKGridViewCellAccessoryTypeNew;
  }
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
