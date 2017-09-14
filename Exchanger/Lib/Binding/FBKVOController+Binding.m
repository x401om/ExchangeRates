//
//  FBKVOController+Binding.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

#import "FBKVOController+Binding.h"

@implementation FBKVOController (Binding)

- (void)observeObject:(id)object
         propertyName:(NSString *)propertyName
            withBlock:(ECBlockChange)observationBlock;{
  
  [self observe:object keyPath:propertyName
        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
          block:^(id target, id obj, NSDictionary *change) {

            BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
            NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];

            id old = [change objectForKey:NSKeyValueChangeOldKey];
            id new = [ change objectForKey : NSKeyValueChangeNewKey ];


            if (old == new || (old && [old isEqual:new])) return;

            if (old == [NSNull null]) old = nil;
            if (new == [NSNull null]) new = nil;

            if (!isPrior) {

              switch (changeKind) {
                case NSKeyValueChangeSetting:
                  observationBlock(old, new);
                  break;
                case NSKeyValueChangeInsertion:
                  break;
                case NSKeyValueChangeRemoval:
                  break;
                case NSKeyValueChangeReplacement:
                  break;
              }
            }
            
          }];
}

@end
