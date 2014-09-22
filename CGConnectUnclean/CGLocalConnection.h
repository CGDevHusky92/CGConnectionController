//
//  CGLocalConnection.h
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGConnection.h"

@interface CGLocalConnection : CGConnection

@property (strong, nonatomic) NSString * name;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name andCertificate:(NSString *)certName;

- (void)broadcastUpdateNotification;

@end
