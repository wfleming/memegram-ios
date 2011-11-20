//
//  UITextViewTableCell.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "UITextViewTableCell.h"

#import "UIView+WillFleming.h"
#import "TextViewInputAccessory.h"

@implementation UITextViewTableCell

@synthesize textView, changeBlock;

- (id) init {
  return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      CGRect frame = CGRectMake(5.0, 5.0,
                                self.contentView.width - 10.0,
                                self.contentView.height - 10.0);
      self.textView = [[UITextView alloc] initWithFrame:frame];
      self.textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
      self.textView.font = [UIFont systemFontOfSize:14.0];
      self.textView.backgroundColor = [UIColor clearColor];
      self.textView.inputAccessoryView = [TextViewInputAccessory accessoryForTextView:self.textView];
      
      [self.contentView addSubview:self.textView];
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textViewDidChange:(UITextView *)textView {
  if (self.changeBlock) {
    self.changeBlock(self.textView);
  }
}

@end
