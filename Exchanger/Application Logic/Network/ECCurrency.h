//
//  ECCurrency.h
//  Exchanger
//
//  Created by Alex Goncharov on 11/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@interface ECCurrency : NSObject

@property (nonatomic, strong) NSString *currencyId;
@property (nonatomic, strong) NSNumber *exchangeRate;

- (instancetype)initWithCurrencyId:(NSString *)currencyId
                      exchangeRate:(NSNumber *)exchangeRate;

@end
