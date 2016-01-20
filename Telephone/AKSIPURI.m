//
//  AKSIPURI.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

#import "AKSIPURI.h"

#import <pjsua-lib/pjsua.h>

#import "AKNSString+PJSUA.h"
#import "AKSIPUserAgent.h"


@implementation AKSIPURI

- (NSString *)SIPAddress {
    if ([[self user] length] > 0) {
        return [NSString stringWithFormat:@"%@@%@", [self user], [self host]];
    } else {
        return [self host];
    }
}


#pragma mark -

+ (instancetype)SIPURIWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName {
    return [[self alloc] initWithUser:aUser host:aHost displayName:aDisplayName];
}

+ (instancetype)SIPURIWithString:(NSString *)SIPURIString {
    return [[self alloc] initWithString:SIPURIString];
}

// Designated initializer.
- (instancetype)initWithUser:(NSString *)aUser host:(NSString *)aHost displayName:(NSString *)aDisplayName {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    [self setDisplayName:aDisplayName];
    [self setUser:aUser];
    [self setHost:aHost];
    
    return self;
}

- (instancetype)init {
    return [self initWithUser:nil host:nil displayName:nil];
}

- (instancetype)initWithString:(NSString *)SIPURIString {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s<sip:(.+@)?.+>'"];
    if ([predicate evaluateWithObject:SIPURIString]) {
        NSRange delimiterRange = [SIPURIString rangeOfString:@" <"];
        
        NSMutableCharacterSet *trimmingCharacterSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
        [trimmingCharacterSet addCharactersInString:@"\""];
        [self setDisplayName:[[SIPURIString substringToIndex:delimiterRange.location]
                              stringByTrimmingCharactersInSet:trimmingCharacterSet]];
        
        NSRange userAndHostRange = [SIPURIString rangeOfString:@"<sip:" options:NSCaseInsensitiveSearch];
        userAndHostRange.location += 5;
        userAndHostRange.length = [SIPURIString length] - userAndHostRange.location - 1;
        NSString *userAndHost = [SIPURIString substringWithRange:userAndHostRange];
        
        NSRange atSignRange = [userAndHost rangeOfString:@"@" options:NSBackwardsSearch];
        if (atSignRange.location != NSNotFound) {
            [self setUser:[userAndHost substringToIndex:atSignRange.location]];
            [self setHost:[userAndHost substringFromIndex:(atSignRange.location + 1)]];
        } else {
            [self setHost:userAndHost];
        }
        
        return self;
    }
    
    if (![[AKSIPUserAgent sharedUserAgent] isStarted]) {
        return nil;
    }
    
    pjsip_name_addr *nameAddr;
    nameAddr = (pjsip_name_addr *)pjsip_parse_uri([[AKSIPUserAgent sharedUserAgent] pjPool],
                                                  (char *)[SIPURIString cStringUsingEncoding:NSUTF8StringEncoding],
                                                  [SIPURIString length], PJSIP_PARSE_URI_AS_NAMEADDR);
    if (nameAddr == NULL) {
        return nil;
    }
    
    [self setDisplayName:[NSString stringWithPJString:nameAddr->display]];
    
    pj_str_t *schemePJString = (pj_str_t *)pjsip_uri_get_scheme(nameAddr);
    NSString *scheme = [NSString stringWithPJString:*schemePJString];
    
    if ([scheme isEqualToString:@"sip"] || [scheme isEqualToString:@"sips"]) {
        pjsip_sip_uri *uri = (pjsip_sip_uri *)pjsip_uri_get_uri(nameAddr);
        
        [self setUser:[NSString stringWithPJString:uri->user]];
        [self setPassword:[NSString stringWithPJString:uri->passwd]];
        [self setHost:[NSString stringWithPJString:uri->host]];
        [self setPort:uri->port];
        [self setUserParameter:[NSString stringWithPJString:uri->user_param]];
        [self setMethodParameter:[NSString stringWithPJString:uri->method_param]];
        [self setTransportParameter:[NSString stringWithPJString:uri->transport_param]];
        [self setTTLParameter:uri->ttl_param];
        [self setLooseRoutingParameter:uri->lr_param];
        [self setMaddrParameter:[NSString stringWithPJString:uri->maddr_param]];
        
    } else if ([scheme isEqualToString:@"tel"]) {
        // TODO(eofster): we really must have some kind of AKTelURI here instead.
        pjsip_tel_uri *uri = (pjsip_tel_uri *)pjsip_uri_get_uri(nameAddr);
        
        [self setUser:[NSString stringWithPJString:uri->number]];
        
    } else {
        return nil;
    }
    
    return self;
}

- (NSString *)description {
    NSString *SIPAddressWithPort = [self SIPAddress];
    if ([self port] > 0) {
        SIPAddressWithPort = [SIPAddressWithPort stringByAppendingFormat:@":%ld", [self port]];
    }
    
    if ([[self displayName] length] > 0) {
        return [NSString stringWithFormat:@"\"%@\" <sip:%@>", [self displayName], SIPAddressWithPort];
    } else {
        return [NSString stringWithFormat:@"<sip:%@>", SIPAddressWithPort];
    }
}


#pragma mark -
#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone {
  AKSIPURI *newURI = [[AKSIPURI allocWithZone:zone] initWithUser:[self user]
                                                            host:[self host]
                                                     displayName:[self displayName]];
  [newURI setPassword:[self password]];
  [newURI setPort:[self port]];
  [newURI setUserParameter:[self userParameter]];
  [newURI setMethodParameter:[self methodParameter]];
  [newURI setTransportParameter:[self transportParameter]];
  [newURI setTTLParameter:[self TTLParameter]];
  [newURI setLooseRoutingParameter:[self looseRoutingParameter]];
  [newURI setMaddrParameter:[self maddrParameter]];
  
  return newURI;
}

@end
