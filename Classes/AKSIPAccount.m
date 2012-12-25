//
//  AKSIPAccount.m
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

#import "AKSIPAccount.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"
#import "AKSIPCall.h"


const NSInteger kAKSIPAccountDefaultSIPProxyPort = 5060;
const NSInteger kAKSIPAccountDefaultReregistrationTime = 300;

NSString * const AKSIPAccountRegistrationDidChangeNotification = @"AKSIPAccountRegistrationDidChange";
NSString * const AKSIPAccountWillMakeCallNotification = @"AKSIPAccountWillMakeCall";

@implementation AKSIPAccount

- (void)setDelegate:(NSObject <AKSIPAccountDelegate> *)aDelegate {
    if (_delegate == aDelegate) {
        return;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (_delegate != nil) {
        [notificationCenter removeObserver:_delegate name:nil object:self];
    }
    
    if (aDelegate != nil) {
        if ([aDelegate respondsToSelector:@selector(SIPAccountRegistrationDidChange:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPAccountRegistrationDidChange:)
                                       name:AKSIPAccountRegistrationDidChangeNotification
                                     object:self];
        }
    }
    
    _delegate = aDelegate;
}

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
        pjsua_acc_set_registration([self identifier], PJ_TRUE);
        [self setOnline:YES];
    } else {
        [self setOnline:NO];
        pjsua_acc_set_registration([self identifier], PJ_FALSE);
    }
}

- (NSInteger)registrationStatus {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return 0;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info([self identifier], &accountInfo);
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
    
    status = pjsua_acc_get_info([self identifier], &accountInfo);
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
    
    status = pjsua_acc_get_info([self identifier], &accountInfo);
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
    
    status = pjsua_acc_get_info([self identifier], &accountInfo);
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
        pjsua_acc_set_online_status([self identifier], PJ_TRUE);
    } else {
        pjsua_acc_set_online_status([self identifier], PJ_FALSE);
    }
}

- (NSString *)onlineStatusText {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return nil;
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info([self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return nil;
    }
    
    return [NSString stringWithPJString:accountInfo.online_status_text];
}

+ (id)SIPAccountWithFullName:(NSString *)aFullName
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

- (id)initWithFullName:(NSString *)aFullName
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

- (id)init {
    return [self initWithFullName:nil SIPAddress:nil registrar:nil realm:nil username:nil];
}

- (void)dealloc {
    [self setDelegate:nil];
}

- (NSString *)description {
    return [self SIPAddress];
}

- (AKSIPCall *)makeCallTo:(AKSIPURI *)destinationURI {
    [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPAccountWillMakeCallNotification
                                                        object:self];
    
    pjsua_call_id callIdentifier;
    pj_str_t uri = [[destinationURI description] pjString];
    
    pj_status_t status = pjsua_call_make_call([self identifier], &uri, 0, NULL, NULL, &callIdentifier);
    AKSIPCall *theCall = nil;
    if (status == PJ_SUCCESS) {
        for (AKSIPCall *aCall in [[self calls] copy]) {
            if ([aCall identifier] == callIdentifier) {
                theCall = aCall;
                break;
            }
        }
    } else {
        NSLog(@"Error making call to %@ via account %@", destinationURI, self);
    }
    
    return theCall;
}

@end
