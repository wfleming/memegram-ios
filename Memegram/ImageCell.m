//
//  ImageCell.m
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "ImageCell.h"

#import "UIView+WillFleming.h"

@implementation ImageCell

@dynamic image;

- (id) init {
  if ((self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])])) {
    CGRect frame = CGRectMake(10.0, 10.0, self.contentView.width - 20.0, self.contentView.height - 20.0);
    _bigImageView = [[UIImageView alloc] initWithFrame:frame];
    _bigImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_bigImageView];
  }
  return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse {
  _bigImageView.image = nil;
  [super prepareForReuse];
}


#pragma mark - property implementations

- (UIImage*)image {
  return _bigImageView.image;
}

- (void) setImage:(UIImage *)image {
  _bigImageView.image = image;
}

@end
