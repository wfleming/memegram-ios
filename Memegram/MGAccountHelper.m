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

+ (ACAccount*) defaultTwitterAccount {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *acctId = [defaults objectForKey:kDefaultsTwitterAccountIdentifier];
  ACAccount *acct = nil;
  if (acctId) {
    ACAccountStore *acctStore = [[ACAccountStore alloc] init];
    acct = [acctStore accountWithIdentifier:acctId];
  }
  return acct;
}

@end
