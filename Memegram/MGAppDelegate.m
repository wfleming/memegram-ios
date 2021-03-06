//
//  MGAppDelegate.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGAppDelegate.h"

#import "SelectInstagramMediaController.h"
#import "YourMemesController.h"

#import "WFInstagramAPI.h"
#import "NSURL+WillFleming.h"
#import "MGConstants.h"
#import "MGUploader.h"
#import "ABNotifier.h"
#import "LolgramzAuthInitialView.h"

#pragma mark -
@interface MGAppDelegate (Private)
- (void) ensureUserLoggedIn;
@end


#pragma mark -
@implementation MGAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController = __tabBarController;
@synthesize splitViewController = _splitViewController;
@synthesize facebook = _facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [ABNotifier startNotifierWithAPIKey:@"YOUR_KEY"
                      environmentName:ABNotifierAutomaticEnvironment
                               useSSL:YES
                             delegate:nil];
  
  // Setup API base stuff
  [WFInstagramAPI setClientId:OAUTH_INSTAGRAM_KEY];
  [WFInstagramAPI setOAuthRedirctURL:OAUTH_INSTAGRAM_REDIRECT_URL];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [WFInstagramAPI setAccessToken:[defaults stringForKey:kDefaultsInstagramToken]];
  [WFInstagramAPI setGlobalErrorHandler:^(WFIGResponse* response) {
    void (^logicBlock)(WFIGResponse*) = ^(WFIGResponse *response){
      switch ([response error].code) {
        case WFIGErrorOAuthException:
          [WFInstagramAPI enterAuthFlow];
          break;
        default: {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[[response error] localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
          [alert show];
        } break;
      }
    };
    // needs to be run on main thread because of UI changes. So we decide where to run & then run it.
    if ([NSThread isMainThread]) {
      logicBlock(response);
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        logicBlock(response);
      });
    }
  }];
  [WFIGAuthController setInitialViewClass:[LolgramzAuthInitialView class]];
  
  // set up the UI
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.tabBarController = [[UITabBarController alloc] init];
    
    SelectInstagramMediaController *tabOneRoot = [[SelectInstagramMediaController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *tabOne = [[UINavigationController alloc] initWithRootViewController:tabOneRoot];
    tabOne.navigationBar.barStyle = UIBarStyleBlack;
    
    YourMemesController *tabTwoRoot = [[YourMemesController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *tabTwo = [[UINavigationController alloc] initWithRootViewController:tabTwoRoot];
    tabTwo.navigationBar.barStyle = UIBarStyleBlack;
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:tabOne, tabTwo, nil];
    
    self.window.rootViewController = self.tabBarController;
  } else {
//    iPad not currently supported!
//    SelectInstagramMediaController *masterViewController = [[SelectInstagramMediaController alloc] initWithNibName:@"MGMasterViewController_iPad" bundle:nil];
//    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
//    
//    MGDetailViewController *detailViewController = [[MGDetailViewController alloc] initWithNibName:@"MGDetailViewController_iPad" bundle:nil];
//    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
//
//    self.splitViewController = [[UISplitViewController alloc] init];
//    self.splitViewController.delegate = detailViewController;
//    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
//    
//    self.window.rootViewController = self.splitViewController;
//    masterViewController.detailViewController = detailViewController;
  }
  
  [self.window makeKeyAndVisible];
  
  [self ensureUserLoggedIn];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
  // restart the uploader (tell it to attempt another upload)
  [MGUploader attemptUpload];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([kAuthCallbackURL isEqual:[url host]]) {
    NSDictionary *params = [url queryDictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[params objectForKey:kAuthCallbackURLApiTokenParam] forKey:kDefaultsMemegramToken];
    [defaults setObject:[params objectForKey:kAuthCallbackURLInstagramTokenParam] forKey:kDefaultsInstagramToken];
    [defaults synchronize];
    [WFInstagramAPI setAccessToken:[params objectForKey:kAuthCallbackURLInstagramTokenParam]];
    //TODO handle failure here (params not present, etc. passed error codes?)
    
    // dismiss our auth controller, get back to the regular application
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow resignKeyWindow];
    keyWindow.hidden = YES;
    [WFInstagramAPI setAuthWindow:nil];
    [self.window makeKeyAndVisible];
    
    return YES;
  } else if ([@"fb" isEqual:[url.scheme substringToIndex:2]]) {
    return [self.facebook handleOpenURL:url];
  }
  return NO;
}

- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil)
  {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
      DLOG(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
  }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Memegram" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Memegram.sqlite"];
  
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
#ifdef DEBUG
      // quick fix (for dev) - attempt a delete and try again
      // potential infinite loop if things are really messed up
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      __persistentStoreCoordinator = nil;
      [self persistentStoreCoordinator];
#else
      // there was an issue we failed to address
#endif
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCachesDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - other properties

- (Facebook*) facebook {
  if (!_facebook) {
    _facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kDefaultsFacebookToken]) {
      _facebook.accessToken = [defaults objectForKey:kDefaultsFacebookToken];
      _facebook.expirationDate = [defaults objectForKey:kDefaultsFacebookExpiration];
    }
  }
  return _facebook;
}

@end


#pragma mark -
@implementation MGAppDelegate (FBSessionDelegate)

- (void)fbDidLogin {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[self.facebook accessToken] forKey:kDefaultsFacebookToken];
  [defaults setObject:[self.facebook expirationDate] forKey:kDefaultsFacebookExpiration];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookDidLoginNotification object:self];
}

@end


#pragma mark -
@implementation MGAppDelegate (Private)

// both the memegram & instagram keys must be valid & present
- (void) ensureUserLoggedIn {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSString *memegramToken = [defaults stringForKey:kDefaultsMemegramToken];
  
  if (!memegramToken) {
    // we must have 2 tokens, so make sure that instagram clears if we don't have a memegram one
    [WFInstagramAPI setAccessToken:nil];
  }
}

@end
