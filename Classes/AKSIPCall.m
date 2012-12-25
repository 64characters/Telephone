//
//  AKSIPCall.m
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

#import "AKSIPCall.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPAccount.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"

#define THIS_FILE "AKSIPCall.m"


const NSInteger kAKSIPCallsMax = 8;

NSString * const AKSIPCallCallingNotification = @"AKSIPCallCalling";
NSString * const AKSIPCallIncomingNotification = @"AKSIPCallIncoming";
NSString * const AKSIPCallEarlyNotification = @"AKSIPCallEarly";
NSString * const AKSIPCallConnectingNotification = @"AKSIPCallConnecting";
NSString * const AKSIPCallDidConfirmNotification = @"AKSIPCallDidConfirm";
NSString * const AKSIPCallDidDisconnectNotification = @"AKSIPCallDidDisconnect";
NSString * const AKSIPCallMediaDidBecomeActiveNotification = @"AKSIPCallMediaDidBecomeActive";
NSString * const AKSIPCallDidLocalHoldNotification = @"AKSIPCallDidLocalHold";
NSString * const AKSIPCallDidRemoteHoldNotification = @"AKSIPCallDidRemoteHold";
NSString * const AKSIPCallTransferStatusDidChangeNotification = @"AKSIPCallTransferStatusDidChange";

@implementation AKSIPCall

- (void)setDelegate:(id)aDelegate {
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

- (BOOL)isActive {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    return (pjsua_call_is_active([self identifier])) ? YES : NO;
}

- (BOOL)hasMedia {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    return (pjsua_call_has_media([self identifier])) ? YES : NO;
}

- (BOOL)hasActiveMedia {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info([self identifier], &callInfo);
    
    return (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) ? YES : NO;
}

- (BOOL)isOnLocalHold {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info([self identifier], &callInfo);
    
    return (callInfo.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) ? YES : NO;
}

- (BOOL)isOnRemoteHold {
    if ([self identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return NO;
    }
    
    pjsua_call_info callInfo;
    pjsua_call_get_info([self identifier], &callInfo);
    
    return (callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) ? YES : NO;
}


#pragma mark -

- (id)initWithSIPAccount:(AKSIPAccount *)anAccount identifier:(NSInteger)anIdentifier {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    [self setIdentifier:anIdentifier];
    [self setAccount:anAccount];
    
    pjsua_call_info callInfo;
    pj_status_t status = pjsua_call_get_info(anIdentifier, &callInfo);
    if (status == PJ_SUCCESS) {
        [self setState:callInfo.state];
        [self setStateText:[NSString stringWithPJString:callInfo.state_text]];
        [self setLastStatus:callInfo.last_status];
        [self setLastStatusText:[NSString stringWithPJString:callInfo.last_status_text]];
        [self setRemoteURI:[AKSIPURI SIPURIWithString:[NSString stringWithPJString:callInfo.remote_info]]];
        [self setLocalURI:[AKSIPURI SIPURIWithString:[NSString stringWithPJString:callInfo.local_info]]];
        
        if (callInfo.state == kAKSIPCallIncomingState) {
            [self setIncoming:YES];
        } else {
            [self setIncoming:NO];
        }
        
    } else {
        [self setState:kAKSIPCallNullState];
        [self setIncoming:NO];
    }
    
    return self;
}

- (id)init {
    return [self initWithSIPAccount:nil identifier:kAKSIPUserAgentInvalidIdentifier];
}

- (void)dealloc {
    if ([[AKSIPUserAgent sharedUserAgent] isStarted]) {
        [self hangUp];
    }
    
    [self setDelegate:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ <=> %@", [self localURI], [self remoteURI]];
}

- (void)answer {
    pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_OK, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error answering call %@", self);
    }
}

- (void)hangUp {
    if (([self identifier] == kAKSIPUserAgentInvalidIdentifier) || ([self state] == kAKSIPCallDisconnectedState)) {
        return;
    }
    
    pj_status_t status = pjsua_call_hangup([self identifier], 0, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error hanging up call %@", self);
    }
}

- (void)attendedTransferToCall:(AKSIPCall *)destinationCall {
    [self setTransferStatus:kAKSIPUserAgentInvalidIdentifier];
    [self setTransferStatusText:nil];
    pj_status_t status = pjsua_call_xfer_replaces([self identifier],
                                                  [destinationCall identifier],
                                                  PJSUA_XFER_NO_REQUIRE_REPLACES,
                                                  NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error transfering call %@", self);
    }
}

- (void)sendRingingNotification {
    pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_RINGING, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error sending ringing notification in call %@", self);
    }
}

- (void)replyWithTemporarilyUnavailable {
    pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_TEMPORARILY_UNAVAILABLE, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error replying with 480 Temporarily Unavailable");
    }
}

- (void)replyWithBusyHere {
    pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_BUSY_HERE, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error replying with 486 Busy Here");
    }
}

- (void)ringbackStart {
    AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
    
    // Use dot syntax for properties to prevent square bracket clutter.
    if (userAgent.callData[self.identifier].ringbackOn) {
        return;
    }
    
    userAgent.callData[self.identifier].ringbackOn = PJ_TRUE;
    
    [userAgent setRingbackCount:[userAgent ringbackCount] + 1];
    if ([userAgent ringbackCount] == 1 && [userAgent ringbackSlot] != kAKSIPUserAgentInvalidIdentifier) {
        pjsua_conf_connect([userAgent ringbackSlot], 0);
    }
}

- (void)ringbackStop {
    AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
    
    // Use dot syntax for properties to prevent square bracket clutter.
    if (userAgent.callData[self.identifier].ringbackOn) {
        userAgent.callData[self.identifier].ringbackOn = PJ_FALSE;
        
        pj_assert([userAgent ringbackCount] > 0);
        
        [userAgent setRingbackCount:[userAgent ringbackCount] - 1];
        if ([userAgent ringbackCount] == 0 &&
            [userAgent ringbackSlot] != kAKSIPUserAgentInvalidIdentifier) {
            pjsua_conf_disconnect([userAgent ringbackSlot], 0);
            pjmedia_tonegen_rewind([userAgent ringbackPort]);
        }
    }
}

- (void)sendDTMFDigits:(NSString *)digits {
    pj_status_t status;
    pj_str_t pjDigits = [digits pjString];
    
    // Try to send RFC2833 DTMF first.
    status = pjsua_call_dial_dtmf([self identifier], &pjDigits);
    
    if (status != PJ_SUCCESS) {  // Okay, that didn't work. Send INFO DTMF.
        const pj_str_t kSIPINFO = pj_str("INFO");
        
        for (NSUInteger i = 0; i < [digits length]; ++i) {
            pjsua_msg_data messageData;
            pjsua_msg_data_init(&messageData);
            messageData.content_type = pj_str("application/dtmf-relay");
            
            NSString *messageBody = [NSString stringWithFormat:@"Signal=%C\r\nDuration=300",
                                     [digits characterAtIndex:i]];
            messageData.msg_body = [messageBody pjString];
            
            status = pjsua_call_send_request([self identifier], &kSIPINFO, &messageData);
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
    pjsua_call_get_info([self identifier], &callInfo);
    
    pj_status_t status = pjsua_conf_disconnect(0, callInfo.conf_slot);
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
    pjsua_call_get_info([self identifier], &callInfo);
    
    pj_status_t status = pjsua_conf_connect(0, callInfo.conf_slot);
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
        pjsua_call_set_hold([self identifier], NULL);
    }
}

- (void)unhold {
    if ([self state] == kAKSIPCallConfirmedState) {
        pjsua_call_reinvite([self identifier], PJ_TRUE, NULL);
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
