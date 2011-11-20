//
//  UISwitchTableCell.h
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

// return NO to prevent the change
typedef BOOL (^UISwitchTableCellChangedBlock)(UISwitch *uiswitch);

@interface UISwitchTableCell : UITableViewCell

@property (strong, nonatomic) UISwitch *uiswitch;
@property (copy, nonatomic) UISwitchTableCellChangedBlock changeBlock;

@end
