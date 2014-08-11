//
//  CGConnectionController.h
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGConnection.h"

@interface CGConnectionController : CGConnection

//@property (weak, nonatomic) id<CGAuthConnectionDelegate> syncDelegate;
@property (assign, readonly) BOOL loggedIn;

+ (instancetype)sharedConnection;

- (void)addConnectionWithBaseURL:(NSString *)baseURL;

- (void)checkForAuthentication;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion:(void(^)(NSError * error))completion;

- (void)autoAddLocalConnections:(BOOL)autoAdd;
- (void)autoAddLocalConnections:(BOOL)autoAdd withCertifacate:(NSString *)certName;

@end
