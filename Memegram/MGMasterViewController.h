//
//  MGMasterViewController.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGDetailViewController;

#import <CoreData/CoreData.h>

@interface MGMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MGDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
