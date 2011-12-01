//
//  FinishMemegramController.m
//  Memegram
//
//  Created by William Fleming on 11/17/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "FinishMemegramController.h"

#import "Memegram.h"
#import "UITextViewTableCell.h"
#import "UISwitchTableCell.h"
#import "MGConstants.h"
#import "MGAccountHelper.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "MGAppDelegate.h"

#pragma mark -
@interface FinishMemegramController (Actions)
- (void) cancel;
- (void) done;
@end

@interface FinishMemegramController (Private)
- (void) facebookDidLogin;
@end


#pragma mark -
@implementation FinishMemegramController

@synthesize memegram;

- (id) init {
  return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      self.title = NSLocalizedString(@"Finish", @"Finish");
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookDidLogin) name:kFacebookDidLoginNotification object:nil];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (0 == section) {
    return 1;
  } else if (1 == section) {
    return 2;  // add more later!
  }
  
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (0 == section) {
    return @"Caption";
  } else if (1 == section) {
    return @"Sharing";
  }
  
  return nil;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (0 == indexPath.section) {
    // this is a crappy separation of concerns. this is the font size we use in the table view cell,
    // and we need to know the padding as well
    UIFont *font = [UIFont systemFontOfSize:14.0];
    return (font.lineHeight * 2.0) + 20.0;
  }
  return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell;
  
  if (0 == indexPath.section) {
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITextViewTableCell class])];
    if (!cell) {
      cell = [[UITextViewTableCell alloc] init];
    }
    ((UITextViewTableCell*)cell).textView.text = self.memegram.caption;
    ((UITextViewTableCell*)cell).changeBlock = ^(UITextView *textView) {
      self.memegram.caption = textView.text;
    };
  } else if (1 == indexPath.section) {
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UISwitchTableCell class])];
    if (!cell) {
      cell = [[UISwitchTableCell alloc] init];
    }
    DLOG(@"cell at row %x is %@", indexPath.row, cell);
    if (0 == indexPath.row) { // twitter
      cell.textLabel.text = @"Share on Twitter";
      if (![TWTweetComposeViewController canSendTweet]) {
        ((UISwitchTableCell*)cell).uiswitch.enabled = NO;
      }
      ((UISwitchTableCell*)cell).uiswitch.on = [self.memegram.shareToTwitter boolValue];
      __block Memegram *blockMemegram = self.memegram;
      __block UITableView *blockTableView = self.tableView;
      ((UISwitchTableCell*)cell).changeBlock = ^(UISwitch *uiswitch){
        BOOL returnValue = YES;
        
        if (uiswitch.on) {
          ACAccount *defaultAcct = [MGAccountHelper defaultTwitterAccount];
          
          if (!defaultAcct) {
            returnValue = NO; // presume we fail until we get access
            
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            /* this returns immediately, so we manually change the switch to
             * on after finishing getting access (if we do) */
            [accountStore requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
              // Did user allow us access?
              if (granted == YES) {
                // Populate array with all available Twitter accounts
                NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
                
                if (0 == [accounts count]) { // should not happen
                  return; // switch is already off, no need to do anything
                } else if (1 == [accounts count]) {
                  ACAccount *acct = [accounts objectAtIndex:0];
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  [defaults setObject:[acct identifier] forKey:kDefaultsTwitterAccountIdentifier];
                  blockMemegram.shareToTwitter = [NSNumber numberWithBool:YES];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    [blockTableView reloadData];
                  });
                } else { // ask user to select an account
//                    TODO: prompt user
                  ACAccount *acct = [accounts objectAtIndex:0];
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  [defaults setObject:[acct identifier] forKey:kDefaultsTwitterAccountIdentifier];
                  blockMemegram.shareToTwitter = [NSNumber numberWithBool:YES];
                  dispatch_async(dispatch_get_main_queue(), ^{
                    [blockTableView reloadData];
                  });
                }
              }
            }];
          } // if no default account is found
        } // if switch is on
        
        if (returnValue) {
          self.memegram.shareToTwitter = [NSNumber numberWithBool:uiswitch.on];
        }
          
        return returnValue;
      };
    } else if (1 == indexPath.row) { // Facebook
      cell.textLabel.text = @"Share on Facebook";
      ((UISwitchTableCell*)cell).uiswitch.on = [self.memegram.shareToFacebook boolValue];
      ((UISwitchTableCell*)cell).changeBlock = ^(UISwitch *uiswitch){
        MGAppDelegate *appDelegate = (MGAppDelegate*)[UIApplication sharedApplication].delegate;
        Facebook *fb = appDelegate.facebook;
        
        if (uiswitch.on && ![fb isSessionValid]) {
          [fb authorize:[NSArray arrayWithObjects:@"publish_stream", @"offline_access", nil]];
          return NO;
        }
        
        self.memegram.shareToFacebook = [NSNumber numberWithBool:uiswitch.on];
        return YES;
      };
    } else if (2 == indexPath.row) { // Tumblr
      //TODO
      cell.textLabel.text = @"Share on Tumblr (TODO)";
      ((UISwitchTableCell*)cell).uiswitch.on = [self.memegram.shareToTumblr boolValue];
    }
  }    
    // Configure the cell...
    
    return cell;
}



#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

@end


#pragma mark -
@implementation FinishMemegramController (Actions)
- (void) cancel {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) done {
  MGAppDelegate *appDelegate = (MGAppDelegate*)[UIApplication sharedApplication].delegate;
  NSManagedObjectContext *ctx = appDelegate.managedObjectContext;
  [ctx insertObject:self.memegram];
  [appDelegate saveContext]; // this triggers upload
  
  // switch to show your memegrams
  UITabBarController *tabBarController = appDelegate.tabBarController;
  tabBarController.selectedIndex = 1;
  
  // pop this controller back to root
  [self.navigationController popToRootViewControllerAnimated:NO];
}
@end


@implementation FinishMemegramController (Private)
- (void) facebookDidLogin {
  // this happening implies the user wanted to share on fb & had to login
  self.memegram.shareToFacebook = [NSNumber numberWithBool:YES];
  [self.tableView reloadData];
}
@end

