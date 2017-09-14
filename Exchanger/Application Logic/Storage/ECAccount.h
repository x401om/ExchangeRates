//
//  ECAccount.h
//  Exchanger
//
//  Created by Alex Goncharov on 12/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@interface ECAccount : NSObject

@property (nonatomic, strong) NSString *currencyId;
@property (nonatomic, strong) NSNumber *amount;

@end
