//
//  AKSIPURIParser.m
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

#import "AKSIPURIParser.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"

@implementation AKSIPURIParser

- (instancetype)initWithUserAgent:(AKSIPUserAgent *)agent {
    NSParameterAssert(agent);
    if ((self = [super init])) {
        _agent = agent;
    }
    return self;
}

- (nullable AKSIPURI *)SIPURIFromString:(NSString *)string {
    if (!self.agent.isStarted) {
        return nil;
    }

    pj_pool_t *pool = pjsua_pool_create("AKSIPUserAgent-uri-parsing-tmp", 512, 512);
    if (!pool) {
        return nil;
    }
    pjsip_name_addr *nameAddr = (pjsip_name_addr *)pjsip_parse_uri(pool,
                                                                   (char *)[string cStringUsingEncoding:NSUTF8StringEncoding],
                                                                   [string length],
                                                                   PJSIP_PARSE_URI_AS_NAMEADDR);
    if (nameAddr == NULL) {
        pj_pool_release(pool);
        return nil;
    }

    NSString *displayName = [NSString stringWithPJString:nameAddr->display];

    NSString *user = @"";
    NSString *host = @"";
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
        pj_pool_release(pool);
        return nil;
    }

    pj_pool_release(pool);

    return [[AKSIPURI alloc] initWithUser:user host:host displayName:displayName port:port];
}

@end
