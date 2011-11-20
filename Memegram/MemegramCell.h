//
//  MemegramCell.h
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "KKGridViewCell.h"

@class Memegram;

@interface MemegramCell : KKGridViewCell {
  Memegram *_memegram;
  UIImageView *_imageView;
}

@property (strong, nonatomic) Memegram *memegram;

@end
