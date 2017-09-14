//
//  ECExchangeInteractor.m
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Bolts;
#import "ECBinding.h"

#import "ECRatesService.h"
#import "ECStorageService.h"
#import "ECExchangeCalculator.h"

#import "ECCurrency.h"
#import "ECAccount.h"

#import "ECExchangeInteractor.h"

@interface ECExchangeInteractor ()

@property (nonatomic, strong) ECRatesService *ratesService;
@property (nonatomic, strong) ECStorageService *storageService;

@property (nonatomic, strong) NSArray<ECCurrency *> *currentRates;
@property (nonatomic, strong) NSArray<ECAccount *> *accounts;

@end

@implementation ECExchangeInteractor

- (instancetype)init {
  self = [super init];
  if (self) {
    _ratesService = [[ECRatesService alloc] initWithBaseCurrencyId:@"EUR"];
    _storageService = [ECStorageService new];
    [_storageService resetStorage];
    
    [self setupBindings];
  }
  return self;
}

- (void)setupBindings {
  __weak typeof(self) weakSelf = self;
  [self bindObject:self.ratesService property:@"rates" withBlock:^(NSArray *value) {
    weakSelf.currentRates = value;
  }];
  [self bindObject:self.storageService property:@"accounts" withBlock:^(id value) {
    weakSelf.accounts = value;
  }];
}

- (BFTask<NSArray<ECCurrency *> *> *)syncRates {
  return [self.ratesService loadRates];
}

- (BFTask<NSArray<ECAccount *> *> *)fetchAccounts {
  return [self.storageService fetchAccounts];
}

- (BFTask *)performTransactionFrom:(ECCurrency *)fromCurrency
                                to:(ECCurrency *)toCurrency
                        fromAmount:(double)fromAmount
                          toAmount:(double)toAmount {
  
  ECAccount *from = [self accountWithId:fromCurrency.currencyId];
  if (from.amount.doubleValue < fromAmount) {
    return [BFTask taskWithError:[NSError errorWithDomain:@"com.exchanger.storage" code:0 userInfo:nil]];
  }
  from.amount = @(from.amount.doubleValue - fromAmount);
  
  ECAccount *to = [self accountWithId:toCurrency.currencyId];
  to.amount = @(to.amount.doubleValue + toAmount);
  
  __weak typeof(self) weakSelf = self;
  return [[BFTask taskForCompletionOfAllTasksWithResults:@[[self.storageService updateAccount:from],
                                                           [self.storageService updateAccount:to]]] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
    return [weakSelf.storageService fetchAccounts];
  }];
}

- (ECAccount *)accountWithId:(NSString *)currencyId {
  for (ECAccount *acc in self.accounts) {
    if ([acc.currencyId isEqualToString:currencyId]) {
      return acc;
    }
  }
  return nil;
}

@end
