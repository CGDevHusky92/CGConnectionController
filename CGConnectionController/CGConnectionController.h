//
//  CGConnectionController.h
//  CGConnectionController
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CGConnectionController/CGConnection.h>
#import <CGConnectionController/CGReachability.h>

//! Project version number for CGConnectionController.
FOUNDATION_EXPORT double CGConnectionControllerVersionNumber;

//! Project version string for CGConnectionController.
FOUNDATION_EXPORT const unsigned char CGConnectionControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CGConnectionController/PublicHeader.h>

@interface CGConnectionController : CGConnection

//@property (weak, nonatomic) id<CGAuthConnectionDelegate> syncDelegate;
@property (assign, readonly) BOOL loggedIn;

+ (instancetype)sharedConnection;

- (void)addConnectionWithBaseURL:(NSString *)baseURL;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion:(void(^)(NSError * error))completion;

- (void)autoAddLocalConnections:(BOOL)autoAdd;
- (void)autoAddLocalConnections:(BOOL)autoAdd withCertifacate:(NSString *)certName;

- (NSArray *)registeredClasses;
- (void)registerClass:(NSString *)className withURLParameter:(NSString *)parameter;
- (NSString *)urlForRegisteredClass:(NSString *)className;

@end
