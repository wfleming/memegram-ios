//
//  MGAccountHelper.m
//  Memegram
//
//  Created by William Fleming on 11/18/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGAccountHelper.h"
#import "MGConstants.h"

@implementation MGAccountHelper

/**
 * Why store this reference? Because things get crashy if we don't.
 * Apparently there's a strong relationship between ACAccountStore & ACAccount
 * instances - so when the store gets dealloced, so do the account instances.
 * Additionally, ARC doesn't seem to realize it needs to retain & then autorelease
 * the account instance. End result? EXC_BAD_ACCESS all up in this motha.
 * 
 * Solution? Global account store intstance.
 */
static ACAccountStore *acctStore;

+ (ACAccountStore*)accountStore {
  if(!acctStore) {
    @synchronized(self) {
      acctStore = [[ACAccountStore alloc] init];
    }
  }
  return acctStore;
}

+ (ACAccount*) defaultTwitterAccount {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *acctId = [defaults objectForKey:kDefaultsTwitterAccountIdentifier];
  ACAccount *acct = nil;
  
  DLOG(@"the default acctId is %@", acctId);
  
  if (acctId) {
    // acctStore -accountWithIdentifier does not seem to be reliable, and can return junk...
    ACAccountStore *acctStore = [self accountStore];
    ACAccountType *twitterAccountType = [acctStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *allAccounts = [acctStore accountsWithAccountType:twitterAccountType];
    
    for (ACAccount *tmpAcct in allAccounts) {
      // no, i have no idea why i have to do this for string equality to work correctly
      NSString *tmpId = [NSString stringWithString:[tmpAcct identifier]];
      if ([acctId isEqualToString:tmpId]) {
        acct = tmpAcct;
      }
    }
  }
  
  return acct;
}

@end
