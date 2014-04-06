//
//  CGConnectionController.m
//  CGConnectionController
//
//  Created by Chase Gorectke on 3/31/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "CGConnectionController.h"

@interface CGConnectionController ()

@end

@implementation CGConnectionController

+ (instancetype)sharedConnection
{
    static dispatch_once_t once;
    static CGConnectionController *sharedConnection;
    dispatch_once(&once, ^{
        sharedConnection = [[self alloc] init];
    });
    return sharedConnection;
}

- (void)addSource:(NSString *)name withType:(CGConnectionType)type
{
    
}

@end
