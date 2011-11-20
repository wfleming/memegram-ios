//
//  UITextViewTableCell.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TextViewTableCellChangedBlock)(UITextView*);

@interface UITextViewTableCell : UITableViewCell<UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (copy, nonatomic) TextViewTableCellChangedBlock changeBlock;


@end
