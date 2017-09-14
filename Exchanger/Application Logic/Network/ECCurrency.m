//
//  ECCurrency.m
//  Exchanger
//
//  Created by Alex Goncharov on 11/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

#import "ECCurrency.h"

@implementation ECCurrency

- (instancetype)initWithCurrencyId:(NSString *)currencyId
                      exchangeRate:(NSNumber *)exchangeRate {
  self = [super init];
  if (self) {
    _currencyId = currencyId;
    _exchangeRate = exchangeRate;
  }
  return self;
}

- (BOOL)isEqual:(ECCurrency *)object {
  return [self.currencyId isEqualToString:object.currencyId];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ = %@", _currencyId, _exchangeRate];
}

@end
