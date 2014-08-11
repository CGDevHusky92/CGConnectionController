//
//  CGConnectionController.m
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CGConnectionController.h"
#import "CGServerConnection.h"
#import "CGLocalConnection.h"

#import "Reachability.h"

#import "UserSecurityController.h"

@interface CGConnectionController () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) CGServerConnection * priorityConnection;
@property (strong, nonatomic) NSMutableArray * localConnections;

@property (assign, nonatomic) BOOL autoAddLocalConnections;
@property (assign, atomic) BOOL online;

@property (strong, nonatomic) NSString * certName;

//@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

- (void)addLocalConnectionWithName:(NSString *)name;

@end

@implementation CGConnectionController
@synthesize loggedIn=_loggedIn;

+ (instancetype)sharedConnection
{
    static dispatch_once_t once;
    static CGConnectionController *sharedConnection = nil;
    dispatch_once(&once, ^{
        sharedConnection = [[CGConnectionController alloc] init];
    });
    return sharedConnection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _online = YES;
        _autoAddLocalConnections = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidNotifyOnline) name:kReachabilityOnlineNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidNotifyOffline) name:kReachabilityOfflineNotification object:nil];
    }
    return self;
}

- (void)addConnectionWithBaseURL:(NSString *)baseURL
{
    if (!baseURL) return;
    _priorityConnection = [[CGServerConnection alloc] initWithBaseURL:baseURL];
    _priorityConnection.authDelegate = self;
    _priorityConnection.dataDelegate = self;
}



#warning Add reachability and other authentication checks



#pragma mark - Server Connection Helper Methods

- (void)updateDictionary
{
    
}

#pragma mark - MCAdvertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"Invited Connection %@", [peerID displayName]);
//    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - MCBrowser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    MCPeerID *myPeerID = [self globalPeerID];
    if (myPeerID.hash > peerID.hash) {
//        if (![[self.session connectedPeers] containsObject:peerID]) {
//            [browser invitePeer:peerID toSession:self.session withContext:nil timeout:0.0];
//        }
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

//// Reload this particular table view row on the main thread
//dispatch_async(dispatch_get_main_queue(), ^{
//    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//    [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//});

#pragma mark - Local Connection Helper Methods

- (void)autoAddLocalConnections:(BOOL)autoAdd
{
    [self autoAddLocalConnections:autoAdd withCertifacate:nil];
}

- (void)autoAddLocalConnections:(BOOL)autoAdd withCertifacate:(NSString *)certName
{
    _autoAddLocalConnections = autoAdd;
    MCPeerID *peerId = [self globalPeerID];
    
    if (certName) {
        //        self.session = [[MCSession alloc] initWithPeer:peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerId discoveryInfo:nil serviceType:@"jackson-repo"];
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerId serviceType:@"jackson-repo"];
    } else {
        //        self.session = [[MCSession alloc] initWithPeer:peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerId discoveryInfo:nil serviceType:@"jackson-repo"];
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerId serviceType:@"jackson-repo"];
    }
    
    //    self.session.delegate = self;
    self.advertiser.delegate = self;
    self.browser.delegate = self;
    
    [self.advertiser startAdvertisingPeer];
    [self.browser startBrowsingForPeers];
}

- (void)addLocalConnectionWithName:(NSString *)name
{
    if (!name) return;
}

#pragma mark - Private Priority Methods

- (CGConnection *)priorityConnection
{
    if (_priorityConnection) return _priorityConnection;
    if (_localConnections && [_localConnections count] > 0) return [_localConnections objectAtIndex:0];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"CGConnectionController must have a connection"] userInfo:nil];
}

- (void)checkForAuthentication
{
    if (_priorityConnection) {
        [_priorityConnection checkForAuthentication];
        
        if ([_priorityConnection authenticated]) {
            //            return YES;
        } else {
            
        }
    }
    
    //    return YES;
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [self loginWithUsername:username andPassword:password withCompletion:nil];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withCompletion:(void(^)(NSError * error))completion
{
    if (!_priorityConnection) return;
    if (!username || !password) return;
    [[self priorityConnection] loginWithUsername:username andPassword:password withCompletion:completion];
}

#pragma mark - CGConnection Method Protocol Return Overrides

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId
{
    if (!type || !objectId) return;
    [self syncObjectType:type withID:objectId andCompletion:nil];
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId
{
    if (!type || !objectId) return;
    [self deleteObjectType:type withID:objectId andCompletion:nil];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    if (!type || !objectId) return;
    [self requestObjectWithType:type andID:objectId andCompletion:nil];
}

- (void)requestObjectsWithType:(NSString *)type
{
    if (!type) return;
    [self requestObjectsWithType:type andLimit:0];
}

- (void)requestObjectsWithType:(NSString *)type andLimit:(NSUInteger)num
{
    if (!type) return;
    [self requestObjectsWithType:type limit:num andCompletion:nil];
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date
{
    if (!type) return;
    [self requestObjectsWithType:type afterDate:date andCompletion:nil];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type
{
    if (!type) return;
    [self requestStatusOfObjectsWithType:type andCompletion:nil];
}

- (void)requestCountOfObjectsWithType:(NSString *)type
{
    if (!type) return;
    [self requestCountOfObjectsWithType:type andCompletion:nil];
}

#pragma mark - CGConnection Completion Return Overrides

- (void)syncObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    if (!type || !objectId) return;
    [[self priorityConnection] syncObjectType:type withID:objectId andCompletion:completion];
}

- (void)deleteObjectType:(NSString *)type withID:(NSString *)objectId andCompletion:(void(^)(NSError * error))completion
{
    if (!type || !objectId) return;
    [[self priorityConnection] deleteObjectType:type withID:objectId andCompletion:completion];
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId andCompletion:(void (^)(NSDictionary *, NSError * error))completion
{
    if (!type || !objectId) return;
    [[self priorityConnection] requestObjectWithType:type andID:objectId andCompletion:completion];
}

- (void)requestObjectsWithType:(NSString *)type andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    if (!type) return;
    [[self priorityConnection] requestObjectsWithType:type andCompletion:completion];
}

- (void)requestObjectsWithType:(NSString *)type limit:(NSUInteger)num andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    if (!type) return;
    [[self priorityConnection] requestObjectsWithType:type limit:num andCompletion:completion];
}

- (void)requestObjectsWithType:(NSString *)type afterDate:(NSDate *)date andCompletion:(void(^)(NSArray * retObjects, NSError * error))completion
{
    if (!type) return;
    [[self priorityConnection] requestObjectsWithType:type afterDate:date andCompletion:completion];
}

- (void)requestStatusOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSDictionary * statusDic, NSError * error))completion
{
    if (!type) return;
    [[self priorityConnection] requestStatusOfObjectsWithType:type andCompletion:completion];
}

- (void)requestCountOfObjectsWithType:(NSString *)type andCompletion:(void(^)(NSUInteger count, NSError * error))completion
{
    if (!type) return;
    [[self priorityConnection] requestCountOfObjectsWithType:type andCompletion:completion];
}

//#pragma mark - CGAuthConnection Protocol
//
//- (void)connection:(CGConnection *)connection didConnectWithUserInfo:(NSDictionary *)userInfo
//{
//    if (self.authDelegateRespondsTo.didConnectWithUserInfo)
//        [self.authDelegate connection:connection didConnectWithUserInfo:userInfo];
//}
//
//- (void)connection:(CGConnection *)connection didFailToConnectWithError:(NSError *)error
//{
//    NSLog(@"Error: %@", error);
//    if (self.authDelegateRespondsTo.didFailToConnectWithError)
//        [self.authDelegate connection:connection didFailToConnectWithError:error];
//}
//
//- (void)connection:(CGConnection *)connection didFailToAuthenticateWithError:(NSError *)error
//{
//    if (self.authDelegateRespondsTo.didFailToAuthenticateWithError)
//        [self.authDelegate connection:connection didFailToAuthenticateWithError:error];
//}
//
//#pragma mark - CGDataConnection Protocol
//
//- (void)connection:(CGConnection *)connection didSyncObjectWithId:(NSString *)objectId
//{
//    if (self.dataDelegateRespondsTo.didSyncObject)
//        [self.dataDelegate connection:connection didSyncObjectWithId:objectId];
//}
//
//- (void)connection:(CGConnection *)connection didFailToSyncObjectWithId:(NSString *)objectId withError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToSyncObjectWithError)
//        [self.dataDelegate connection:connection didFailToSyncObjectWithId:objectId withError:error];
//}
//
//- (void)connection:(CGConnection *)connection didDeleteObjectWithId:(NSString *)objectId
//{
//    if (self.dataDelegateRespondsTo.didDeleteObject)
//        [self.dataDelegate connection:connection didSyncObjectWithId:objectId];
//}
//
//- (void)connection:(CGConnection *)connection didFailToDeleteObjectWithId:(NSString *)objectId withError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToDeleteObjectWithError)
//        [self.dataDelegate connection:connection didFailToDeleteObjectWithId:objectId withError:error];
//}
//
//- (void)connection:(CGConnection *)connection didReceiveObject:(NSDictionary *)object
//{
//    if (self.dataDelegateRespondsTo.didReceiveObject)
//        [self.dataDelegate connection:connection didReceiveObject:object];
//}
//
//- (void)connection:(CGConnection *)connection didFailToReceiveObjectWithId:(NSString *)objectId withError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToReceiveObjectWithError)
//        [self.dataDelegate connection:connection didFailToReceiveObjectWithId:objectId withError:error];
//}
//
//- (void)connection:(CGConnection *)connection didReceiveObjects:(NSArray *)objects
//{
//    if (self.dataDelegateRespondsTo.didReceiveObjects)
//        [self.dataDelegate connection:connection didReceiveObjects:objects];
//}
//
//- (void)connection:(CGConnection *)connection didFailToReceiveObjectsWithError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToReceiveObjectsWithError)
//        [self.dataDelegate connection:connection didFailToReceiveObjectsWithError:error];
//}
//
//- (void)connection:(CGConnection *)connection didReceiveStatusForType:(NSDictionary *)status
//{
//    if (self.dataDelegateRespondsTo.didReceiveStatusForType)
//        [self.dataDelegate connection:connection didReceiveStatusForType:status];
//}
//
//- (void)connection:(CGConnection *)connection didFailToReceiveStatusForObjectType:(NSString *)type withError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToReceiveStatusForTypeWithError)
//        [self.dataDelegate connection:connection didFailToReceiveStatusForType:type withError:error];
//}
//
//- (void)connection:(CGConnection *)connection didReceiveCount:(NSUInteger)count forObjectType:(NSString *)type
//{
//    if (self.dataDelegateRespondsTo.didReceiveCountForObject)
//        [self.dataDelegate connection:connection didReceiveCount:count forObjectType:type];
//}
//
//- (void)connection:(CGConnection *)connection didFailToReceiveCountForObjectType:(NSString *)type withError:(NSError *)error
//{
//    if (self.dataDelegateRespondsTo.didFailToReceiveCountForObjectWithError)
//        [self.dataDelegate connection:connection didFailToReceiveCountForObjectType:type withError:error];
//}

#pragma mark - Reachability Protocol

- (void)reachabilityDidNotifyOnline
{
    NSLog(@"Device has network");
    _online = YES;
}

- (void)reachabilityDidNotifyOffline
{
    NSLog(@"Device doesn't have network");
    _online = NO;
}

#pragma mark - Global PeerID

- (MCPeerID *)globalPeerID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData  *peerIDData = [defaults dataForKey:kCGPeerIDKey];
    MCPeerID *peerID;
    if (peerIDData) {
        peerID = [NSKeyedUnarchiver unarchiveObjectWithData:peerIDData];
    } else {
        peerID = [[MCPeerID alloc] initWithDisplayName:[[UserSecurityController sharedLogin] nick_nm]];
        peerIDData = [NSKeyedArchiver archivedDataWithRootObject:peerID];
        [defaults setObject:peerID forKey:kCGPeerIDKey];
        [defaults synchronize];
    }
    return peerID;
}

#pragma mark - Cleanup Protocol

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
