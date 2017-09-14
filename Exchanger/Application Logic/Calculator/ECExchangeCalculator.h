//
//  ECExchangeCalculator.h
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@class ECCurrency;

@interface ECExchangeCalculator : NSObject

+ (double)convertValue:(double)value
                  from:(ECCurrency *)fromCurrency
                    to:(ECCurrency *)toCurrency;

@end
