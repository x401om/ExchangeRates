//
//  NSObject+Binding.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import KVOController;

#import "NSObject+Binding.h"
#import "FBKVOController+Binding.h"

NS_INLINE ECBlockChange blockChangeFrom(ECBlockFilter filterBlock, ECBlock observationBlock) {
  return ^(id oldValue, id newValue) {
    if (!filterBlock || filterBlock(newValue)) {
      observationBlock(newValue);
    }
  };
}

@implementation NSObject (Binding)

- (void)bindObject:(id)object
          property:(NSString *)propertyName
         withBlock:(ECBlock)observationBlock {
  
  [self bindObject:object
          property:propertyName
   withBlockChange:blockChangeFrom(nil, observationBlock)];
}

- (void)bindObject:(id)object
          property:(NSString *)propertyName
            filter:(ECBlockFilter)filterBlock
         withBlock:(ECBlock)observationBlock {
  
  [self bindObject:object
          property:propertyName
   withBlockChange:blockChangeFrom(filterBlock, observationBlock)];
}

- (void)bindObject:(id)object
          property:(NSString *)propertyName
   withBlockChange:(ECBlockChange)observationBlock {
  
  [self.KVOController observeObject:object
                       propertyName:propertyName
                          withBlock:observationBlock];
}

- (void)unbindObject:(id)object {
  [self.KVOController unobserve:object];
  [self.KVOControllerNonRetaining unobserve:object];
}

- (void)unbindAll {
  [self.KVOController unobserveAll];
  [self.KVOControllerNonRetaining unobserveAll];
}

@end
