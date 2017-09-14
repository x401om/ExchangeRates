//
//  ECExchangeInteractor.h
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@class BFTask<ResultType>;
@class ECCurrency;
@class ECAccount;

@interface ECExchangeInteractor : NSObject

@property (nonatomic, readonly) NSArray<ECCurrency *> *currentRates;
@property (nonatomic, readonly) NSArray<ECAccount *> *accounts;

- (BFTask<NSArray<ECCurrency *> *> *)syncRates;
- (BFTask<NSArray<ECAccount *> *> *)fetchAccounts;

- (BFTask *)performTransactionFrom:(ECCurrency *)fromCurrency
                                to:(ECCurrency *)toCurrency
                        fromAmount:(double)fromAmount
                          toAmount:(double)toAmount;

@end
