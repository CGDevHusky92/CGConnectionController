//
//  CGConnection.h
//  CGConnectionController
//
//  Created by Chase Gorectke on 4/15/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGManagedObject.h"

@interface CGConnection : NSObject


// get all objects (type)
// get all objects (type, limit)
// get all objects (type, limit, skip)
// get all objects (type, limit, skip, predicate, accessId)
// get all objects derivatives
// get object (type, id)
// update object (type, id)

- (CGManagedObject *)retrieveObjectWithId:(NSString *)objId;

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className; // forUserKey:(NSString *)relKey;


- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderAscendingByKey:(NSString *)key;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderDescendingByKey:(NSString *)key;
- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderedByKey:(NSString *)key ascending:(BOOL)ascend;

@end
