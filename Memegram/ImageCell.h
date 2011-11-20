//
//  ImageCell.h
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell {
  UIImageView *_bigImageView;
}

@property (strong, nonatomic) UIImage *image;

- (id) init;

@end
