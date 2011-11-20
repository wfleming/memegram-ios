//
//  UISwitchTableCell.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "UISwitchTableCell.h"
#import "UIView+WillFleming.h"


@implementation UISwitchTableCell

@synthesize uiswitch, changeBlock;

- (id) init {
  return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.uiswitch = [[UISwitch alloc] init];
    self.uiswitch.right = self.contentView.width - 25.0;
    self.uiswitch.top = ((self.contentView.height - self.uiswitch.height) / 2.0);
    [self.uiswitch addTarget:self action:@selector(_selectorChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.uiswitch];
     
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) _selectorChanged:(id)sender {
  if (self.changeBlock) {
    BOOL validValue = self.changeBlock(self.uiswitch);
    if (!validValue) {
      self.uiswitch.on = !self.uiswitch.on;
    }
  }
}

- (void) layoutSubviews {
  [super layoutSubviews];
  [self.contentView bringSubviewToFront:self.uiswitch];
}

@end
