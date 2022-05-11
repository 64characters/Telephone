//
//  AKSIPAccount.m
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

#import "AKSIPAccount.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"
#import "AKSIPCall.h"
#import "PJSUACallInfo.h"

#import "Telephone-Swift.h"

NS_ASSUME_NONNULL_BEGIN

const NSInteger kAKSIPAccountDefaultSIPProxyPort = 0;
const NSInteger kAKSIPAccountDefaultReregistrationTime = 300;
const Transport kAKSIPAccountDefaultTransport = TransportUDP;
const NSInteger kAKSIPAccountRegistrationExpireTimeNotSpecified = PJSIP_EXPIRES_NOT_SPECIFIED;

@interface AKSIPCallParameters : NSObject

@property(nonatomic, readonly) URI *destination;
@property(nonatomic, readonly) pjsua_acc_id account;
@property(nonatomic, readonly) void (^ _Nonnull completion)(BOOL, PJSUACallInfo *);

- (instancetype)initWithDestination:(URI *)destination
                            account:(pjsua_acc_id)account
                         completion:(void (^ _Nonnull)(BOOL, PJSUACallInfo *))completion;

@end

@interface AKSIPAccount () {
    NSString *_uuid;
}

@property(nonatomic, copy) NSString *username;
@property(nonatomic) NSInteger identifier;

@property(nonatomic, readonly) NSMutableArray *calls;
@property(nonatomic, readonly) AKSIPURIParser *parser;

@end

NS_ASSUME_NONNULL_END

@implementation AKSIPAccount

- (NSString *)uuid {
    return _uuid;
}

- (void)setProxyPort:(NSUInteger)port {
    if (port >= 0 && port <= 65535) {
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
    return [self registrationStatus] / 100 == 2 && [self registrationExpireTime] != kAKSIPAccountRegistrationExpireTimeNotSpecified;
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

- (NSInteger)registrationErrorCode {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return 0;
    }

    pjsua_acc_info accountInfo;
    pj_status_t status;

    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return 0;
    }

    return accountInfo.reg_last_err;
}

- (NSString *)registrationStatusText {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return @"";
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return @"";
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
        return @"";
    }
    
    pjsua_acc_info accountInfo;
    pj_status_t status;
    
    status = pjsua_acc_get_info((pjsua_acc_id)[self identifier], &accountInfo);
    if (status != PJ_SUCCESS) {
        return @"";
    }
    
    return [NSString stringWithPJString:accountInfo.online_status_text];
}

- (BOOL)hasUnansweredIncomingCalls {
    for (AKSIPCall *call in self.calls) {
        if (call.isActive &&
            call.isIncoming &&
            (call.state == kAKSIPCallIncomingState || call.state == kAKSIPCallEarlyState)) {
            return YES;
        }
    }
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict parser:(AKSIPURIParser *)parser {
    NSParameterAssert([dict[AKSIPAccountKeys.uuid] length] > 0);
    NSParameterAssert(dict[AKSIPAccountKeys.fullName]);
    NSParameterAssert(dict[AKSIPAccountKeys.realm]);
    NSParameterAssert(dict[AKSIPAccountKeys.username]);
    NSParameterAssert(dict[AKSIPAccountKeys.domain]);
    
    self = [super init];
    if (self == nil) {
        return nil;
    }

    SIPAddress *address = nil;
    if ([dict[AKSIPAccountKeys.sipAddress] length] > 0) {
        address = [[SIPAddress alloc] initWithString:dict[AKSIPAccountKeys.sipAddress]];
    } else {
        address = [[SIPAddress alloc] initWithUser:dict[AKSIPAccountKeys.username] host:dict[AKSIPAccountKeys.domain]];
    }

    _uuid = [dict[AKSIPAccountKeys.uuid] copy];
    if ([dict[AKSIPAccountKeys.transport] isEqualToString:AKSIPAccountKeys.transportTCP]) {
        _transport = TransportTCP;
    } else if ([dict[AKSIPAccountKeys.transport] isEqualToString:AKSIPAccountKeys.transportTLS]) {
        _transport = TransportTLS;
    } else {
        _transport = TransportUDP;
    }
    _uri = [[URI alloc] initWithUser:address.user
                                host:address.host
                         displayName:dict[AKSIPAccountKeys.fullName]
                           transport:_transport];

    _fullName = [dict[AKSIPAccountKeys.fullName] copy];
    _SIPAddress = address.stringValue;
    _registrar = [[ServiceAddress alloc] initWithString:([dict[AKSIPAccountKeys.registrar] length] > 0 ?
                                                         dict[AKSIPAccountKeys.registrar] :
                                                         dict[AKSIPAccountKeys.domain])];
    _realm = [dict[AKSIPAccountKeys.realm] copy];
    _username = [dict[AKSIPAccountKeys.username] copy];
    _domain = [dict[AKSIPAccountKeys.domain] copy];
    if ([dict[AKSIPAccountKeys.useProxy] boolValue]) {
        _proxyHost = [dict[AKSIPAccountKeys.proxyHost] copy];
        self.proxyPort = [dict[AKSIPAccountKeys.proxyPort] integerValue];
    }
    self.reregistrationTime = [dict[AKSIPAccountKeys.reregistrationTime] integerValue];
    _usesIPv6 = [dict[AKSIPAccountKeys.ipVersion] isEqualToString:AKSIPAccountKeys.ipVersion6];
    _updatesContactHeader = [dict[AKSIPAccountKeys.updateContactHeader] boolValue];
    _updatesViaHeader = [dict[AKSIPAccountKeys.updateViaHeader] boolValue];
    _updatesSDP = [dict[AKSIPAccountKeys.updateSDP] boolValue];

    _identifier = kAKSIPUserAgentInvalidIdentifier;
    
    _calls = [[NSMutableArray alloc] init];
    _parser = parser;
    
    return self;
}

- (NSString *)description {
    return [self SIPAddress];
}

- (void)updateUsername:(NSString *)username {
    self.username = username;
}

- (void)updateIdentifier:(NSInteger)identifier {
    self.identifier = identifier;
}

- (void)makeCallTo:(URI *)uri label:(NSString *)label {
    NSLog(@"Not calling %@", uri);
}

- (void)makeCallTo:(AKSIPURI *)destination completion:(void (^ _Nonnull)(AKSIPCall * _Nullable))completion {
    URI *uri = [[URI alloc] initWithURI:destination transport:self.transport];
    void (^onCallMakeCompletion)(BOOL, PJSUACallInfo *) = ^(BOOL success, PJSUACallInfo *call) {
        if (success) {
            completion([self addCallWithInfo:call]);
        } else {
            NSLog(@"Error making call to %@ via account %@", uri, self);
            completion(nil);
        }
    };
    AKSIPCallParameters *parameters = [[AKSIPCallParameters alloc] initWithDestination:uri
                                                                               account:(pjsua_acc_id)self.identifier
                                                                            completion:onCallMakeCompletion];
    assert(self.thread);
    [self performSelector:@selector(thread_makeCallWithParameters:) onThread:self.thread withObject:parameters waitUntilDone:NO];
}

- (void)thread_makeCallWithParameters:(AKSIPCallParameters *)parameters {
    pj_str_t uri = parameters.destination.stringValue.pjString;
    pjsua_call_id callID = PJSUA_INVALID_ID;
    BOOL success = pjsua_call_make_call(parameters.account, &uri, 0, NULL, NULL, &callID) == PJ_SUCCESS;
    PJSUACallInfo *infoWrapper = nil;
    if (success) {
        pjsua_call_info info;
        success = pjsua_call_get_info(callID, &info) == PJ_SUCCESS;
        if (success) {
            infoWrapper = [[PJSUACallInfo alloc] initWithInfo:info parser:self.parser];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        parameters.completion(success, infoWrapper);
    });
}

- (AKSIPCall *)addCallWithInfo:(PJSUACallInfo *)info {
    AKSIPCall *call = [self callWithIdentifier:info.identifier];
    if (!call) {
        call = [[AKSIPCall alloc] initWithSIPAccount:self info:info];
        [self.calls addObject:call];
    }
    return call;
}

- (nullable AKSIPCall *)callWithIdentifier:(NSInteger)identifier {
    for (AKSIPCall *call in self.calls) {
        if (call.identifier == identifier) {
            return call;
        }
    }
    return nil;
}

- (void)removeCall:(AKSIPCall *)call {
    [self.calls removeObject:call];
}

- (void)removeAllCalls {
    [self.calls removeAllObjects];
}

- (NSInteger)activeCallsCount {
    NSInteger count = 0;
    for (AKSIPCall *call in self.calls) {
        if (call.isActive) {
            count++;
        }
    }
    return count;
}

@end

@implementation AKSIPCallParameters

- (instancetype)initWithDestination:(URI *)destination
                            account:(pjsua_acc_id)account
                         completion:(void (^ _Nonnull)(BOOL, PJSUACallInfo *))completion {
    if ((self = [super init])) {
        _destination = destination;
        _account = account;
        _completion = completion;
    }
    return self;
}

@end
