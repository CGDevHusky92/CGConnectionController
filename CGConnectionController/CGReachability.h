/**
 
 To use register for notification
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kCGReachabilityChangedNotification object:nil];
 self.reachability = [CGReachability reachabilityWithHostName:remoteHostName];
 [self.reachability startNotifier];

 - (void)reachabilityChanged:(NSNotification *)note
 {
	CGReachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[CGReachability class]]);
 
    ...Get data from reachability
    
    CGNetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = [curReach connectionRequired];
    NSString* statusString = @"";
     
    switch (netStatus) {
        case kCGNetworkNotReachable: {
            // statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            // imageView.image = [UIImage imageNamed:@"stop-32.png"];
 
            / * Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here... * /
 
            connectionRequired = NO;
            break;
        }

        case kCGNetworkReachableViaWiFi: {
            // statusString= NSLocalizedString(@"Reachable WiFi", @"");
            // imageView.image = [UIImage imageNamed:@"Airport.png"];
            break;
        }

        case kCGNetworkReachableViaWWAN: {
            // statusString = NSLocalizedString(@"Reachable WWAN", @"");
            // imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            break;
        }
    }
 }

 Don't forget to remove the notification in dealloc

 [[NSNotificationCenter defaultCenter] removeObserver:self name:kCGReachabilityChangedNotification object:nil];

 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef NS_ENUM(NSInteger, CGNetworkStatus) {
    kCGNetworkNotReachable = 0,
    kCGNetworkReachableViaWiFi,
    kCGNetworkReachableViaWWAN
};

extern NSString *kCGReachabilityChangedNotification;

@interface CGReachability : NSObject

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;
+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
+ (instancetype)reachabilityForInternetConnection;
+ (instancetype)reachabilityForLocalWiFi;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (CGNetworkStatus)currentReachabilityStatus;

- (BOOL)connectionRequired;

@end

