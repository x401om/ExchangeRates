//
//  ECRatesService.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Bolts;
#import "XMLDictionary.h"
#import "NSArray+Transform.h"

#import "ECCurrency.h"
#import "ECRatesService.h"

static NSString *const RatesBaseUrl = @"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";

@interface ECRatesService ()

@property (nonatomic, strong) NSString *baseCurrencyId;
@property (nonatomic, strong) NSArray<ECCurrency *> *rates;

@end

@implementation ECRatesService

- (instancetype)initWithBaseCurrencyId:(NSString *)baseCurrencyId {
  self = [super init];
  if (self) {
    _baseCurrencyId = baseCurrencyId;
  }
  return self;
}

- (BFTask<NSData *> *)downloadRatesData {
  BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSURL *url = [NSURL URLWithString:RatesBaseUrl];
      NSError *error;
      NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
      if (error) {
        [source trySetError:error];
      } else {
        [source trySetResult:data];
      }
  });

  return source.task;
}

- (BFTask<NSArray<ECCurrency *> *> *)loadRates {
  __weak typeof(self) weakSelf = self;
  return [[[[self downloadRatesData] continueWithSuccessBlock:^id _Nullable(BFTask<NSData *> *_Nonnull t) {

      NSDictionary *dict = [NSDictionary dictionaryWithXMLData:t.result];
      if (dict) {
        return dict;
      } else {
        return [BFTask taskWithError:[NSError errorWithDomain:@"com.exchanger.rates" code:0 userInfo:nil]];
      }

  }] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> *_Nonnull t) {

      return [[t.result[@"Cube"][@"Cube"][@"Cube"] filtered:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {

          return ([evaluatedObject[@"_currency"] isEqualToString:@"USD"] ||
                  [evaluatedObject[@"_currency"] isEqualToString:@"GBP"]);

      }] map:^id(id object) {

          NSString *currencyId = object[@"_currency"];
          NSNumber *rate = @([object[@"_rate"] doubleValue]);
          return [[ECCurrency alloc] initWithCurrencyId:currencyId
                                           exchangeRate:rate];

      }];
  }] continueWithSuccessBlock:^id _Nullable(BFTask *_Nonnull t) {
      ECCurrency *baseCurrency = [[ECCurrency alloc] initWithCurrencyId:self.baseCurrencyId
                                                           exchangeRate:@1.0];
      weakSelf.rates = [t.result arrayByAddingObject:baseCurrency];
      NSLog(@"Rates updated: %@", weakSelf.rates);
      return weakSelf.rates;
  }];
}

@end
