//
//  CGServerConnection.h
//  CGConnectionController
//
//  Created by Chase Gorectke on 4/15/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGConnection.h"

@interface CGServerConnection : CGConnection

@property (nonatomic, strong) NSURL *url;

@end
