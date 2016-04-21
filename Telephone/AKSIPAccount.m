//
//  AKSIPAccount.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#import "AKSIPAccount.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"
#import "AKSIPCall.h"


const NSInteger kAKSIPAccountDefaultSIPProxyPort = 5060;
const NSInteger kAKSIPAccountDefaultReregistrationTime = 300;

NSString * const AKSIPAccountWillMakeCallNotification = @"AKSIPAccountWillMakeCall";

@implementation AKSIPAccount

- (void)setProxyPort:(NSUInteger)port {
    if (port > 0 && port < 65535) {
        _proxyPort = port;
    } else {
        _proxyPort = kAKSIPAccountDefaultSIPProxyPort;
    }
}

- (void)setReregistrationTime:(NSUInteger)seconds {
    const NSInteger reregistrationTimeMin = 60;
    const NSInteger reregistrationTimeMax = 3600;
    if (seconds == 0) {
        _reregistrationTime = kAKSIPAccountDefaultReregistrationTime;
    } else if (seconds < reregistrationTimeMin) {
        _reregistrationTime = reregistrationTimeMin;
    } else if (seconds > reregistrationTimeMax) {
        _reregistrationTime = reregistrationTimeMax;
    } else {
        _reregistrationTime = seconds;
    }
}

- (BOOL)isRegistered {
    return ([self registrationStatus] / 100 == 2) && ([self registrationExpireTime] > 0);
}

- (void)setRegistered:(BOOL)value {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return;
    }
    
    if (value) {
        pjsua_acc_set_registration((pjsua_acc_id)[self identifier], PJ_TRUE);
        [self setOnline:YES];
    } else {
        [self setOnline:NO];
        pjsua_acc_set_registration((pjsua_acc_id)[self identifier], PJ_FALSE);
    }
}

- (NSInteger)registrationStatus {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return 0;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return 0;
    }
    
    return accountInfo.status;
}

- (NSString *)registrationStatusText {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return nil;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return nil;
    }
    
    return [NSString stringWithPJString:accountInfo.status_text];
}

- (NSInteger)registrationExpireTime {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return -1;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return -1;
    }
    
    return accountInfo.expires;
}

- (BOOL)isOnline {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    return (accountInfo.online_status == PJ_TRUE) ? YES : NO;
}

- (void)setOnline:(BOOL)value {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return;
    }
    
    if (value) {
        pjsua_acc_set_online_status((pjsua_acc_id)[self identifier], PJ_TRUE);
    } else {
        pjsua_acc_set_online_status((pjsua_acc_id)[self identifier], PJ_FALSE);
    }
}

- (NSString *)onlineStatusText {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return nil;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return nil;
    }
    
    return [NSString stringWithPJString:accountInfo.online_status_text];
}

+ (instancetype)SIPAccountWithFullName:(NSString *)aFullName
                            SIPAddress:(NSString *)aSIPAddress
                             registrar:(NSString *)aRegistrar
                                 realm:(NSString *)aRealm
                              username:(NSString *)aUsername {
    
    return [[AKSIPAccount alloc] initWithFullName:aFullName
                                       SIPAddress:aSIPAddress
                                        registrar:aRegistrar
                                            realm:aRealm
                                         username:aUsername];
}

- (instancetype)initWithFullName:(NSString *)aFullName
                      SIPAddress:(NSString *)aSIPAddress
                       registrar:(NSString *)aRegistrar
                           realm:(NSString *)aRealm
                        username:(NSString *)aUsername {
    
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    [self setRegistrationURI:[AKSIPURI SIPURIWithString:[NSString stringWithFormat:@"\"%@\" <sip:%@>",
                                                         aFullName, aSIPAddress]]];
    
    [self setFullName:aFullName];
    [self setSIPAddress:aSIPAddress];
    [self setRegistrar:aRegistrar];
    [self setRealm:aRealm];
    [self setUsername:aUsername];
    [self setProxyPort:kAKSIPAccountDefaultSIPProxyPort];
    [self setReregistrationTime:kAKSIPAccountDefaultReregistrationTime];
    [self setIdentifier:kAKSIPUserAgentInvalidIdentifier];
    
    _calls = [[NSMutableArray alloc] init];
    
    return self;
}

- (instancetype)init {
    return [self initWithFullName:nil SIPAddress:nil registrar:nil realm:nil username:nil];
}

- (NSString *)description {
    return [self SIPAddress];
}

- (AKSIPCall *)makeCallTo:(AKSIPURI *)destinationURI {
    [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPAccountWillMakeCallNotification
                                                        object:self];
    
    pjsua_call_id callIdentifier;
    pj_str_t uri = [[destinationURI description] pjString];
    
    pj_status_t status = pjsua_call_make_call((pjsua_acc_id)[self identifier], &uri, 0, NULL, NULL, &callIdentifier);
    AKSIPCall *call = nil;
    if (status == PJ_SUCCESS) {
        call = [[AKSIPCall alloc] initWithSIPAccount:self identifier:callIdentifier];
        [self.calls addObject:call];
    } else {
        NSLog(@"Error making call to %@ via account %@", destinationURI, self);
    }
    
    return call;
}

@end
