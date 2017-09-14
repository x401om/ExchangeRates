//
//  ECRatesService.h
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@class BFTask<ResultType>;
@class ECCurrency;

@interface ECRatesService : NSObject

@property (nonatomic, readonly) NSArray<ECCurrency *> *rates;

- (instancetype)initWithBaseCurrencyId:(NSString *)baseCurrencyId;

- (BFTask<NSArray<ECCurrency *> *> *)loadRates;

@end
