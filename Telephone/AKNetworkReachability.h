//
//  AKNetworkReachability.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


// Notifications.
//
// Sent when target host becomes reachable.
extern NSString * const AKNetworkReachabilityDidBecomeReachableNotification;
//
// Sent when target host becomes unreachable.
extern NSString * const AKNetworkReachabilityDidBecomeUnreachableNotification;

// Wrapper for SCNetworkReachability.
@interface AKNetworkReachability : NSObject {
  @private
    SCNetworkReachabilityRef _reachability;  // Strong.
    SCNetworkReachabilityContext _context;
}

// Host name or address of the target host.
@property(nonatomic, readonly, copy) NSString *host;

// A Boolean value indicating whether the target host is reachable.
@property(nonatomic, readonly, assign, getter=isReachable) BOOL reachable;

// Returns a new instance of the network reachability for the given host.
// Returns nil when |nameOrAddress| is nil or @"".
+ (AKNetworkReachability *)networkReachabilityWithHost:(NSString *)nameOrAddress;

// Designated initializer.
// Returns nil when |nameOrAddress| is nil or @"".
- (instancetype)initWithHost:(NSString *)nameOrAddress;

@end
