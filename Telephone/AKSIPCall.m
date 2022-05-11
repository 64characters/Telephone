//
//  AKSIPCall.m
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

#import "AKSIPCall.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPAccount.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"
#import "PJSUACallInfo.h"

#import "Telephone-Swift.h"

#define THIS_FILE "AKSIPCall.m"


@interface AKSIPCall () {
    URI *_remote;
    BOOL _incoming;
    BOOL _missed;
}

@property(nonatomic, getter=isMicrophoneMuted) BOOL microphoneMuted;

@end

@implementation AKSIPCall

- (void)setDelegate:(id<AKSIPCallDelegate>)aDelegate {
    if (_delegate == aDelegate) {
        return;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (_delegate != nil) {
        [notificationCenter removeObserver:_delegate name:nil object:self];
    }
    
    if (aDelegate != nil) {
        // Subscribe to notifications
        if ([aDelegate respondsToSelector:@selector(SIPCallCalling:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallCalling:)
                                       name:AKSIPCallCallingNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallIncoming:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallIncoming:)
                                       name:AKSIPCallIncomingNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallEarly:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallEarly:)
                                       name:AKSIPCallEarlyNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallConnecting:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallConnecting:)
                                       name:AKSIPCallConnectingNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallDidConfirm:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallDidConfirm:)
                                       name:AKSIPCallDidConfirmNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallDidDisconnect:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallDidDisconnect:)
                                       name:AKSIPCallDidDisconnectNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallMediaDidBecomeActive:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallMediaDidBecomeActive:)
                                       name:AKSIPCallMediaDidBecomeActiveNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallDidLocalHold:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallDidLocalHold:)
                                       name:AKSIPCallDidLocalHoldNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallDidRemoteHold:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallDidRemoteHold:)
                                       name:AKSIPCallDidRemoteHoldNotification
                                     object:self];
        }
        if ([aDelegate respondsToSelector:@selector(SIPCallTransferStatusDidChange:)]) {
            [notificationCenter addObserver:aDelegate
                                   selector:@selector(SIPCallTransferStatusDidChange:)
                                       name:AKSIPCallTransferStatusDidChangeNotification
                                     object:self];
        }
    }
    
    _delegate = aDelegate;
}

- (URI *)remote {
    return _remote;
}

- (BOOL)isIncoming {
    return _incoming;
}

- (BOOL)isMissed {
    return _missed;
}

- (void)setMissed:(BOOL)flag {
    _missed = flag;
}

- (BOOL)isActive {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    return (pjsua_call_is_active((pjsua_call_id)[self identifier])) ? YES : NO;
}

- (BOOL)isOnLocalHold {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info((pjsua_call_id)[self identifier], &callInfo);
    
    return (callInfo.media[0].status == PJSUA_CALL_MEDIA_LOCAL_HOLD) ? YES : NO;
}

- (BOOL)isOnRemoteHold {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info((pjsua_call_id)[self identifier], &callInfo);
    
    return (callInfo.media[0].status == PJSUA_CALL_MEDIA_REMOTE_HOLD) ? YES : NO;
}


#pragma mark -

- (instancetype)initWithSIPAccount:(AKSIPAccount *)account info:(PJSUACallInfo *)info {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _account = account;
    _identifier = info.identifier;

    _date = [NSDate date];

    _incoming = info.isIncoming;
    _missed = _incoming;
    _state = info.state;
    _stateText = info.stateText;
    _lastStatus = info.lastStatus;
    _lastStatusText = info.lastStatusText;
    _localURI = info.localURI;
    _remoteURI = info.remoteURI;
    _remote = [[URI alloc] initWithURI:_remoteURI];

    return self;
}

- (void)dealloc {
    [self setDelegate:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ <=> %@", [self localURI], [self remoteURI]];
}

- (void)answer {
    pj_status_t status = pjsua_call_answer((pjsua_call_id)[self identifier], PJSIP_SC_OK, NULL, NULL);
    if (status == PJ_SUCCESS) {
        self.missed = NO;
    } else {
        NSLog(@"Error answering call %@", self);
    }
}

- (void)hangUp {
    if (([self identifier] == kAKSIPUserAgentInvalidIdentifier) || ([self state] == kAKSIPCallDisconnectedState)) {
        return;
    }
    
    pj_status_t status = pjsua_call_hangup((pjsua_call_id)[self identifier], 0, NULL, NULL);
    if (status == PJ_SUCCESS) {
        self.missed = NO;
    } else {
        NSLog(@"Error hanging up call %@", self);
    }
}

- (void)attendedTransferToCall:(AKSIPCall *)destinationCall {
    [self setTransferStatus:kAKSIPUserAgentInvalidIdentifier];
    [self setTransferStatusText:@""];
    pj_status_t status = pjsua_call_xfer_replaces((pjsua_call_id)[self identifier],
                                                  (pjsua_call_id)[destinationCall identifier],
                                                  PJSUA_XFER_NO_REQUIRE_REPLACES,
                                                  NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error transfering call %@", self);
    }
}

- (void)sendRingingNotification {
    pj_status_t status = pjsua_call_answer((pjsua_call_id)[self identifier], PJSIP_SC_RINGING, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error sending ringing notification in call %@", self);
    }
}

- (void)replyWithTemporarilyUnavailable {
    pj_status_t status = pjsua_call_answer((pjsua_call_id)[self identifier], PJSIP_SC_TEMPORARILY_UNAVAILABLE, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error replying with 480 Temporarily Unavailable");
    }
}

- (void)replyWithBusyHere {
    pj_status_t status = pjsua_call_answer((pjsua_call_id)[self identifier], PJSIP_SC_BUSY_HERE, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error replying with 486 Busy Here");
    }
}

- (void)sendDTMFDigits:(NSString *)digits {
    pj_status_t status;
    pj_str_t pjDigits = [digits pjString];
    
    // Try to send RFC2833 DTMF first.
    status = pjsua_call_dial_dtmf((pjsua_call_id)[self identifier], &pjDigits);
    
    if (status != PJ_SUCCESS) {  // Okay, that didn't work. Send INFO DTMF.
        const pj_str_t kSIPINFO = pj_str("INFO");
        
        for (NSUInteger i = 0; i < [digits length]; ++i) {
            pjsua_msg_data messageData;
            pjsua_msg_data_init(&messageData);
            messageData.content_type = pj_str("application/dtmf-relay");
            
            NSString *messageBody = [NSString stringWithFormat:@"Signal=%C\r\nDuration=300",
                                     [digits characterAtIndex:i]];
            messageData.msg_body = [messageBody pjString];
            
            status = pjsua_call_send_request((pjsua_call_id)[self identifier], &kSIPINFO, &messageData);
            if (status != PJ_SUCCESS) {
                NSLog(@"Error sending DTMF");
            }
        }
    }
}

- (void)muteMicrophone {
    if ([self isMicrophoneMuted] || [self state] != kAKSIPCallConfirmedState) {
        return;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info((pjsua_call_id)[self identifier], &callInfo);
    
    pj_status_t status = pjsua_conf_disconnect(0, callInfo.media[0].stream.aud.conf_slot);
    if (status == PJ_SUCCESS) {
        [self setMicrophoneMuted:YES];
    } else {
        NSLog(@"Error muting microphone in call %@", self);
    }
}

- (void)unmuteMicrophone {
    if (![self isMicrophoneMuted] || [self state] != kAKSIPCallConfirmedState) {
        return;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info((pjsua_call_id)[self identifier], &callInfo);
    
    pj_status_t status = pjsua_conf_connect(0, callInfo.media[0].stream.aud.conf_slot);
    if (status == PJ_SUCCESS) {
        [self setMicrophoneMuted:NO];
    } else {
        NSLog(@"Error unmuting microphone in call %@", self);
    }
}

- (void)toggleMicrophoneMute {
    if ([self isMicrophoneMuted]) {
        [self unmuteMicrophone];
    } else {
        [self muteMicrophone];
    }
}

- (void)hold {
    if ([self state] == kAKSIPCallConfirmedState && ![self isOnRemoteHold]) {
        pjsua_call_set_hold((pjsua_call_id)[self identifier], NULL);
    }
}

- (void)unhold {
    if ([self state] == kAKSIPCallConfirmedState) {
        pjsua_call_reinvite((pjsua_call_id)[self identifier], PJ_TRUE, NULL);
    }
}

- (void)toggleHold {
    if ([self isOnLocalHold]) {
        [self unhold];
    } else {
        [self hold];
    }
}

@end
