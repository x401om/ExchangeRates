//
//  ECStorageService.m
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Bolts;

#import "NSArray+Transform.h"

#import "ECAccount.h"
#import "ECStorageService.h"

@interface ECStorageService ()

@property (nonatomic, strong) NSArray<ECAccount *> *accounts;

@end

@implementation ECStorageService

- (BFTask<NSArray<ECAccount *> *> *)fetchAccounts {
  NSDictionary *storage = [[NSUserDefaults standardUserDefaults] objectForKey:@"Storage"];
  
  NSArray *accounts = [storage.allKeys map:^id(id object) {
    ECAccount *acc = [ECAccount new];
    acc.currencyId = object;
    acc.amount = storage[object];
    return acc;
  }];
  
  self.accounts = accounts;
  return [BFTask taskWithResult:accounts];
}

- (BFTask *)updateAccount:(ECAccount *)account {
  NSMutableDictionary *storage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Storage"] mutableCopy];

  storage[account.currencyId] = account.amount;
  [[NSUserDefaults standardUserDefaults] setObject:storage forKey:@"Storage"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  for (ECAccount *acc in self.accounts) {
    if ([acc.currencyId isEqualToString:account.currencyId]) {
      acc.amount = account.amount;
    }
  }
  
  return [BFTask taskWithResult:@YES];
}

- (void)resetStorage {
  NSDictionary *storage = @{@"EUR" : @100,
                            @"USD" : @100,
                            @"GBP" : @100};
  [[NSUserDefaults standardUserDefaults] setObject:storage forKey:@"Storage"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
