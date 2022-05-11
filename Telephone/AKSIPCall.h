//
//  AKSIPCall.h
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

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

@import UseCases;

#import "AKSIPCallDelegate.h"
#import "AKSIPCallNotifications.h"


NS_ASSUME_NONNULL_BEGIN

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

@class AKSIPAccount, AKSIPURI, PJSUACallInfo;

@interface AKSIPCall : NSObject <Call>

@property(nonatomic, readonly) AKSIPAccount<Account> *account;
@property(nonatomic) NSInteger identifier;

@property(nonatomic, weak) id<AKSIPCallDelegate> delegate;

@property(nonatomic) AKSIPCallState state;
@property(nonatomic, copy) NSString *stateText;
@property(nonatomic) NSInteger lastStatus;
@property(nonatomic, copy) NSString *lastStatusText;
@property(nonatomic) NSInteger transferStatus;
@property(nonatomic, copy) NSString *transferStatusText;
@property(nonatomic) NSInteger duration;

@property(nonatomic, readonly, copy) NSDate *date;
@property(nonatomic, readonly) AKSIPURI *localURI;
@property(nonatomic, readonly) AKSIPURI *remoteURI;
@property(nonatomic, readonly, getter=isActive) BOOL active;
@property(nonatomic, readonly, getter=isMicrophoneMuted) BOOL microphoneMuted;
@property(nonatomic, readonly, getter=isOnLocalHold) BOOL onLocalHold;
@property(nonatomic, readonly, getter=isOnRemoteHold) BOOL onRemoteHold;

- (instancetype)initWithSIPAccount:(AKSIPAccount *)account info:(PJSUACallInfo *)info;

- (void)answer;
- (void)hangUp;

- (void)attendedTransferToCall:(AKSIPCall *)destinationCall;

- (void)sendRingingNotification;
- (void)replyWithTemporarilyUnavailable;
- (void)replyWithBusyHere;

- (void)sendDTMFDigits:(NSString *)digits;
- (void)toggleMicrophoneMute;
- (void)toggleHold;

@end

NS_ASSUME_NONNULL_END
