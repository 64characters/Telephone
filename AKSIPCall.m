//
//  AKSIPCall.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
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

@implementation AKSIPCall

@synthesize delegate = delegate_;
@synthesize identifier = identifier_;
@synthesize localURI = localURI_;
@synthesize remoteURI = remoteURI_;
@synthesize state = state_;
@synthesize stateText = stateText_;
@synthesize lastStatus = lastStatus_;
@synthesize lastStatusText = lastStatusText_;
@dynamic active;
@dynamic hasMedia;
@dynamic hasActiveMedia;
@synthesize incoming = incoming_;
@synthesize microphoneMuted = microphoneMuted_;
@dynamic onLocalHold;
@dynamic onRemoteHold;
@synthesize account = account_;

- (void)setDelegate:(id)aDelegate {
  if (delegate_ == aDelegate)
    return;
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  if (delegate_ != nil)
    [notificationCenter removeObserver:delegate_ name:nil object:self];
  
  if (aDelegate != nil) {
    // Subscribe to notifications
    if ([aDelegate respondsToSelector:@selector(SIPCallCalling:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallCalling:)
                                 name:AKSIPCallCallingNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallIncoming:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallIncoming:)
                                 name:AKSIPCallIncomingNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallEarly:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallEarly:)
                                 name:AKSIPCallEarlyNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallConnecting:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallConnecting:)
                                 name:AKSIPCallConnectingNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallDidConfirm:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallDidConfirm:)
                                 name:AKSIPCallDidConfirmNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallDidDisconnect:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallDidDisconnect:)
                                 name:AKSIPCallDidDisconnectNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallMediaDidBecomeActive:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallMediaDidBecomeActive:)
                                 name:AKSIPCallMediaDidBecomeActiveNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallDidLocalHold:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallDidLocalHold:)
                                 name:AKSIPCallDidLocalHoldNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(SIPCallDidRemoteHold:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(SIPCallDidRemoteHold:)
                                 name:AKSIPCallDidRemoteHoldNotification
                               object:self];
  }
  
  delegate_ = aDelegate;
}

- (BOOL)isActive {
  if ([self identifier] == kAKSIPUserAgentInvalidIdentifier)
    return NO;
  
  return (pjsua_call_is_active([self identifier])) ? YES : NO;
}

- (BOOL)hasMedia {
  if ([self identifier] == kAKSIPUserAgentInvalidIdentifier)
    return NO;
  
  return (pjsua_call_has_media([self identifier])) ? YES : NO;
}

- (BOOL)hasActiveMedia {
  if ([self identifier] == kAKSIPUserAgentInvalidIdentifier)
    return NO;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info([self identifier], &callInfo);
  
  return (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) ? YES : NO;
}

- (BOOL)isOnLocalHold {
  if ([self identifier] == kAKSIPUserAgentInvalidIdentifier)
    return NO;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info([self identifier], &callInfo);
  
  return (callInfo.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) ? YES : NO;
}

- (BOOL)isOnRemoteHold {
  if ([self identifier] == kAKSIPUserAgentInvalidIdentifier)
    return NO;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info([self identifier], &callInfo);
  
  return (callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) ? YES : NO;
}


#pragma mark -

- (id)initWithSIPAccount:(AKSIPAccount *)anAccount
              identifier:(NSInteger)anIdentifier {
  self = [super init];
  if (self == nil)
    return nil;
  
  [self setIdentifier:anIdentifier];
  [self setAccount:anAccount];
  
  pjsua_call_info callInfo;
  pjsua_call_get_info(anIdentifier, &callInfo);
  [self setRemoteURI:[AKSIPURI SIPURIWithString:
                      [NSString stringWithPJString:callInfo.remote_info]]];
  [self setLocalURI:[AKSIPURI SIPURIWithString:
                     [NSString stringWithPJString:callInfo.local_info]]];
  
  [self setState:kAKSIPCallNullState];
  
  [self setIncoming:NO];
  
  return self;
}

- (id)init {
  return [self initWithSIPAccount:nil
                       identifier:kAKSIPUserAgentInvalidIdentifier];
}

- (void)dealloc {
  if ([[AKSIPUserAgent sharedUserAgent] isStarted])
    [self hangUp];
  
  [self setDelegate:nil];
  
  [localURI_ release];
  [remoteURI_ release];
  [stateText_ release];
  [lastStatusText_ release];
  
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ <=> %@", [self localURI],
          [self remoteURI]];
}

- (void)answer {
  pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_OK,
                                         NULL, NULL);
  if (status != PJ_SUCCESS)
    NSLog(@"Error answering call %@", self);
}

- (void)hangUp {
  if (([self identifier] == kAKSIPUserAgentInvalidIdentifier) ||
      ([self state] == kAKSIPCallDisconnectedState))
    return;
  
  pj_status_t status = pjsua_call_hangup([self identifier], 0, NULL, NULL);
  if (status != PJ_SUCCESS)
    NSLog(@"Error hanging up call %@", self);
}

- (void)sendRingingNotification {
  pj_status_t status = pjsua_call_answer([self identifier], PJSIP_SC_RINGING,
                                         NULL, NULL);
  if (status != PJ_SUCCESS)
    NSLog(@"Error sending ringing notification in call %@", self);
}

- (void)replyWithTemporarilyUnavailable {
  pj_status_t status = pjsua_call_answer([self identifier],
                                         PJSIP_SC_TEMPORARILY_UNAVAILABLE,
                                         NULL, NULL);
  if (status != PJ_SUCCESS)
    NSLog(@"Error replying with 480 Temporarily Unavailable");
}

- (void)ringbackStart {
  AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
  
  // Use dot syntax for properties to prevent square bracket clutter.
  if (userAgent.callData[self.identifier].ringbackOn)
    return;
  
  userAgent.callData[self.identifier].ringbackOn = PJ_TRUE;
  
  [userAgent setRingbackCount:[userAgent ringbackCount] + 1];
  if ([userAgent ringbackCount] == 1 &&
      [userAgent ringbackSlot] != kAKSIPUserAgentInvalidIdentifier)
    pjsua_conf_connect([userAgent ringbackSlot], 0);
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
      
      NSString *messageBody
        = [NSString stringWithFormat:@"Signal=%C\r\nDuration=160",
           [digits characterAtIndex:i]];
      messageData.msg_body = [messageBody pjString];
      
      status = pjsua_call_send_request([self identifier], &kSIPINFO, &messageData);
      if (status != PJ_SUCCESS)
        NSLog(@"Error sending DTMF");
    }
  }
}

- (void)muteMicrophone {
  if ([self isMicrophoneMuted] ||
      [self state] != kAKSIPCallConfirmedState)
    return;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info([self identifier], &callInfo);
  
  pj_status_t status = pjsua_conf_disconnect(0, callInfo.conf_slot);
  if (status == PJ_SUCCESS)
    [self setMicrophoneMuted:YES];
  else
    NSLog(@"Error muting microphone in call %@", self);
}

- (void)unmuteMicrophone {
  if (![self isMicrophoneMuted] ||
      [self state] != kAKSIPCallConfirmedState)
    return;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info([self identifier], &callInfo);
  
  pj_status_t status = pjsua_conf_connect(0, callInfo.conf_slot);
  if (status == PJ_SUCCESS)
    [self setMicrophoneMuted:NO];
  else
    NSLog(@"Error unmuting microphone in call %@", self);
}

- (void)toggleMicrophoneMute {
  if ([self isMicrophoneMuted])
    [self unmuteMicrophone];
  else
    [self muteMicrophone];
}

- (void)hold {
  if ([self state] == kAKSIPCallConfirmedState && ![self isOnRemoteHold])
    pjsua_call_set_hold([self identifier], NULL);
}

- (void)unhold {
  if ([self state] == kAKSIPCallConfirmedState)
    pjsua_call_reinvite([self identifier], PJ_TRUE, NULL);
}

- (void)toggleHold {
  if ([self isOnLocalHold])
    [self unhold];
  else
    [self hold];
}

@end


#pragma mark -
#pragma mark Callbacks

// When incoming call is received, create call object, set its info,
// attach to the account, add to the array, send notification
void AKSIPCallIncomingReceived(pjsua_acc_id accountIdentifier,
                            pjsua_call_id callIdentifier,
                            pjsip_rx_data *messageData) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  pjsua_call_info callInfo;
  pjsua_call_get_info(callIdentifier, &callInfo);
  
  PJ_LOG(3, (THIS_FILE, "Incoming call for account %d!", accountIdentifier));
  
  AKSIPAccount *theAccount = [[AKSIPUserAgent sharedUserAgent]
                              accountByIdentifier:accountIdentifier];
  
  // AKSIPCall object is created here when the call is incoming.
  AKSIPCall *theCall
    = [[[AKSIPCall alloc] initWithSIPAccount:theAccount
                                  identifier:callIdentifier]
       autorelease];
  
  [theCall setState:callInfo.state];
  [theCall setStateText:[NSString stringWithPJString:callInfo.state_text]];
  [theCall setLastStatus:callInfo.last_status];
  [theCall setLastStatusText:[NSString stringWithPJString:callInfo.last_status_text]];
  [theCall setIncoming:YES];
  
  // Keep the new call in the account's calls array
  [[theAccount calls] addObject:theCall];
  
  if ([[theAccount delegate] respondsToSelector:@selector(SIPAccountDidReceiveCall:)]) {
    [[theAccount delegate]
     performSelectorOnMainThread:@selector(SIPAccountDidReceiveCall:)
                      withObject:theCall
                   waitUntilDone:NO];
  }
  
  NSNotification *notification
    = [NSNotification notificationWithName:AKSIPCallIncomingNotification
                                    object:theCall];
  
  [[NSNotificationCenter defaultCenter]
   performSelectorOnMainThread:@selector(postNotification:)
                    withObject:notification
                 waitUntilDone:NO];
  
  [pool release];
}

// Track changes in calls state. Send notifications
void AKSIPCallStateChanged(pjsua_call_id callIdentifier, pjsip_event *sipEvent) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  NSNotification *notification = nil;
  
  pjsua_call_info callInfo;
  pjsua_call_get_info(callIdentifier, &callInfo);
  
  AKSIPCall *theCall = [[AKSIPUserAgent sharedUserAgent]
                        SIPCallByIdentifier:callIdentifier];
  
  [theCall setState:callInfo.state];
  [theCall setStateText:[NSString stringWithPJString:callInfo.state_text]];
  [theCall setLastStatus:callInfo.last_status];
  [theCall setLastStatusText:
   [NSString stringWithPJString:callInfo.last_status_text]];
  
  if (callInfo.state == PJSIP_INV_STATE_DISCONNECTED) {
    [theCall ringbackStop];
    
    // Remove the call from its account's calls list.
    [[[theCall account] calls] removeObject:theCall];
    
    PJ_LOG(3, (THIS_FILE, "Call %d is DISCONNECTED [reason = %d (%s)]",
               callIdentifier,
               callInfo.last_status,
               callInfo.last_status_text.ptr));
    
    notification
      = [NSNotification notificationWithName:AKSIPCallDidDisconnectNotification
                                      object:theCall];
    
    [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                         withObject:notification
                                      waitUntilDone:NO];
    
  } else {
    if (callInfo.state == PJSIP_INV_STATE_EARLY) {
      // pj_str_t is a struct with NOT null-terminated string
      pj_str_t reason;
      pjsip_msg *msg;
      int code;
      
      // This can only occur because of TX or RX message
      pj_assert(sipEvent->type == PJSIP_EVENT_TSX_STATE);
      
      if (sipEvent->body.tsx_state.type == PJSIP_EVENT_RX_MSG)
        msg = sipEvent->body.tsx_state.src.rdata->msg_info.msg;
      else
        msg = sipEvent->body.tsx_state.src.tdata->msg;
      
      code = msg->line.status.code;
      reason = msg->line.status.reason;
      
      // Start ringback for 180 for UAC unless there's SDP in 180
      if (callInfo.role == PJSIP_ROLE_UAC && code == 180 &&
          msg->body == NULL && callInfo.media_status == PJSUA_CALL_MEDIA_NONE)
      {
        [theCall ringbackStart];
      }
      
      PJ_LOG(3,(THIS_FILE, "Call %d state changed to %s (%d %.*s)",
                callIdentifier, callInfo.state_text.ptr,
                code, (int)reason.slen, reason.ptr));
      
      NSDictionary *userInfo
        = [NSDictionary dictionaryWithObjectsAndKeys:
           [NSNumber numberWithInt:code], @"AKSIPEventCode",
           [NSString stringWithPJString:reason], @"AKSIPEventReason",
           nil];
      
      notification
        = [NSNotification notificationWithName:AKSIPCallEarlyNotification
                                        object:theCall
                                      userInfo:userInfo];
      
      [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                           withObject:notification
                                        waitUntilDone:NO];
    } else {
      PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s",
                 callIdentifier,
                 callInfo.state_text.ptr));
      
      // Incoming call notification is posted in another funcion: AKIncomingCallReceived()
      NSString *notificationName = nil;
      switch (callInfo.state) {
          case PJSIP_INV_STATE_CALLING:
            notificationName = AKSIPCallCallingNotification;
            break;
          case PJSIP_INV_STATE_CONNECTING:
            notificationName = AKSIPCallConnectingNotification;
            break;
          case PJSIP_INV_STATE_CONFIRMED:
            notificationName = AKSIPCallDidConfirmNotification;
            break;
          default:
            break;
      }
      
      if (notificationName != nil) {
        notification = [NSNotification notificationWithName:notificationName
                                                     object:theCall];
        [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                             withObject:notification
                                          waitUntilDone:NO];
      }
    }
  }
  
  [pool release];
}

// Track and log media changes
void AKSIPCallMediaStateChanged(pjsua_call_id callIdentifier) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  pjsua_call_info callInfo;
  pjsua_call_get_info(callIdentifier, &callInfo);
  
  AKSIPCall *theCall = [[AKSIPUserAgent sharedUserAgent]
                        SIPCallByIdentifier:callIdentifier];
  [theCall ringbackStop];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  NSNotification *notification = nil;
  
  if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
    // When media is active, connect call to sound device
    pjsua_conf_connect(callInfo.conf_slot, 0);
    pjsua_conf_connect(0, callInfo.conf_slot);
    
    PJ_LOG(3, (THIS_FILE, "Media for call %d is active", callIdentifier));
    
    notification
      = [NSNotification notificationWithName:AKSIPCallMediaDidBecomeActiveNotification
                                      object:theCall];
    
    [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                         withObject:notification
                                      waitUntilDone:NO];
    
  } else if (callInfo.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) {
    PJ_LOG(3, (THIS_FILE, "Media for call %d is suspended (hold) by local",
               callIdentifier));
    notification
      = [NSNotification notificationWithName:AKSIPCallDidLocalHoldNotification
                                      object:theCall];
    
    [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                         withObject:notification
                                      waitUntilDone:NO];
    
  } else if (callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
    PJ_LOG(3, (THIS_FILE, "Media for call %d is suspended (hold) by remote",
               callIdentifier));
    notification
      = [NSNotification notificationWithName:AKSIPCallDidRemoteHoldNotification
                                      object:theCall];
    
    [notificationCenter performSelectorOnMainThread:@selector(postNotification:)
                                         withObject:notification
                                      waitUntilDone:NO];
    
  } else if (callInfo.media_status == PJSUA_CALL_MEDIA_ERROR) {
    pj_str_t reason = pj_str("ICE negotiation failed");
    PJ_LOG(1, (THIS_FILE, "Media has reported error, disconnecting call"));
    
    pjsua_call_hangup(callIdentifier, 500, &reason, NULL);
    
  } else {
    PJ_LOG(3, (THIS_FILE, "Media for call %d is inactive", callIdentifier));
  }
  
  [pool release];
}
