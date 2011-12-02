//
//  MGAppDelegate.h
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBConnect.h"

@interface MGAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) Facebook *facebook;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
