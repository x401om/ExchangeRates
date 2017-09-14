//
//  ECExchangePresenter.h
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class BFTask;

@interface ECExchangePresenter : NSObject

@property (nonatomic, readonly) NSUInteger firstCurrencyIndex;
@property (nonatomic, readonly) NSString *firstCurrencyId;
@property (nonatomic, readonly) NSString *firstCurrencyAmount;
@property (nonatomic, readonly) NSNumber *firstCurrencyValue;

@property (nonatomic, readonly) NSUInteger secondCurrencyIndex;
@property (nonatomic, readonly) NSString *secondCurrencyId;
@property (nonatomic, readonly) NSString *secondCurrencyAmount;
@property (nonatomic, readonly) NSNumber *secondCurrencyValue;

@property (nonatomic, readonly) NSArray<NSString *> *currenciesIds;

- (BFTask *)exchangePressed;
- (BFTask *)sync;

- (void)updateFirstCurrencyIndex:(NSUInteger)firstCurrencyIndex;
- (void)updateSecondCurrencyIndex:(NSUInteger)secondCurrencyIndex;

- (void)updateFirstCurrencyValue:(NSString *)value;
- (void)updateSecondCurrencyValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
