//
//  CGServerConnection.h
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGConnection.h"

@interface CGServerConnection : CGConnection

@property (strong, nonatomic) NSString * baseURL;
@property (assign, nonatomic) BOOL authenticated;

- (instancetype)initWithBaseURL:(NSString *)urlPath;

//- (void)checkForAuthentication;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion:(void(^)(NSError * error))completion;

- (NSArray *)registeredClasses;
- (void)registerClass:(NSString *)className withURLParameter:(NSString *)parameter;
- (NSString *)urlForRegisteredClass:(NSString *)className;

@end

