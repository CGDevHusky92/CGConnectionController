//
//  CGConnectionController.h
//  CGConnectionController
//
//  Created by Chase Gorectke on 3/31/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGManagedObject.h"

typedef enum CGConnectionType
{
    kCGConnectionNone,
    kCGConnectionServer,
    kCGConnectionLibrary,
    kCGConnectionLocal
} CGConnectionType;

@interface CGConnectionController : NSObject

+ (instancetype)sharedConnection;

- (void)addSource:(NSString *)name withType:(CGConnectionType)type;

// public
//
// add server  (name, url, ssl, ...)
// add library (name, appId, appKey, ...)
// add local   (name, beacon_name)
//
// private
//
// specify connection of type
// specify connection of type and name
//
// retrieval methods
//
// ....

- (CGManagedObject *)getObjectWithId:(NSString *)objId forType:(NSString *)type;

//- (CGManagedObject *)retrieveObjectOnServer:(NSString *)objId;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className; // forUserKey:(NSString *)relKey;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderAscendingByKey:(NSString *)key;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderDescendingByKey:(NSString *)key;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderedByKey:(NSString *)key ascending:(BOOL)ascend;

@end
