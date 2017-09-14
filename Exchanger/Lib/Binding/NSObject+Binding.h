//
//  NSObject+Binding.h
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

typedef void (^ECBlock)(id value);
typedef BOOL (^ECBlockFilter)(id value);
typedef void (^ECBlockChange)(id oldValue, id newValue);

@interface NSObject (Binding)

- (void)bindObject:(id)object
          property:(NSString *)propertyName
         withBlock:(ECBlock)block;

- (void)bindObject:(id)object
          property:(NSString *)propertyName
   withBlockChange:(ECBlockChange)block;

- (void)bindObject:(id)object
          property:(NSString *)propertyName
            filter:(ECBlockFilter)filter
         withBlock:(ECBlock)block;

- (void)unbindObject:(id)object;

- (void)unbindAll;

@end
