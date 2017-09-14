//
//  NSArray+Transform.m
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

#import "NSArray+Transform.h"

@implementation NSArray (Map)

- (NSArray *)map:(id (^)(id object))block {
  if (!self.count)
    return nil;
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
  for (id obj in self) {
    id mapped = block(obj);
    
    if (mapped) {
      [result addObject:mapped];
    }
  }
  return result;
}

@end

@implementation NSArray (Filtered)

- (NSArray *)filtered:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
  return [self filteredArrayUsingPredicate:predicate];
}

@end
