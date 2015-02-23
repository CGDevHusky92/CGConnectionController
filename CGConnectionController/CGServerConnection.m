//
//  CGServerConnection.m
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import "CGServerConnection.h"
#import "CGReachability.h"

#import <CGDataController/CGDataController.h>

#import <CGSubExtender/CGSubExtender.h>

#define AUTH_PRINT_DEBUG    0
#define DATA_PRINT_DEBUG    0

@interface CGServerConnection () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic) CGReachability * hostReachability;

@property (strong, nonatomic) NSURLSessionConfiguration * config;
@property (strong, nonatomic) NSURLSession * session;

@property (strong, nonatomic) NSString * accessToken;
@property (strong, nonatomic) NSString * refreshToken;
@property (strong, nonatomic) NSString * tokenType;
@property (assign, nonatomic) int expirationTime;

@property (nonatomic, strong) NSMutableDictionary * registeredClassesWithURLs;

@end

@implementation CGServerConnection
@synthesize baseURL=_baseURL;
@synthesize authenticated=_authenticated;
@synthesize registeredClassesWithURLs=_registeredClassesWithURLs;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _authenticated = NO;
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _config.HTTPAdditionalHeaders = @{ @"Accept":@"application/json", @"User-Agent":@"iOS-App", @"Accept-Language":@"en-US,en;q=0.5" };
        _session = [NSURLSession sessionWithConfiguration:_config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)urlPath
{
    self = [self init];
    if (self)
        _baseURL = urlPath;
    return self;
}

- (NSArray *)registeredClasses
{
    return [_registeredClassesWithURLs allKeys];
}

- (void)registerClass:(NSString *)className withURLParameter:(NSString *)parameter
{
    if (!_registeredClassesWithURLs) _registeredClassesWithURLs = [[NSMutableDictionary alloc] init];
    [_registeredClassesWithURLs setObject:parameter forKey:className];
}

- (NSString *)urlForRegisteredClass:(NSString *)className
{
    NSString * urlPath = [_registeredClassesWithURLs objectForKey:className];
    if (!urlPath) {
#warning throw Exception
    }
    return urlPath;
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [self loginWithUsername:username andPassword:password withCompletion:nil];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion:(void(^)(NSError * error))completion
{
#ifdef AUTH_PRINT_DEBUG
    NSLog(@"I am authing");
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/", _baseURL]]];
    [request setHTTPMethod:@"POST"];
    NSString *unencodedAuth = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString *encodedAuth = [self base64ForString:unencodedAuth];
    [request addValue:[NSString stringWithFormat:@"Basic %@", encodedAuth] forHTTPHeaderField:@"Authorization"];
    [self genericAuthWithRequest:request withCompletion:completion];
}

- (void)attemptRefreshOfAuthenticationWithCompletion:(void(^)(NSError * error))completion
{
#ifdef AUTH_PRINT_DEBUG
    NSLog(@"I am reauthing");
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/", _baseURL]]];
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"Refresh %@", _refreshToken] forHTTPHeaderField:@"Authorization"];
    [self genericAuthWithRequest:request withCompletion:completion];
}

- (void)genericAuthWithRequest:(NSMutableURLRequest *)request withCompletion:(void(^)(NSError * error))completion
{
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            NSDictionary * responseDic = (NSDictionary *)response;
            _accessToken = [responseDic objectForKey:@"access_token"];
            _refreshToken = [responseDic objectForKey:@"refresh_token"];
            _tokenType = [responseDic objectForKey:@"token_type"];
            _expirationTime = [[responseDic objectForKey:@"expires_in"] intValue];
            
#ifdef AUTH_PRINT_DEBUG
            NSLog(@"Access Token: %@", _accessToken);
            NSLog(@"Refresh Token: %@", _refreshToken);
            NSLog(@"Expiration: %d", _expirationTime);
            NSLog(@"Token Type: %@", _tokenType);
#endif
            
            _authenticated = YES;
            if (completion) {
                completion(nil);
            } else {
                if (self.authDelegateRespondsTo.didConnectWithUserInfo) {
                    [self.authDelegate connection:self didConnectWithUserInfo:[responseDic objectForKey:@"user_info"]];
                }
            }
        } else {
            if (completion) {
                completion(error);
            } else {
                if (self.authDelegateRespondsTo.didFailToAuthenticateWithError) {
                    [self.authDelegate connection:self didFailToAuthenticateWithError:error];
                }
            }
        }
    }];
}

#pragma mark - CGConnection Overrides

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId
{
    [self syncObjectType:type withID:objectId andCompletion:nil];
}

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    if (!_authenticated || !type || !objectId) return;
    
    NSError * serializeError;
    NSString * classURL = [self urlForRegisteredClass:type];
    
#warning This should be changed so that we are all ready passing in a blob of object data.... should look at generalizing this for NSObject rather then NSManagedObject... maybe specialize each one as an override...
    NSManagedObject * manObj = [[CGDataController sharedData] managedObjectForClass:type withId:objectId];
    NSDictionary * obj = [manObj dictionaryFromObject];
    
#ifdef DATA_PRINT_DEBUG
    NSLog(@"Dictionary To Sync - %@", obj);
#endif
    
    NSData * objSerialized = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&serializeError];
    if (objSerialized) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", _baseURL, classURL, objectId]]];
        [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
        [request addValue:@"text/plain; charset=utf8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%lul", [objSerialized length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBody:objSerialized];
        [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
            if (!error) {
                if (completion) {
                    completion(nil);
                } else {
                    if (self.dataDelegateRespondsTo.didSyncObject)
                        [self.dataDelegate connection:self didSyncObjectWithId:objectId];
                }
            } else {
                if (completion) {
                    completion(error);
                } else {
                    if (self.dataDelegateRespondsTo.didFailToSyncObjectWithError)
                        [self.dataDelegate connection:self didFailToSyncObjectWithId:objectId withError:error];
                }
            }
        }];
    } else {
        if (self.dataDelegateRespondsTo.didReceiveCountForObject)
            [self.dataDelegate connection:self didFailToSyncObjectWithId:objectId withError:serializeError];
    }
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId
{
    [self deleteObjectType:type withID:objectId andCompletion:nil];
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    if (!_authenticated) {
        return;
    }
    if (!type || !objectId) {
#warning add completion to all of these...
        return;
    }
    
    NSString * classURL = [self urlForRegisteredClass:type];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", _baseURL, classURL, objectId]]];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"DELETE"];
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            if (completion) {
                completion(nil);
            } else {
                if (self.dataDelegateRespondsTo.didDeleteObject) {
                    [self.dataDelegate connection:self didDeleteObjectWithId:objectId];
                }
            }
        } else {
            if (completion) {
                completion(error);
            } else {
                if (self.dataDelegateRespondsTo.didFailToDeleteObjectWithError) {
                    [self.dataDelegate connection:self didFailToDeleteObjectWithId:objectId withError:error];
                }
            }
        }
    }];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    [self requestObjectWithType:type andID:objectId andCompletion:nil];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId andCompletion:(void(^)(NSDictionary * retObject, NSError * error))completion;
{
    if (!_authenticated) {
        return;
    }
    if (!type || !objectId) return;
    NSString * classURL = [self urlForRegisteredClass:type];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", _baseURL, classURL, objectId]]];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            NSArray * object = (NSArray *)response;
            if (completion) {
                if (object && [object count] > 0) {
                    completion([object objectAtIndex:0], nil);
                } else {
#warning Error????
                    completion(nil, [NSError errorWithDomain:@"Fuck" code:-1 userInfo:nil]);
                }
            } else {
                if (self.dataDelegateRespondsTo.didReceiveObject) {
                    [self.dataDelegate connection:self didReceiveObject:[object objectAtIndex:0]];
                }
            }
        } else {
            if (completion) {
                completion(nil, error);
            } else {
                if (self.dataDelegateRespondsTo.didFailToReceiveObjectWithError) {
                    [self.dataDelegate connection:self didFailToReceiveObjectWithId:objectId withError:error];
                }
            }
        }
        
        
    }];
}

- (void)requestObjectsWithType:(NSString *)type
{
    [self requestObjectsWithType:type andLimit:0];
}

- (void)requestObjectsWithType:(NSString *)type andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    [self requestObjectsWithType:type limit:0 andCompletion:completion];
}

- (void)requestObjectsWithType:(NSString *)type andLimit:(NSUInteger)num
{
    [self requestObjectsWithType:type limit:num andCompletion:nil];
}

- (void)requestObjectsWithType:(NSString *)type limit:(NSUInteger)num andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    if (!type) return;
    if (num > 0) {
        NSManagedObject * manObj = [[CGDataController sharedData] nth:num managedObjectForClass:type];
//        NSDate * updatedDate = [[CGDataController sharedData] dateUsingStringFromAPI:[manObj updatedAt]];
        [self requestObjectsWithType:type afterDate:[manObj updatedAt] andCompletion:completion];
    } else {
        [self requestObjectsWithType:type afterDate:nil andCompletion:completion];
    }
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date
{
    [self requestObjectsWithType:type afterDate:date andCompletion:nil];
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    if (!_authenticated) {
        return;
    }
    if (!type) return;
    NSString * classURL = [self urlForRegisteredClass:type];
    NSURL * requestURL;
    if (date) {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/after/%@", _baseURL, classURL, [date stringFromDate]]];
    } else {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", _baseURL, classURL]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            NSArray * objectsArray = (NSArray *)response;
            if (completion) {
                completion(objectsArray, nil);
            } else {
                if (self.dataDelegateRespondsTo.didReceiveObjects) {
                    [self.dataDelegate connection:self didReceiveObjects:objectsArray];
                }
            }
        } else {
            if (completion) {
                completion(nil, error);
            } else {
                if (self.dataDelegateRespondsTo.didFailToReceiveObjectsWithError) {
                    [self.dataDelegate connection:self didFailToReceiveObjectsWithError:error];
                }
            }
        }
    }];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type
{
    [self requestStatusOfObjectsWithType:type andCompletion:nil];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSDictionary * statusDic, NSError * error))completion
{
    if (!_authenticated) {
        return;
    }
    if (!type) return;
    NSString * classURL = [self urlForRegisteredClass:type];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/status", _baseURL, classURL]]];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            NSDictionary * status = (NSDictionary *)response;
            if (completion) {
                completion(status, nil);
            } else {
                if (self.dataDelegateRespondsTo.didReceiveStatusForType)
                    [self.dataDelegate connection:self didReceiveStatusForType:status];
            }
        } else {
            if (completion) {
                completion(nil, error);
            } else {
                if (self.dataDelegateRespondsTo.didFailToReceiveStatusForTypeWithError) {
                    [self.dataDelegate connection:self didFailToReceiveStatusForType:type withError:error];
                }
            }
        }
    }];
}

- (void)requestCountOfObjectsWithType:(NSString *)type
{
    [self requestCountOfObjectsWithType:type andCompletion:nil];
}

- (void)requestCountOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSUInteger count, NSError * error))completion
{
    if (!_authenticated) {
        return;
    }
    if (!type) return;
    NSString * classURL = [self urlForRegisteredClass:type];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/count", _baseURL, classURL]]];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    [self genericServerRequestWithRequest:request withCompletion:^(id response, NSError * error) {
        if (!error) {
            NSDictionary * count = (NSDictionary *)response;
            if (completion) {
                completion([[count objectForKey:@"count"] integerValue], nil);
            } else {
                if (self.dataDelegateRespondsTo.didReceiveCountForObject) {
                    [self.dataDelegate connection:self didReceiveCount:[[count objectForKey:@"count"] integerValue] forObjectType:type];
                }
            }
        } else {
            if (completion) {
                completion(0, error);
            } else {
                if (self.dataDelegateRespondsTo.didFailToReceiveCountForObjectWithError) {
                    [self.dataDelegate connection:self didFailToReceiveCountForObjectType:type withError:error];
                }
            }
        }
    }];
}

#pragma mark - Request Helper

- (void)genericServerRequestWithRequest:(NSMutableURLRequest *)request withCompletion:(void(^)(id response, NSError * error))completion
{
    if (!request || !completion) return;
    [[_session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (!error) {
            if (((NSHTTPURLResponse *)response).statusCode == 200) {
                if ([[request HTTPMethod] isEqualToString:@"DELETE"]) {
                    if (completion)
                        completion(nil, nil);
                } else {
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&jsonError];
                    if (completion)
                        completion(jsonObject, jsonError);
                }
            } else {
                id wwwAuth = [[((NSHTTPURLResponse *)response) allHeaderFields] valueForKey:@"WWW-Authenticate"];
                NSRange result = [wwwAuth rangeOfString:@"invalid_token" options:NSCaseInsensitiveSearch];
                if (wwwAuth && result.location != NSNotFound) {
                    [self attemptRefreshOfAuthenticationWithCompletion:^(NSError * error){
                        if (!error) {
                            [request setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
                            [self genericServerRequestWithRequest:request withCompletion:completion];
                        } else {
                            NSError *authError = [self generateErrorWithDomain:@"CGAuthError" code:401 andReason:[NSString stringWithFormat:@"WWW-Authenticate Info Held: %@", wwwAuth]];
                            if (completion) {
                                completion(nil, authError);
                            } else {
                                if (self.authDelegateRespondsTo.didFailToAuthenticateWithError)
                                    [self.authDelegate connection:self didFailToAuthenticateWithError:authError];
                            }
                        }
                    }];
                } else if (!wwwAuth) {
                    NSError *authError = [self generateErrorWithDomain:@"CGConnError" code:402 andReason:[NSString stringWithFormat:@"WWW-Authenticate Info was null indicating a general server error"]];
                    if (completion) {
                        completion(nil, authError);
                    } else {
                        if (self.authDelegateRespondsTo.didFailToConnectWithError)
                            [self.authDelegate connection:self didFailToConnectWithError:authError];
                    }
                } else {
                    NSError *authError = [self generateErrorWithDomain:@"CGAuthError" code:401 andReason:[NSString stringWithFormat:@"WWW-Authenticate Info Held: %@", wwwAuth]];
                    if (completion) {
                        completion(nil, authError);
                    } else {
                        if (self.authDelegateRespondsTo.didFailToAuthenticateWithError)
                            [self.authDelegate connection:self didFailToAuthenticateWithError:authError];
                    }
                }
            }
        } else {
            if (completion) {
                completion(nil, error);
            } else {
                if (self.authDelegateRespondsTo.didFailToConnectWithError)
                    [self.authDelegate connection:self didFailToConnectWithError:error];
            }
        }
    }] resume];
}

#pragma mark - Helper Methods

- (NSError *)generateErrorWithDomain:(NSString *)domain code:(NSInteger)code andReason:(NSString *)reason
{
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:reason forKey:NSLocalizedDescriptionKey];
    return [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
}

- (NSString *)base64ForString:(NSString *)str
{
    NSData *strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *input = (const uint8_t *)[strData bytes];
    NSInteger length = [strData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger j, value = 0;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length)
                value |= (0xFF & input[j]);
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
