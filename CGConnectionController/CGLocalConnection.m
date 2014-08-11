//
//  CGLocalConnection.m
//  REPO
//
//  Created by Charles Gorectke on 7/23/14.
//  Copyright (c) 2014 Jackson. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CGLocalConnection.h"

@interface CGLocalConnection () <MCSessionDelegate>

@end

@implementation CGLocalConnection

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name andCertificate:nil];
}

- (instancetype)initWithName:(NSString *)name andCertificate:(NSString *)certName
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)broadcastUpdateNotification
{
    
}

#pragma mark - CGConnection Overrides

- (void)updateObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    NSLog(@"Local Update Object Override");
}

- (void)deleteObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    NSLog(@"Local Delete Object Override");
}

- (void)requestObjectWithType:(NSString *)type andID:(NSString *)objectId
{
    NSLog(@"Local Request Object by ID Override");
}

- (void)requestObjectsWithType:(NSString *)type
{
    NSLog(@"Local Request Objects by Type Override");
}

- (void)requestObjectsWithType:(NSString *)type andLimit:(NSUInteger)num
{
    NSLog(@"Local Request Objects by Type with Limit Override");
}

#pragma mark - MCSession Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected) {
        NSLog(@"Peer %@ Connected", [peerID displayName]);
//        [self startSyncWithPeer:peerID];
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"Peer %@ Disconnected", [peerID displayName]);
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSError *error;
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
//    if ([[object objectForKey:@"serverClass"] isEqualToString:@"Status"]) {
//        [self compareStatusDictionary:object fromPeer:peerID];
//    } else if ([[object objectForKey:@"serverClass"] isEqualToString:@"Request"]) {
//        [self generateAndSendRequestedItems:object fromPeer:peerID];
//    } else {
//        if ([object objectForKey:@"objectId"]) {
//            NSArray *objects = [[CGDataController sharedData] managedObjectsForClass:[object objectForKey:@"serverClass"]
//                                                                           sortedByKey:@"objectId"
//                                                                         withPredicate:[NSPredicate predicateWithFormat:@"%@ like %@", @"objectId", [object objectForKey:@"objectId"]]
//                                                                             ascending:YES];
//
//            if ([objects count] == 0) {
//                // Object doesn't exist
//                NSManagedObject *obj = [[CGDataController sharedData] newManagedObjectForClass:[object objectForKey:@"serverClass"]];
//                if (![obj updateFromDictionary:object]) {
//                    pthread_mutex_lock(&_missing_lock);
//                    [self.missingDataQueue addObject:object];
//                    pthread_mutex_unlock(&_missing_lock);
//                }
//                [[CGDataController sharedData] save];
//            } else if ([objects count] == 1) {
//                // Object exists
//                NSManagedObject *obj = [objects objectAtIndex:0];
//                if (![obj updateFromDictionary:object]) {
//                    pthread_mutex_lock(&_missing_lock);
//                    [self.missingDataQueue addObject:object];
//                    pthread_mutex_unlock(&_missing_lock);
//                }
//                [[CGDataController sharedData] save];
//            } else if ([objects count] > 1) {
//                // Error more then one recruiter with id
//                NSLog(@"Error: More then one recruiter with id");
//            }
//        }
//    }
//    [self syncMissingDataQueue];
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

@end
