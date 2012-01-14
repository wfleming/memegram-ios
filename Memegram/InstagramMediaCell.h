//
//  InstagramMediaCell.h
//  Memegram
//
//  Created by William Fleming on 11/16/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "KKGridViewCell.h"

@class WFIGMedia;

@interface InstagramMediaCell : KKGridViewCell {
  WFIGMedia *_media;
  UIImageView *_imageView;
}

@property (strong, nonatomic) WFIGMedia *media;

@end
