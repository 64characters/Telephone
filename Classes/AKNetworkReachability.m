//
//  AKNetworkReachability.m
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
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

#import "AKNetworkReachability.h"

#import <netinet/in.h>
#import <arpa/inet.h>

#import "AKNSString+Scanning.h"


NSString * const AKNetworkReachabilityDidBecomeReachableNotification = @"AKNetworkReachabilityDidBecomeReachable";
NSString * const AKNetworkReachabilityDidBecomeUnreachableNotification = @"AKNetworkReachabilityDidBecomeUnreachable";

// SCNetworkReachability callback.
static void AKReachabilityChanged(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info);


@interface AKNetworkReachability ()

@property (nonatomic, copy) NSString *host;

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

- (id)initWithHost:(NSString *)nameOrAddress {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    if ([nameOrAddress length] == 0) {
        return nil;
    }
    
    if ([nameOrAddress ak_isIPAddress]) {
        struct sockaddr_in sin;
        bzero(&sin, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET;
        inet_aton([nameOrAddress UTF8String], &sin.sin_addr);
        _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&sin);
    } else {
        _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [nameOrAddress UTF8String]);
    }
    
    _context.info = (__bridge void *)(self);
    Boolean callbackSet = SCNetworkReachabilitySetCallback(_reachability, &AKReachabilityChanged, &_context);
    if (!callbackSet) {
        return nil;
    }
    
    Boolean scheduled = SCNetworkReachabilityScheduleWithRunLoop(_reachability,
                                                                 CFRunLoopGetMain(),
                                                                 kCFRunLoopDefaultMode);
    if (!scheduled) {
        return nil;
    }
    
    [self setHost:nameOrAddress];
    
    return self;
}

- (void)dealloc {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    if (_reachability != NULL) {
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
