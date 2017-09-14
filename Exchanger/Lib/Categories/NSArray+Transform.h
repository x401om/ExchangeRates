//
//  NSArray+Transform.h
//  Exchanger
//
//  Created by Alex Goncharov on 10/09/2017.
//  Copyright © 2017 Alex Goncharov. All rights reserved.
//

@import Foundation;

@interface NSArray<ObjectType> (Map)

- (NSArray *)map:(id (^)(ObjectType object))block;

@end

@interface NSArray<ObjectType> (Filtered)

- (NSArray<ObjectType> *)filtered:(BOOL (^)(ObjectType evaluatedObject, NSDictionary *bindings))block;

@end
