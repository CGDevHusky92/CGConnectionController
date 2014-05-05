//
//  CGConnectionController.m
//  CGConnectionController
//
//  Created by Chase Gorectke on 3/31/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import "CGConnectionController.h"

@interface CGConnectionController ()

@property (nonatomic, strong) NSMutableArray *syncLibraries;
@property (nonatomic, strong) NSMutableArray *syncURLs;
@property (nonatomic, strong) NSMutableArray *syncDevices;

@end

@implementation CGConnectionController
@synthesize syncLibraries=_syncLibraries;
@synthesize syncURLs=_syncURLs;
@synthesize syncDevices=_syncDevices;

+ (instancetype)sharedConnection
{
    static dispatch_once_t once;
    static CGConnectionController *sharedConnection;
    dispatch_once(&once, ^{
        sharedConnection = [[self alloc] init];
    });
    return sharedConnection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _syncLibraries = [[NSMutableArray alloc] init];
        _syncURLs = [[NSMutableArray alloc] init];
        _syncDevices = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSource:(NSString *)name withType:(CGConnectionType)type
{
    switch (type) {
        case kCGConnectionLibrary:
            [_syncLibraries addObject:name];
            break;
        case kCGConnectionServer:
            [_syncURLs addObject:name];
            break;
        case kCGConnectionLocal:
            [_syncDevices addObject:name];
            break;
        case kCGConnectionNone:
        default:
            break;
    }
}

- (CGConnectionType)defaultSource
{
    if ([_syncURLs count] > 0) {
        return kCGConnectionServer;
    } else if ([_syncLibraries count] > 0) {
        return kCGConnectionLibrary;
    } else if ([_syncDevices count] > 0) {
        return kCGConnectionLocal;
    }
    return kCGConnectionNone;
}

#pragma mark - Grab server objects

- (CGManagedObject *)retrieveObjectOnServer:(NSString *)objId
{
#warning Implement
    return nil;
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className
{
    return [self grabAllServerObjectsWithName:className orderAscendingByKey:nil];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderAscendingByKey:(NSString *)key
{
    return [self grabAllServerObjectsWithName:className orderedByKey:key ascending:YES];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderDescendingByKey:(NSString *)key
{
    return [self grabAllServerObjectsWithName:className orderedByKey:key ascending:NO];
}

- (NSArray *)grabAllServerObjectsWithName:(NSString *)className orderedByKey:(NSString *)key ascending:(BOOL)ascend
{
    if (!className || ![PFUser currentUser]) return nil;
    
    NSError *error = nil;
    switch ([self defaultSource]) {
        case kCGConnectionLibrary:
            if ([_syncLibraries count] > 0 && [[_syncLibraries objectAtIndex:0] isEqualToString:@"Parse"]) {
                PFQuery *query = [PFQuery queryWithClassName:className];
                query.limit = 1000;
                
                if (key) {
                    if (ascend) {
                        [query orderByAscending:key];
                    } else {
                        [query orderByDescending:key];
                    }
                }
                
                NSArray *objects = [query findObjects:&error];
                
                if (error) {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
                
                return objects;
            }
            break;
        case kCGConnectionServer:
            
            break;
        case kCGConnectionLocal:
            
            break;
        case kCGConnectionNone:
        default:
            break;
    }
    
    return nil;
}

//#pragma mark - Custom Decision Grab Tools
//
//- (NSArray *)decisionsForGroup:(int)group
//{
//    NSError *error = nil;
//    
//    // 1
//    if ([PFUser currentUser]) {
//        PFQuery *rec = [PFQuery queryWithClassName:@"Decision"];
//        [rec whereKey:@"receiver" equalTo:[[PFUser currentUser] username]];
//        [rec orderByDescending:@"createdAt"];
//        rec.limit = 50;
//        NSArray *recObjs = [rec findObjects:&error];
//        if (error) {
//            NSLog(@"Error: %@", [error localizedDescription]);
//            return nil;
//        }
//        
//        // 2
//        PFQuery *sen = [PFQuery queryWithClassName:@"Decision"];
//        [sen whereKey:@"sender" equalTo:[[PFUser currentUser] username]];
//        [sen orderByDescending:@"createdAt"];
//        sen.limit = 1000;
//        NSArray *senObjs = [sen findObjects:&error];
//        if (error) {
//            NSLog(@"Error: %@", [error localizedDescription]);
//            return nil;
//        }
//        
//        // 3
//        // Unique array of objectIds
//        // Array of the unique objects
//        NSArray *senUniqueObjs = [self decisionsStripUniqueObjects:senObjs];
//        
//        // 4
//        // Combine Unique Array and Rec Array Sorted By "createdAt"
//        // Remove Anything after 50 items
//        NSArray *combinedArray = [self decisionsSortedArrayOfObjects:recObjs andObjects:senUniqueObjs withLimit:YES];
//        
//        // 5
//        // Iterate over remaining array and find objects contained in the unique array
//        // add those objects to separate array and call decisionsFinalSelfSenderGroup on there valueForKey:@"choices"
//        NSMutableArray *combMutable = [combinedArray mutableCopy];
//        [combMutable removeObjectsInArray:recObjs];
//        NSArray *finalUnique = [combMutable valueForKeyPath:@"choices"];
//        NSArray *totalSend = [self decisionsFinalSenderFromGatheredObjects:senObjs forKeys:finalUnique];
//        
//        // 6
//        // Recombine into single array
//        NSArray *ret = [self decisionsSortedArrayOfObjects:recObjs andObjects:totalSend withLimit:YES];
//        return ret;
//    }
//    
//    return nil;
//}
//
//- (NSArray *)decisionsStripUniqueObjects:(NSArray *)objects
//{
//    if (!objects) return nil;
//    NSMutableArray *ret = [[NSMutableArray alloc] init];
//    NSMutableArray *uniqueObjKeys = [[objects valueForKeyPath:@"@distinctUnionOfObjects.choices"] mutableCopy];
//    for (PFDecision *dec in objects) {
//        if ([uniqueObjKeys containsObject:[dec choices]]) {
//            [ret addObject:dec];
//            [uniqueObjKeys removeObject:[dec choices]];
//        }
//    }
//    return ret;
//}
//
//- (NSArray *)decisionsSortedArrayOfObjects:(NSArray *)objsOne andObjects:(NSArray *)objsTwo withLimit:(BOOL)limit
//{
//    if (!objsOne || !objsTwo) return nil;
//    NSMutableArray *ret = [objsOne mutableCopy];
//    ret = [[ret arrayByAddingObjectsFromArray:objsTwo] mutableCopy];
//    [ret sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
//    if (limit && [ret count] > DECISION_PULL_LIMIT) {
//        [ret removeObjectsInRange:NSMakeRange((DECISION_PULL_LIMIT), [ret count] - DECISION_PULL_LIMIT)];
//    }
//    return ret;
//}
//
//- (NSArray *)decisionsFinalSenderFromGatheredObjects:(NSArray *)objs forKeys:(NSArray *)objIds
//{
//    if (!objs || !objIds) return nil;
//    NSMutableArray *ret = [[NSMutableArray alloc] init];
//    for (PFDecision *dec in objs) {
//        if ([objIds containsObject:[dec choices]]) {
//            [ret addObject:dec];
//        }
//    }
//    return ret;
//}

@end
