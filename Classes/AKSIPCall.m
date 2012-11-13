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
NSString * const AKSIPCallMediaDidBecomeActiveNotification
  = @"AKSIPCallMediaDidBecomeActive";
NSString * const AKSIPCallDidLocalHoldNotification = @"AKSIPCallDidLocalHold";
NSString * const AKSIPCallDidRemoteHoldNotification = @"AKSIPCallDidRemoteHold";
NSString * const AKSIPCallTransferStatusDidChangeNotification
  = @"AKSIPCallTransferStatusDidChange";

@implementation AKSIPCall

@synthesize delegate = delegate_;
@synthesize identifier = identifier_;
@synthesize localURI = localURI_;
@synthesize remoteURI = remoteURI_;
@synthesize state = state_;
@synthesize stateText = stateText_;
@synthesize lastStatus = lastStatus_;
@synthesize lastStatusText = lastStatusText_;
@synthesize transferStatus = transferStatus_;
@synthesize transferStatusText = transferStatusText_;
@dynamic active;
@dynamic hasMedia;
@dynamic hasActiveMedia;
@synthesize incoming = incoming_;
@synthesize microphoneMuted = microphoneMuted_;
@dynamic onLocalHold;
@dynamic onRemoteHold;
@synthesize account = account_;

- (void)setDelegate:(id)aDelegate {
  if (delegate_ == aDelegate) {
    return;
  }
  
  NSNotificationCenter *notificationCenter
    = [NSNotificationCenter defaultCenter];
  
  if (delegate_ != nil) {
    [notificationCenter removeObserver:delegate_ name:nil object:self];
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
    if ([aDelegate respondsToSelector:
         @selector(SIPCallMediaDidBecomeActive:)]) {
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
    if ([aDelegate respondsToSelector:
         @selector(SIPCallTransferStatusDidChange:)]) {
      [notificationCenter
       addObserver:aDelegate
          selector:@selector(SIPCallTransferStatusDidChange:)
              name:AKSIPCallTransferStatusDidChangeNotification
            object:self];
    }
  }
  
  delegate_ = aDelegate;
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

- (id)initWithSIPAccount:(AKSIPAccount *)anAccount
              identifier:(NSInteger)anIdentifier {
  
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
    [self setLastStatusText:
     [NSString stringWithPJString:callInfo.last_status_text]];
    [self setRemoteURI:[AKSIPURI SIPURIWithString:
                        [NSString stringWithPJString:callInfo.remote_info]]];
    [self setLocalURI:[AKSIPURI SIPURIWithString:
                       [NSString stringWithPJString:callInfo.local_info]]];
    
    if (callInfo.state == kAKSIPCallIncomingState) {
      [self setIncoming:YES];
    } else {
      [self setIncoming:NO];
    }
    
  } else {
    [self setState:kAKSIPCallNullState];
    [self setIncoming:NO];
  }
  
  // will be lazy created when/if needed
  pool_ = NULL;
  
  // will be lazy created when/if needed
  tonegen_ = NULL;
  
  return self;
}

- (id)init {
  return [self initWithSIPAccount:nil
                       identifier:kAKSIPUserAgentInvalidIdentifier];
}

- (void)dealloc {
  if ([[AKSIPUserAgent sharedUserAgent] isStarted]) {
    [self hangUp];
  }

  // was used, so clean up
  if (tonegen_) {
    pjsua_conf_remove_port(toneslot_);
    pjmedia_port_destroy(tonegen_);
  }
  
  // was used, so clean up
  if (pool_) {
    pj_pool_release(pool_);
  }
  
  [self setDelegate:nil];
  
  [localURI_ release];
  [remoteURI_ release];
  [stateText_ release];
  [lastStatusText_ release];
  [transferStatusText_ release];
  
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ <=> %@", [self localURI],
          [self remoteURI]];
}

- (void)answer {
  pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_OK,
                                         NULL, NULL);
  if (status != PJ_SUCCESS) {
    NSLog(@"Error answering call %@", self);
  }
}

- (void)hangUp {
  if (([self identifier] == kAKSIPUserAgentInvalidIdentifier) ||
      ([self state] == kAKSIPCallDisconnectedState)) {
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
  pj_status_t status
    = pjsua_call_xfer_replaces([self identifier],
                               [destinationCall identifier],
                               PJSUA_XFER_NO_REQUIRE_REPLACES,
                               NULL);
  if (status != PJ_SUCCESS) {
    NSLog(@"Error transfering call %@", self);
  }
}

- (void)sendRingingNotification {
  pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_RINGING,
                                         NULL, NULL);
  if (status != PJ_SUCCESS) {
    NSLog(@"Error sending ringing notification in call %@", self);
  }
}

- (void)replyWithTemporarilyUnavailable {
  pj_status_t status = pjsua_call_answer([self identifier],
                                         PJSIP_SC_TEMPORARILY_UNAVAILABLE,
                                         NULL, NULL);
  if (status != PJ_SUCCESS) {
    NSLog(@"Error replying with 480 Temporarily Unavailable");
  }
}

- (void)replyWithBusyHere {
  pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_BUSY_HERE,
                                         NULL, NULL);
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
  if ([userAgent ringbackCount] == 1 &&
      [userAgent ringbackSlot] != kAKSIPUserAgentInvalidIdentifier) {
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

- (pj_status_t)initTonegen
{
  // lazy create a mem pool
  if (pool_ == NULL) {
    pool_ = pjsua_pool_create("Call", 512, 512);
    if (pool_ == NULL) return -1;
  }
  // lazy create/connect tonegen
  if (tonegen_ == NULL) {
    pjsua_call_info ci;
    pj_status_t status = pjsua_call_get_info([self identifier], &ci);
    if (status != PJ_SUCCESS) return status;
    status = pjmedia_tonegen_create(pool_, 8000, 1, 160, 16, 0, &tonegen_);
    if (status != PJ_SUCCESS) return status;
    status = pjsua_conf_add_port(pool_, tonegen_, &toneslot_);
    if (status != PJ_SUCCESS) return status;
    status = pjsua_conf_connect(toneslot_, ci.conf_slot);
    return status;
  }
  return PJ_SUCCESS;
}

- (void)sendDTMFDigits:(NSString *)digits {
  pj_status_t status;
  
  // Try to send DTMF inband if account is configured so
  if ([account_ inbandDTMF]) {
    status = PJ_SUCCESS;
    // lazy init the tonegen
    if (tonegen_ == NULL) {
      status = [self initTonegen];
    }
    if (status == PJ_SUCCESS) {
      // it may probably be more efficient to use an array of pjmedia_tone_digit
      // and not call pjmedia_tonegen_play_digits in a loop
      pjmedia_tone_digit tone;
      tone.on_msec = 100;
      tone.off_msec = 200;
      // 0 is the default, PJMEDIA_TONEGEN_VOLUME will be used
      tone.volume = 0;
      NSUInteger count = [digits length];
      for (NSUInteger i = 0; i < count; i++) {
         // should be safe to cast unichar to char here, since dtmf is only digits, *, #, a-d
        tone.digit = (char)[digits characterAtIndex:i];
        status = pjmedia_tonegen_play_digits(tonegen_, 1, &tone, 0);
        if (status != PJ_SUCCESS) break;
      }
      if (status == PJ_SUCCESS) return;
    }
  }
  
  pj_str_t pjDigits = [digits pjString];
  
  // Try to send RFC2833 DTMF first.
  status = pjsua_call_dial_dtmf([self identifier], &pjDigits);
  
  if (status != PJ_SUCCESS) {  // Okay, that didn't work. Send INFO DTMF.
    const pj_str_t kSIPINFO = pj_str("INFO");
    
    for (NSUInteger i = 0; i < [digits length]; ++i) {
      pjsua_msg_data messageData;
      pjsua_msg_data_init(&messageData);
      messageData.content_type = pj_str("application/dtmf-relay");
      
      NSString *messageBody
        = [NSString stringWithFormat:@"Signal=%C\r\nDuration=300",
           [digits characterAtIndex:i]];
      messageData.msg_body = [messageBody pjString];
      
      status = pjsua_call_send_request([self identifier],
                                       &kSIPINFO,
                                       &messageData);
      if (status != PJ_SUCCESS) {
        NSLog(@"Error sending DTMF");
      }
    }
  }
}

- (void)muteMicrophone {
  if ([self isMicrophoneMuted] ||
      [self state] != kAKSIPCallConfirmedState) {
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
  if (![self isMicrophoneMuted] ||
      [self state] != kAKSIPCallConfirmedState) {
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
