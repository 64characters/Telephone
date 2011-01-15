//
//  AKNetworkReachability.h
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
  SCNetworkReachabilityRef reachability_;  // Strong.
  SCNetworkReachabilityContext context_;
  NSString *host_;
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
- (id)initWithHost:(NSString *)nameOrAddress;

@end
