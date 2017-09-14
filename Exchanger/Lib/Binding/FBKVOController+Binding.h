//
//  FBKVOController+Binding.h
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import KVOController;
#import "NSObject+Binding.h"

@interface FBKVOController (Binding)

- (void)observeObject:(id)object
         propertyName:(NSString *)propertyName
            withBlock:(ECBlockChange)observationBlock;

@end
