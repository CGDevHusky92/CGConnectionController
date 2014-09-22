
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

#import "CGReachability.h"

NSString *kCGReachabilityChangedNotification = @"kCGNetworkReachabilityChangedNotification";

static void CGReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in CGReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass:[CGReachability class]], @"info was wrong class in CGReachabilityCallback");

    CGReachability* noteObject = (__bridge CGReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:kCGReachabilityChangedNotification object:noteObject];
}

@interface CGReachability ()

@property (assign) BOOL alwaysReturnLocalWiFiStatus;
@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;

@end

#pragma mark - Reachability implementation

@implementation CGReachability

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	CGReachability* ret = NULL;

	if (reachability != NULL) {
		ret = [[self alloc] init];
		if (ret != NULL) {
			ret->_reachabilityRef = reachability;
			ret->_alwaysReturnLocalWiFiStatus = NO;
		}
	}
	return ret;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
	CGReachability* ret = NULL;

	if (reachability != NULL) {
		ret = [[self alloc] init];
		if (ret != NULL) {
			ret->_reachabilityRef = reachability;
			ret->_alwaysReturnLocalWiFiStatus = NO;
		}
	}
	return ret;
}

+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}

+ (instancetype)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	CGReachability * ret = [self reachabilityWithAddress:&localWifiAddress];
	if (ret != NULL)
		ret->_alwaysReturnLocalWiFiStatus = YES;
    
	return ret;
}

#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
	BOOL ret = NO;
	SCNetworkReachabilityContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, CGReachabilityCallback, &context))
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
			ret = YES;

	return ret;
}

- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
		CFRelease(_reachabilityRef);
}

#pragma mark - Network Flag Handling

- (CGNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	CGNetworkStatus ret = kCGNetworkNotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
		ret = kCGNetworkReachableViaWiFi;
    
	return ret;
}

- (CGNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
		return kCGNetworkNotReachable;

    CGNetworkStatus ret = kCGNetworkNotReachable;

    /* If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi... */
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
		ret = kCGNetworkReachableViaWiFi;

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
        /* ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs... */
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
            /* ... and no [user] intervention is needed... */
            ret = kCGNetworkReachableViaWiFi;

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
		/* ... but WWAN connections are OK if the calling application is using the CFNetwork APIs. */
		ret = kCGNetworkReachableViaWWAN;
    
	return ret;
}

- (BOOL)connectionRequired
{
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);

    return NO;
}

- (CGNetworkStatus)currentReachabilityStatus
{
	NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	CGNetworkStatus ret = kCGNetworkNotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		if (_alwaysReturnLocalWiFiStatus) {
			ret = [self localWiFiStatusForFlags:flags];
		} else {
			ret = [self networkStatusForFlags:flags];
		}
	}
    
	return ret;
}

@end
