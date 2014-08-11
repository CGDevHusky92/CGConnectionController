//
//  CGConnection.h
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CGConnection;

typedef struct CGAuthDelegateCalls {
    unsigned int didConnectWithUserInfo;
    unsigned int didFailToConnectWithError;
    unsigned int didFailToAuthenticateWithError;
} CGAuthDelegateCalls;

typedef struct CGDataDelegateCalls {
    unsigned int didSyncObject;
    unsigned int didFailToSyncObjectWithError;
    
    unsigned int didDeleteObject;
    unsigned int didFailToDeleteObjectWithError;
    
    unsigned int didReceiveObject;
    unsigned int didFailToReceiveObjectWithError;
    
    unsigned int didReceiveObjects;
    unsigned int didFailToReceiveObjectsWithError;
    
    unsigned int didReceiveStatusForType;
    unsigned int didFailToReceiveStatusForTypeWithError;
    
    unsigned int didReceiveCountForObject;
    unsigned int didFailToReceiveCountForObjectWithError;
} CGDataDelegateCalls;

@protocol CGConnectionAuthDelegate <NSObject>

@optional

#pragma mark - CGConnection Auth Protocol

- (void)connection:(CGConnection *)connection didConnectWithUserInfo:(NSDictionary *)userInfo;
- (void)connection:(CGConnection *)connection didFailToConnectWithError:(NSError *)error;
- (void)connection:(CGConnection *)connection didFailToAuthenticateWithError:(NSError *)error;

@end

@protocol CGConnectionDataDelegate <NSObject>

@optional

#pragma mark - CGConnection Sync Protocol

- (void)connection:(CGConnection *)connection didSyncObjectWithId:(NSString *)objectId;
- (void)connection:(CGConnection *)connection didFailToSyncObjectWithId:(NSString *)objectId withError:(NSError *)error;

#pragma mark - CGConnection Delete Protocol

- (void)connection:(CGConnection *)connection didDeleteObjectWithId:(NSString *)objectId;
- (void)connection:(CGConnection *)connection didFailToDeleteObjectWithId:(NSString *)objectId withError:(NSError *)error;

#pragma mark - CGConnection Retrieve Object Protocol

- (void)connection:(CGConnection *)connection didReceiveObject:(NSDictionary *)object;
- (void)connection:(CGConnection *)connection didFailToReceiveObjectWithId:(NSString *)objectId withError:(NSError *)error;

#pragma mark - CGConnection Retrieve Objects Protocol

- (void)connection:(CGConnection *)connection didReceiveObjects:(NSArray *)objects;
- (void)connection:(CGConnection *)connection didFailToReceiveObjectsWithError:(NSError *)error;

#pragma mark - CGConnection Status Protocol

- (void)connection:(CGConnection *)connection didReceiveStatusForType:(NSDictionary *)status;
- (void)connection:(CGConnection *)connection didFailToReceiveStatusForType:(NSString *)type withError:(NSError *)error;

#pragma mark - CGConnection Count Protocol

- (void)connection:(CGConnection *)connection didReceiveCount:(NSUInteger)count forObjectType:(NSString *)type;
- (void)connection:(CGConnection *)connection didFailToReceiveCountForObjectType:(NSString *)type withError:(NSError *)error;

@end

@interface CGConnection : NSObject <CGConnectionAuthDelegate, CGConnectionDataDelegate>

@property (weak, nonatomic) id<CGConnectionAuthDelegate> authDelegate;
@property (weak, nonatomic) id<CGConnectionDataDelegate> dataDelegate;

@property (assign, nonatomic) CGAuthDelegateCalls authDelegateRespondsTo;
@property (assign, nonatomic) CGDataDelegateCalls dataDelegateRespondsTo;

/* Sync Object */
- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId;
- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion;

/* Delete Object */
- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId;
- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion;

/* Request Object */
- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId;
- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId andCompletion:(void(^)(NSDictionary * retObject, NSError * error))completion;

/* Request Objects */
- (void)requestObjectsWithType:(NSString *)type;
- (void)requestObjectsWithType:(NSString *)type andLimit:(NSUInteger)num;
- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date;

- (void)requestObjectsWithType:(NSString *)type andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion;
- (void)requestObjectsWithType:(NSString *)type limit:(NSUInteger)num andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion;
- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion;

/* Status of Objects */
- (void)requestStatusOfObjectsWithType:(NSString *)type;
- (void)requestStatusOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSDictionary * statusDic, NSError * error))completion;

/* Count of Objects */
- (void)requestCountOfObjectsWithType:(NSString *)type;
- (void)requestCountOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSUInteger count, NSError * error))completion;

@end
