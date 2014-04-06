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
    kCGConnectionURL,
    kCGConnectionLibrary,
    kCGConnectionLocalSyncKey
} CGConnectionType;

@interface CGConnectionController : NSObject

+ (instancetype)sharedConnection;

- (void)addSource:(NSString *)name withType:(CGConnectionType)type;

@end
