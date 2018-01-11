//
//  AKSIPURI.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

+ (instancetype)SIPURIWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName {
    return [[self alloc] initWithUser:user host:host displayName:displayName];
}

+ (nullable instancetype)SIPURIWithString:(NSString *)SIPURIString {
    return [[self alloc] initWithString:SIPURIString];
}

- (instancetype)initWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName port:(NSInteger)port {
    NSParameterAssert(user);
    NSParameterAssert(host);
    NSParameterAssert(displayName);
    self = [super init];
    if ((self != nil)) {
        _user = [user copy];
        _host = [host copy];
        _displayName = [displayName copy];
    }
    return self;
}

- (instancetype)initWithUser:(NSString *)user host:(NSString *)host displayName:(NSString *)displayName {
    return [self initWithUser:user host:host displayName:displayName port:0];
}

- (instancetype)init {
    return [self initWithUser:@"" host:@"" displayName:@""];
}

- (nullable instancetype)initWithString:(NSString *)SIPURIString {
    NSString *user = @"";
    NSString *host = @"";
    NSString *displayName = @"";

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s<sip:(.+@)?.+>'"];
    if ([predicate evaluateWithObject:SIPURIString]) {
        NSRange delimiterRange = [SIPURIString rangeOfString:@" <"];
        
        NSMutableCharacterSet *trimmingCharacterSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
        [trimmingCharacterSet addCharactersInString:@"\""];
        displayName = [[SIPURIString substringToIndex:delimiterRange.location] stringByTrimmingCharactersInSet:trimmingCharacterSet];
        
        NSRange userAndHostRange = [SIPURIString rangeOfString:@"<sip:" options:NSCaseInsensitiveSearch];
        userAndHostRange.location += 5;
        userAndHostRange.length = [SIPURIString length] - userAndHostRange.location - 1;
        NSString *userAndHost = [SIPURIString substringWithRange:userAndHostRange];
        
        NSRange atSignRange = [userAndHost rangeOfString:@"@" options:NSBackwardsSearch];
        if (atSignRange.location != NSNotFound) {
            user = [userAndHost substringToIndex:atSignRange.location];
            host = [userAndHost substringFromIndex:(atSignRange.location + 1)];
        } else {
            host = userAndHost;
        }
        
        return [self initWithUser:user host:host displayName:displayName];
    }
    
    if (![[AKSIPUserAgent sharedUserAgent] isStarted]) {
        return nil;
    }
    
    pjsip_name_addr *nameAddr;
    nameAddr = (pjsip_name_addr *)pjsip_parse_uri([[AKSIPUserAgent sharedUserAgent] pool],
                                                  (char *)[SIPURIString cStringUsingEncoding:NSUTF8StringEncoding],
                                                  [SIPURIString length], PJSIP_PARSE_URI_AS_NAMEADDR);
    if (nameAddr == NULL) {
        return nil;
    }
    
    displayName = [NSString stringWithPJString:nameAddr->display];
    
    pj_str_t *schemePJString = (pj_str_t *)pjsip_uri_get_scheme(nameAddr);
    NSString *scheme = [NSString stringWithPJString:*schemePJString];
    NSInteger port = 0;
    
    if ([scheme isEqualToString:@"sip"] || [scheme isEqualToString:@"sips"]) {
        pjsip_sip_uri *uri = (pjsip_sip_uri *)pjsip_uri_get_uri(nameAddr);
        
        user = [NSString stringWithPJString:uri->user];
        host = [NSString stringWithPJString:uri->host];
        port = uri->port;

    } else if ([scheme isEqualToString:@"tel"]) {
        // TODO(eofster): we really must have some kind of AKTelURI here instead.
        pjsip_tel_uri *uri = (pjsip_tel_uri *)pjsip_uri_get_uri(nameAddr);
        
        user = [NSString stringWithPJString:uri->number];

    } else {
        return nil;
    }
    
    return [self initWithUser:user host:host displayName:displayName port:port];
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
  AKSIPURI *newURI = [[AKSIPURI allocWithZone:zone] initWithUser:[self user] host:[self host] displayName:[self displayName]];
  [newURI setPort:[self port]];

  return newURI;
}

@end
