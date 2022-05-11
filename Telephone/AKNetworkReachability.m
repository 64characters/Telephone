//
//  AKNetworkReachability.m
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

#import "AKNetworkReachability.h"

#import <netinet/in.h>
#import <arpa/inet.h>

@import UseCases;


NSString * const AKNetworkReachabilityDidBecomeReachableNotification = @"AKNetworkReachabilityDidBecomeReachable";
NSString * const AKNetworkReachabilityDidBecomeUnreachableNotification = @"AKNetworkReachabilityDidBecomeUnreachable";

// SCNetworkReachability callback.
static void AKReachabilityChanged(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info);


@interface AKNetworkReachability ()

@property(nonatomic, copy) NSString *host;

@end


@implementation AKNetworkReachability

- (BOOL)isReachable {
    SCNetworkConnectionFlags flags;
    Boolean flagsValid = SCNetworkReachabilityGetFlags(_reachability, &flags);
    
    return (flagsValid && (flags & kSCNetworkFlagsReachable)) ? YES : NO;
}

+ (AKNetworkReachability *)networkReachabilityWithHost:(NSString *)nameOrAddress {
    return [[self alloc] initWithHost:nameOrAddress];
}

- (instancetype)initWithHost:(NSString *)nameOrAddress {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    if ([nameOrAddress length] == 0) {
        return nil;
    }
    
    if ([nameOrAddress ak_isIP4Address]) {
        struct sockaddr_in sin;
        bzero(&sin, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET;
        inet_pton(AF_INET, [nameOrAddress UTF8String], &sin.sin_addr);
        _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&sin);
    } else if ([nameOrAddress ak_isIP6Address]) {
        struct sockaddr_in6 sin;
        bzero(&sin, sizeof(sin));
        sin.sin6_len = sizeof(sin);
        sin.sin6_family = AF_INET6;
        inet_pton(AF_INET6, [nameOrAddress UTF8String], &sin.sin6_addr);
        _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&sin);
    } else {
        _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [nameOrAddress UTF8String]);
    }
    
    _context.info = (__bridge void *)(self);
    Boolean callbackSet = SCNetworkReachabilitySetCallback(_reachability, &AKReachabilityChanged, &_context);
    if (!callbackSet) {
        if (_reachability) {
            CFRelease(_reachability);
        }
        return nil;
    }
    
    Boolean scheduled = SCNetworkReachabilityScheduleWithRunLoop(_reachability,
                                                                 CFRunLoopGetMain(),
                                                                 kCFRunLoopDefaultMode);
    if (!scheduled) {
        if (_reachability) {
            CFRelease(_reachability);
        }
        return nil;
    }
    
    [self setHost:nameOrAddress];
    
    return self;
}

- (void)dealloc {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    if (_reachability) {
        CFRelease(_reachability);
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ reachability", [self host]];
}

@end


static void AKReachabilityChanged(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info) {
    AKNetworkReachability *networkReachability = (__bridge AKNetworkReachability *)info;
    
    if (flags & kSCNetworkFlagsReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AKNetworkReachabilityDidBecomeReachableNotification
                                                            object:networkReachability];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:AKNetworkReachabilityDidBecomeUnreachableNotification
                                                            object:networkReachability];
    }
}
