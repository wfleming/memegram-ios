//
//  MemegramCell.h
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "KKGridViewCell.h"

@class Meme;

@interface MemegramCell : KKGridViewCell {
  Meme *_memegram;
  UIImageView *_imageView;
}

@property (strong, nonatomic) Meme *memegram;

@end
