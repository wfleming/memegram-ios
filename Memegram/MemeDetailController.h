//
//  MemegramDetailController.h
//  Memegram
//
//  Created by William Fleming on 11/19/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Meme;

@interface MemeDetailController : UITableViewController<UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) Meme *meme;

@end
