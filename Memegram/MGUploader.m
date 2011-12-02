//
//  MGUploader.m
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGUploader.h"
#import "MGAppDelegate.h"
#import "MGConstants.h"
#import "Meme.h"

@implementation MGUploader

static Meme *g_currentUpload = nil;

+ (void) initialize {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

+ (void) _managedObjectContextDidSave:(NSNotification*)notification {
  [self attemptUpload];
}

+ (Meme*) currentUpload {
  @synchronized(self) {
    return g_currentUpload;
  }
}

+ (void) setCurrentUpload:(Meme*)upload; {
  @synchronized(self) {
    g_currentUpload = upload;
  }
}

+ (void) attemptUpload {
  if ([self currentUpload]) {
    DLOG(@"tried to attempt an upload, but we're already uploading %@", [self currentUpload]);
    return;
  }
  
  MGAppDelegate *appDelegate = (MGAppDelegate*)[UIApplication sharedApplication].delegate;
  NSManagedObjectContext *ctx = appDelegate.managedObjectContext;
  NSFetchRequest *request = [appDelegate.managedObjectModel fetchRequestTemplateForName:kUnuploadedMemesFetchRequest];
  NSError *err = nil;
  NSArray *results = [ctx executeFetchRequest:request error:&err];
  if (results && [results count] > 0) {
    __block Meme *nextUpload =[results objectAtIndex:0];
    DLOG(@"will attempt to upload %@", nextUpload);
    
    // mark this as a current upload so other uploads won't start
    [self setCurrentUpload:nextUpload];
    
    // notify the system we're starting a background task
    __block UIBackgroundTaskIdentifier uploadTask = UIBackgroundTaskInvalid;
    uploadTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
      dispatch_async(dispatch_get_main_queue(), ^{
        if (UIBackgroundTaskInvalid != uploadTask) {
          // do any needed cleanup here...
          [[UIApplication sharedApplication] endBackgroundTask:uploadTask];
          uploadTask = UIBackgroundTaskInvalid;
        }
      });
    }];
    
    //TODO - should this be a higher priority QUEUE? DEFAULT?
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
      __block NSError *err = nil;
      if (![nextUpload uploadError:&err]) {
        DLOG(@"UPLOAD OF %@ FAILED: %@", nextUpload, err);
        //TODO: possibly manually trigger trying again. but maybe delay to not hit network too hard?
      } else {
        DLOG(@"upload of %@ succeeded!", nextUpload);
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self setCurrentUpload:nil]; // clear the current upload so the next one can start
        
        // cleanup the task ID on the main thread to prevent race with expiration handler
        if (UIBackgroundTaskInvalid != uploadTask) {
          [[UIApplication sharedApplication] endBackgroundTask:uploadTask];
          uploadTask = UIBackgroundTaskInvalid;
        }
        
        [appDelegate saveContext]; // save the uploaded object & trigger the next upload attempt
        
        // we schedule a manual attempt to upload if there was an error because save generally will do nothing
        if (err) {
          // wait a while so we're not churning too much
          [NSTimer scheduledTimerWithTimeInterval:60.0
                                           target:[MGUploader class]
                                         selector:@selector(attemptUpload)
                                         userInfo:nil repeats:NO];
        }
      });
    });
  } else {
    DLOG(@"no objects waiting to be uploaded");
  }
}

@end
