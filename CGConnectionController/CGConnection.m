//
//  CGConnection.m
//  CGConnectionController
//
//  Created by Chase Gorectke on 4/15/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "CGConnection.h"

@implementation CGConnection

- (CGManagedObject *)retrieveObjectWithId:(NSString *)objId
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderAscendingByKey:(NSString *)key
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderDescendingByKey:(NSString *)key
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderedByKey:(NSString *)key ascending:(BOOL)ascend
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)] userInfo:nil];
}

@end
