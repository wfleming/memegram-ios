//
//  InstagramMediaCell.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "KKGridViewCell.h"

@class IGInstagramMedia;

@interface InstagramMediaCell : KKGridViewCell {
  IGInstagramMedia *_media;
  UIImageView *_imageView;
}

@property (strong, nonatomic) IGInstagramMedia *media;

@end
