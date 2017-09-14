//
//  ECStorageService.h
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@class ECAccount;
@class BFTask<ResultType>;

@interface ECStorageService : NSObject

@property (nonatomic, readonly) NSArray<ECAccount *> *accounts;

- (BFTask<NSArray<ECAccount *> *> *)fetchAccounts;
- (BFTask *)updateAccount:(ECAccount *)account;
- (void)resetStorage;

@end
