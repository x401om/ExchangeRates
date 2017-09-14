//
//  ECExchangeCalculator.m
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

#import "ECCurrency.h"
#import "ECExchangeCalculator.h"

@implementation ECExchangeCalculator

+ (double)convertValue:(double)value
                  from:(ECCurrency *)fromCurrency
                    to:(ECCurrency *)toCurrency {
  if ([fromCurrency.currencyId isEqualToString:toCurrency.currencyId]) {
    return value;
  }

  return value * toCurrency.exchangeRate.doubleValue / fromCurrency.exchangeRate.doubleValue;
}

@end
