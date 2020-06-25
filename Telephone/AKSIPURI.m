//
//  AKSIPURI.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

@import UseCases;

#import <pjsua-lib/pjsua.h>

#import "AKNSString+PJSUA.h"
#import "AKSIPUserAgent.h"

@implementation AKSIPURI

- (NSString *)SIPAddress {
    return [[SIPAddress alloc] initWithUser:self.user host:self.host].stringValue;
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
    
    pjsip_name_addr * __block nameAddr;
    dispatch_sync(AKSIPUserAgent.sharedUserAgent.poolQueue, ^{
        nameAddr = (pjsip_name_addr *)pjsip_parse_uri([[AKSIPUserAgent sharedUserAgent] poolResettingIfNeeded],
                                                      (char *)[SIPURIString cStringUsingEncoding:NSUTF8StringEncoding],
                                                      [SIPURIString length], PJSIP_PARSE_URI_AS_NAMEADDR);
    });
    if (nameAddr == NULL) {
        return nil;
    }
    
    displayName = [NSString stringWithPJString:nameAddr->display];
    
    NSInteger port = 0;
    
    if (PJSIP_URI_SCHEME_IS_SIP(nameAddr) || PJSIP_URI_SCHEME_IS_SIPS(nameAddr)) {
        pjsip_sip_uri *uri = (pjsip_sip_uri *)pjsip_uri_get_uri(nameAddr);
        
        user = [NSString stringWithPJString:uri->user];
        host = [NSString stringWithPJString:uri->host];
        port = uri->port;

    } else if (PJSIP_URI_SCHEME_IS_TEL(nameAddr)) {
        // TODO(eofster): we really must have some kind of AKTelURI here instead.
        pjsip_tel_uri *uri = (pjsip_tel_uri *)pjsip_uri_get_uri(nameAddr);
        
        user = [NSString stringWithPJString:uri->number];

    } else {
        return nil;
    }
    
    return [self initWithUser:user host:host displayName:displayName port:port];
}

- (NSString *)description {
    NSString *port = self.port > 0 ? @(self.port).stringValue : @"";
    return [[URI alloc] initWithUser:self.user
                             address:[[ServiceAddress alloc] initWithHost:self.host port:port]
                         displayName:self.displayName
                           transport:TransportUDP].stringValue;
}


#pragma mark -
#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone {
    return [[AKSIPURI allocWithZone:zone] initWithUser:self.user
                                                  host:self.host
                                           displayName:self.displayName
                                                  port:self.port];
}

@end
