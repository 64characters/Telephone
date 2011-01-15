//
//  AKNetworkReachability.m
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

#import "AKNetworkReachability.h"

#import <netinet/in.h>
#import <arpa/inet.h>

#import "AKNSString+Scanning.h"


NSString * const AKNetworkReachabilityDidBecomeReachableNotification
 = @"AKNetworkReachabilityDidBecomeReachable";
NSString * const AKNetworkReachabilityDidBecomeUnreachableNotification
 = @"AKNetworkReachabilityDidBecomeUnreachable";

// SCNetworkReachability callback.
static void AKReachabilityChanged(SCNetworkReachabilityRef target,
                                  SCNetworkConnectionFlags flags,
                                  void *info);


@interface AKNetworkReachability ()

@property(nonatomic, copy) NSString *host;

@end


@implementation AKNetworkReachability

@synthesize host = host_;
@dynamic reachable;

- (BOOL)isReachable {
  SCNetworkConnectionFlags flags;
  Boolean flagsValid = SCNetworkReachabilityGetFlags(reachability_, &flags);
  
  return (flagsValid && (flags & kSCNetworkFlagsReachable)) ? YES : NO;
}

+ (AKNetworkReachability *)networkReachabilityWithHost:(NSString *)nameOrAddress {
  return [[[self alloc] initWithHost:nameOrAddress] autorelease];
}

- (id)initWithHost:(NSString *)nameOrAddress {
  self = [super init];
  if (self == nil)
    return nil;
  
  if ([nameOrAddress length] == 0) {
    [self release];
    return nil;
  }

  if ([nameOrAddress ak_isIPAddress]) {
    struct sockaddr_in sin;
    bzero(&sin, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    inet_aton([nameOrAddress UTF8String], &sin.sin_addr);
    reachability_
      = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                               (struct sockaddr *)&sin);
  } else {
    reachability_
      = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault,
                                            [nameOrAddress UTF8String]);
  }
  
  context_.info = self;
  Boolean callbackSet = SCNetworkReachabilitySetCallback(reachability_,
                                                         &AKReachabilityChanged,
                                                         &context_);
  if (!callbackSet) {
    [self release];
    return nil;
  }
  
  Boolean scheduled
    = SCNetworkReachabilityScheduleWithRunLoop(reachability_,
                                               CFRunLoopGetMain(),
                                               kCFRunLoopDefaultMode);
  if (!scheduled) {
    [self release];
    return nil;
  }
  
  [self setHost:nameOrAddress];
  
  return self;
}

- (void)dealloc {
  SCNetworkReachabilityUnscheduleFromRunLoop(reachability_,
                                             CFRunLoopGetMain(),
                                             kCFRunLoopDefaultMode);
  if (reachability_ != NULL)
    CFRelease(reachability_);
  
  [host_ release];
  
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ reachability", [self host]];
}

@end


static void AKReachabilityChanged(SCNetworkReachabilityRef target,
                                  SCNetworkConnectionFlags flags,
                                  void *info) {
  AKNetworkReachability *networkReachability = (AKNetworkReachability *)info;
  
  if (flags & kSCNetworkFlagsReachable) {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AKNetworkReachabilityDidBecomeReachableNotification
                   object:networkReachability];
  } else {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AKNetworkReachabilityDidBecomeUnreachableNotification
                   object:networkReachability];
  }
}
