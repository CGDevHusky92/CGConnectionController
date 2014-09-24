//
//  CGConnection.m
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import "CGConnection.h"



@interface CGConnection ()

@end

@implementation CGConnection
@synthesize authDelegate=_authDelegate;
@synthesize dataDelegate=_dataDelegate;
@synthesize authDelegateRespondsTo;
@synthesize dataDelegateRespondsTo;

- (void)setAuthDelegate:(id<CGConnectionAuthDelegate>)authDelegate
{
    _authDelegate = authDelegate;
    authDelegateRespondsTo.didConnectWithUserInfo = [authDelegate respondsToSelector:@selector(connection:didConnectWithUserInfo:)];
    authDelegateRespondsTo.didConnectWithUsername = [authDelegate respondsToSelector:@selector(connection:didConnectWithUsername:)];
    authDelegateRespondsTo.didFailToConnectWithError = [authDelegate respondsToSelector:@selector(connection:didFailToConnectWithError:)];
    authDelegateRespondsTo.didFailToAuthenticateWithError = [authDelegate respondsToSelector:@selector(connection:didFailToAuthenticateWithError:)];
}

- (void)setDataDelegate:(id<CGConnectionDataDelegate>)dataDelegate
{
    _dataDelegate = dataDelegate;
    dataDelegateRespondsTo.didSyncObject = [dataDelegate respondsToSelector:@selector(connection:didSyncObjectWithId:)];
    dataDelegateRespondsTo.didFailToSyncObjectWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToSyncObjectWithId:withError:)];
    dataDelegateRespondsTo.didDeleteObject = [dataDelegate respondsToSelector:@selector(connection:didDeleteObjectWithId:)];
    dataDelegateRespondsTo.didFailToDeleteObjectWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToDeleteObjectWithId:withError:)];
    dataDelegateRespondsTo.didReceiveObject = [dataDelegate respondsToSelector:@selector(connection:didReceiveObject:)];
    dataDelegateRespondsTo.didFailToReceiveObjectWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToReceiveObjectWithId:withError:)];
    dataDelegateRespondsTo.didReceiveObjects = [dataDelegate respondsToSelector:@selector(connection:didReceiveObjects:)];
    dataDelegateRespondsTo.didFailToReceiveObjectsWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToReceiveObjectsWithError:)];
    dataDelegateRespondsTo.didReceiveStatusForType = [dataDelegate respondsToSelector:@selector(connection:didReceiveStatusForType:)];
    dataDelegateRespondsTo.didFailToReceiveStatusForTypeWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToReceiveStatusForType:withError:)];
    dataDelegateRespondsTo.didReceiveCountForObject = [dataDelegate respondsToSelector:@selector(connection:didReceiveCount:forObjectType:)];
    dataDelegateRespondsTo.didFailToReceiveCountForObjectWithError = [dataDelegate respondsToSelector:@selector(connection:didFailToReceiveCountForObjectType:withError:)];
}

#pragma mark - CGConnection Protocol Based Methods

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type andLimit:(NSUInteger)num
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestCountOfObjectsWithType:(NSString *)type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

#pragma mark - CGConnection Completion Based Methods

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId andCompletion:(void(^)(NSDictionary * retObject, NSError * error))completion;
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type limit:(NSUInteger)num andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSDictionary * statusDic, NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)requestCountOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSUInteger count, NSError * error))completion
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

#pragma mark - CGAuthConnection Protocol

- (void)connection:(CGConnection *)connection didConnectWithUserInfo:(NSDictionary *)userInfo
{
    if (self.authDelegateRespondsTo.didConnectWithUserInfo)
        [self.authDelegate connection:connection didConnectWithUserInfo:userInfo];
}

- (void)connection:(CGConnection *)connection didConnectWithUsername:(NSString *)username
{
    if (self.authDelegateRespondsTo.didConnectWithUsername)
        [self.authDelegate connection:connection didConnectWithUsername:username];
}

- (void)connection:(CGConnection *)connection didFailToConnectWithError:(NSError *)error
{
    if (self.authDelegateRespondsTo.didFailToConnectWithError)
        [self.authDelegate connection:connection didFailToConnectWithError:error];
}

- (void)connection:(CGConnection *)connection didFailToAuthenticateWithError:(NSError *)error
{
    if (self.authDelegateRespondsTo.didFailToAuthenticateWithError)
        [self.authDelegate connection:connection didFailToAuthenticateWithError:error];
}

#pragma mark - CGDataConnection Protocol

- (void)connection:(CGConnection *)connection didSyncObjectWithId:(NSString *)objectId
{
    if (self.dataDelegateRespondsTo.didSyncObject)
        [self.dataDelegate connection:connection didSyncObjectWithId:objectId];
}

- (void)connection:(CGConnection *)connection didFailToSyncObjectWithId:(NSString *)objectId withError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToSyncObjectWithError)
        [self.dataDelegate connection:connection didFailToSyncObjectWithId:objectId withError:error];
}

- (void)connection:(CGConnection *)connection didDeleteObjectWithId:(NSString *)objectId
{
    if (self.dataDelegateRespondsTo.didDeleteObject)
        [self.dataDelegate connection:connection didSyncObjectWithId:objectId];
}

- (void)connection:(CGConnection *)connection didFailToDeleteObjectWithId:(NSString *)objectId withError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToDeleteObjectWithError)
        [self.dataDelegate connection:connection didFailToDeleteObjectWithId:objectId withError:error];
}

- (void)connection:(CGConnection *)connection didReceiveObject:(NSDictionary *)object
{
    if (self.dataDelegateRespondsTo.didReceiveObject)
        [self.dataDelegate connection:connection didReceiveObject:object];
}

- (void)connection:(CGConnection *)connection didFailToReceiveObjectWithId:(NSString *)objectId withError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToReceiveObjectWithError)
        [self.dataDelegate connection:connection didFailToReceiveObjectWithId:objectId withError:error];
}

- (void)connection:(CGConnection *)connection didReceiveObjects:(NSArray *)objects
{
    if (self.dataDelegateRespondsTo.didReceiveObjects)
        [self.dataDelegate connection:connection didReceiveObjects:objects];
}

- (void)connection:(CGConnection *)connection didFailToReceiveObjectsWithError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToReceiveObjectsWithError)
        [self.dataDelegate connection:connection didFailToReceiveObjectsWithError:error];
}

- (void)connection:(CGConnection *)connection didReceiveStatusForType:(NSDictionary *)status
{
    if (self.dataDelegateRespondsTo.didReceiveStatusForType)
        [self.dataDelegate connection:connection didReceiveStatusForType:status];
}

- (void)connection:(CGConnection *)connection didFailToReceiveStatusForObjectType:(NSString *)type withError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToReceiveStatusForTypeWithError)
        [self.dataDelegate connection:connection didFailToReceiveStatusForType:type withError:error];
}

- (void)connection:(CGConnection *)connection didReceiveCount:(NSUInteger)count forObjectType:(NSString *)type
{
    if (self.dataDelegateRespondsTo.didReceiveCountForObject)
        [self.dataDelegate connection:connection didReceiveCount:count forObjectType:type];
}

- (void)connection:(CGConnection *)connection didFailToReceiveCountForObjectType:(NSString *)type withError:(NSError *)error
{
    if (self.dataDelegateRespondsTo.didFailToReceiveCountForObjectWithError)
        [self.dataDelegate connection:connection didFailToReceiveCountForObjectType:type withError:error];
}

@end

