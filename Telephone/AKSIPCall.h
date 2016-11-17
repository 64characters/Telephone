//
//  AKSIPCall.h
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

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

#import "AKSIPCallDelegate.h"
#import "AKSIPCallNotifications.h"


NS_ASSUME_NONNULL_BEGIN

extern const NSInteger kAKSIPCallsMax;

typedef NS_ENUM(NSUInteger, AKSIPCallState) {
    // Before INVITE is sent or received.
    kAKSIPCallNullState =         PJSIP_INV_STATE_NULL,
    
    // After INVITE is sent.
    kAKSIPCallCallingState =      PJSIP_INV_STATE_CALLING,
    
    // After INVITE is received.
    kAKSIPCallIncomingState =     PJSIP_INV_STATE_INCOMING,
    
    // After response with To tag.
    kAKSIPCallEarlyState =        PJSIP_INV_STATE_EARLY,
    
    // After 2xx is sent/received.
    kAKSIPCallConnectingState =   PJSIP_INV_STATE_CONNECTING,
    
    // After ACK is sent/received.
    kAKSIPCallConfirmedState =    PJSIP_INV_STATE_CONFIRMED,
    
    // Session is terminated.
    kAKSIPCallDisconnectedState = PJSIP_INV_STATE_DISCONNECTED
};

@class AKSIPAccount, AKSIPURI;

// A class representing a SIP call.
@interface AKSIPCall : NSObject

// The receiver's delegate.
@property(nonatomic, weak) id<AKSIPCallDelegate> delegate;

// The receiver's identifier.
@property(nonatomic) NSInteger identifier;

// SIP URI of the local Contact header.
@property(nonatomic, readonly) AKSIPURI *localURI;

// SIP URI of the remote Contact header.
@property(nonatomic, readonly) AKSIPURI *remoteURI;

// Call state.
@property(nonatomic) AKSIPCallState state;

// Call state text.
@property(nonatomic, copy) NSString *stateText;

// Call's last status code.
@property(nonatomic) NSInteger lastStatus;

// Call's last status text.
@property(nonatomic, copy) NSString *lastStatusText;

// Call transfer status code.
@property(nonatomic) NSInteger transferStatus;

// Call transfer status text.
@property(nonatomic, copy) NSString *transferStatusText;

// A Boolean value indicating whether the call is active, i.e. it has active
// INVITE session and the INVITE session has not been disconnected.
@property(nonatomic, readonly, getter=isActive) BOOL active;

// A Boolean value indicating whether the call has a media session.
@property(nonatomic, readonly) BOOL hasMedia;

// A Boolean value indicating whether the call's media is active.
@property(nonatomic, readonly) BOOL hasActiveMedia;

// A Boolean value indicating whether the call is incoming.
@property(nonatomic, getter=isIncoming) BOOL incoming;

// A Boolean value indicating whether microphone is muted.
@property(nonatomic, getter=isMicrophoneMuted) BOOL microphoneMuted;

// A Boolean value indicating whether the call is on local hold.
@property(nonatomic, readonly, getter=isOnLocalHold) BOOL onLocalHold;

// A Boolean value indicating whether the call is on remote hold.
@property(nonatomic, readonly, getter=isOnRemoteHold) BOOL onRemoteHold;

// The account the call belongs to.
@property(nonatomic, readonly) AKSIPAccount *account;

@property(nonatomic, readonly) NSDate *date;
@property(nonatomic, readonly) NSInteger duration;
@property(nonatomic, readonly, getter=isMissed) BOOL missed;

- (instancetype)initWithSIPAccount:(AKSIPAccount *)account identifier:(NSInteger)identifier incoming:(BOOL)isIncoming;

// Answers the call.
- (void)answer;

// Hangs-up the call.
- (void)hangUp;

// Attended call transfer. Sends REFER request to the receiver's remote party to initiate new INVITE session to the URL
// of |destinationCall|. The party at |destinationCall| then should replace the call with us with the new call from the
// REFER recipient.
- (void)attendedTransferToCall:(AKSIPCall *)destinationCall;

// Sends ringing notification to another party.
- (void)sendRingingNotification;

// Replies with 480 Temporarily Unavailable.
- (void)replyWithTemporarilyUnavailable;

// Replies with 486 Busy Here.
- (void)replyWithBusyHere;

// Sends DTMF.
- (void)sendDTMFDigits:(NSString *)digits;

// Mutes microphone.
- (void)muteMicrophone;

// Unmutes microphone.
- (void)unmuteMicrophone;

// Toggles microphone mute.
- (void)toggleMicrophoneMute;

// Places the call on hold.
- (void)hold;

// Releases the call from hold.
- (void)unhold;

// Toggles call hold.
- (void)toggleHold;

@end

NS_ASSUME_NONNULL_END
