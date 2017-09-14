//
//  ECExchangePresenter.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Bolts;

#import "ECBinding.h"
#import "NSArray+Transform.h"

#import "ECCurrency.h"
#import "ECAccount.h"
#import "ECExchangeCalculator.h"

#import "ECExchangeInteractor.h"
#import "ECExchangePresenter.h"

static NSArray *currencies;

@interface ECExchangePresenter ()

@property (nonatomic, assign) NSUInteger firstCurrencyIndex;
@property (nonatomic, strong) NSString *firstCurrencyId;
@property (nonatomic, strong) NSString *firstCurrencyAmount;
@property (nonatomic, strong) NSNumber *firstCurrencyValue;
@property (nonatomic, strong) ECCurrency *firstCurrency;

@property (nonatomic, assign) NSUInteger secondCurrencyIndex;
@property (nonatomic, strong) NSString *secondCurrencyId;
@property (nonatomic, strong) NSString *secondCurrencyAmount;
@property (nonatomic, strong) NSNumber *secondCurrencyValue;
@property (nonatomic, strong) ECCurrency *secondCurrency;

@property (nonatomic, strong) NSArray<NSString *> *currenciesIds;

@property (nonatomic, strong) ECExchangeInteractor *interactor;

@end

@implementation ECExchangePresenter

- (ECExchangeInteractor *)interactor {
  if (!_interactor) {
    _interactor = [ECExchangeInteractor new];
  }
  return _interactor;
}

- (void)setFirstCurrency:(ECCurrency *)firstCurrency {
  _firstCurrency = firstCurrency;
 
  self.firstCurrencyId = firstCurrency.currencyId;
  self.firstCurrencyIndex = [self currencyIndexWithCurrencyId:firstCurrency.currencyId];
}

- (void)setSecondCurrency:(ECCurrency *)secondCurrency {
  _secondCurrency = secondCurrency;
  
  self.secondCurrencyId = secondCurrency.currencyId;
  self.secondCurrencyIndex = [self currencyIndexWithCurrencyId:secondCurrency.currencyId];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    __weak typeof(self) weakSelf = self;
    [self bindObject:self.interactor property:@"currentRates" withBlock:^(id value) {
      [weakSelf updateRates:value];
    }];
  }
  return self;
}

- (void)updateRates:(NSArray<ECCurrency *> *)rates {
  if (rates == nil) {
    return;
  }
  
  self.currenciesIds = [rates map:^id(ECCurrency *object) {
    return object.currencyId;
  }];
}

- (void)updateAccounts:(NSArray<ECAccount *> *)accounts {
  ECAccount *firstAcc = [self accountWithId:self.firstCurrencyId];
  self.firstCurrencyAmount = [NSString stringWithFormat:@"%@%.2f", [self currencySignWithId:firstAcc.currencyId], firstAcc.amount.doubleValue];
  ECAccount *secondAcc = [self accountWithId:self.secondCurrencyId];
  self.secondCurrencyAmount = [NSString stringWithFormat:@"%@%.2f", [self currencySignWithId:secondAcc.currencyId], secondAcc.amount.doubleValue];
}

- (void)updateFirstCurrencyIndex:(NSUInteger)idx {
  self.firstCurrency = [self currencyWithIndex:idx];
  if ([self.firstCurrencyId isEqualToString:self.secondCurrencyId]) {
    self.secondCurrency = [self currencyWithIndex:idx + 1];
  }
  [self updateAccounts:self.interactor.accounts];
  [self recalculateValues];
}
- (void)updateSecondCurrencyIndex:(NSUInteger)idx {
  self.secondCurrency = [self currencyWithIndex:idx];
  if ([self.firstCurrencyId isEqualToString:self.secondCurrencyId]) {
    self.firstCurrency = [self currencyWithIndex:idx + 1];
  }
  [self updateAccounts:self.interactor.accounts];
  [self recalculateValues];
}

- (void)updateFirstCurrencyValue:(NSString *)value {
  if (value.length == 0) {
    self.secondCurrencyValue = @0;
    return;
  }
  double number = value.doubleValue;
  self.firstCurrencyValue = @(number);
  number = [ECExchangeCalculator convertValue:number
                                         from:self.firstCurrency
                                           to:self.secondCurrency];
  self.secondCurrencyValue = @(number);
}

- (void)updateSecondCurrencyValue:(NSString *)value {
  if (value.length == 0) {
    self.firstCurrencyValue = @0;
    return;
  }
  double number = value.doubleValue;
  self.secondCurrencyValue = @(number);
  number = [ECExchangeCalculator convertValue:number
                                         from:self.secondCurrency
                                           to:self.firstCurrency];
  self.firstCurrencyValue = @(number);
}

- (void)recalculateValues {
  double number = [ECExchangeCalculator convertValue:self.firstCurrencyValue.doubleValue
                                                from:self.firstCurrency
                                                  to:self.secondCurrency];
  self.secondCurrencyValue = @(number);
}

- (BFTask *)exchangePressed {
  __weak typeof(self) weakSelf = self;
  BFTask *task = [self.interactor performTransactionFrom:self.firstCurrency
                                                      to:self.secondCurrency
                                              fromAmount:self.firstCurrencyValue.doubleValue
                                                toAmount:self.secondCurrencyValue.doubleValue];
  return [task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
    [weakSelf updateAccounts:weakSelf.interactor.accounts];
    return t;
  }];
}

- (BFTask *)sync {
  __weak typeof(self) weakSelf = self;
  return [[BFTask taskForCompletionOfAllTasksWithResults:@[[self.interactor syncRates],
                                                           [self.interactor fetchAccounts]]] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
    [weakSelf updateFirstCurrencyIndex:0];
    [weakSelf updateSecondCurrencyIndex:1];
    [weakSelf updateAccounts:weakSelf.interactor.accounts];
    [weakSelf recalculateValues];
//    return [BFTask taskWithDelay:1500]; // Uncomment this line to slow down a bit this update
    return t;
  }];
}

#pragma mark - Helpers

- (ECCurrency *)currencyWithIndex:(NSUInteger)idx {
  return self.interactor.currentRates[idx % self.interactor.currentRates.count];
}

- (ECCurrency *)currencyWithId:(NSString *)currencyId {
  NSUInteger idx = [self currencyIndexWithCurrencyId:currencyId];
  if (idx == NSNotFound) {
    return nil;
  }
  return [self currencyWithIndex:idx];
}

- (NSUInteger)currencyIndexWithCurrencyId:(NSString *)currencyId {
  return [self.interactor.currentRates indexOfObjectPassingTest:^BOOL(ECCurrency * _Nonnull obj,
                                                                      NSUInteger idx,
                                                                      BOOL * _Nonnull stop) {
    return (*stop = ([obj.currencyId isEqualToString:currencyId]));
  }];
}

- (ECAccount *)accountWithIndex:(NSUInteger)idx {
  return self.interactor.accounts[idx % self.interactor.accounts.count];
}

- (ECAccount *)accountWithId:(NSString *)currencyId {
  NSUInteger idx = [self accountIndexWithCurrencyId:currencyId];
  if (idx == NSNotFound) {
    return nil;
  }
  return [self accountWithIndex:idx];
}

- (NSUInteger)accountIndexWithCurrencyId:(NSString *)currencyId {
  return [self.interactor.accounts indexOfObjectPassingTest:^BOOL(ECAccount * _Nonnull obj,
                                                                        NSUInteger idx,
                                                                        BOOL * _Nonnull stop) {
    return (*stop = ([obj.currencyId isEqualToString:currencyId]));
  }];
}

- (NSString *)currencySignWithId:(NSString *)currencyId {
  if ([currencyId isEqualToString:@"USD"]) {
    return @"$";
  } else if ([currencyId isEqualToString:@"EUR"]) {
    return @"€";
  } else if ([currencyId isEqualToString:@"GBP"]) {
    return @"£";
  }
  return nil;
}

@end
