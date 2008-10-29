//
//  AKTelephoneCall.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 16.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <pjsua-lib/pjsua.h>


@class AKTelephoneAccount;

APPKIT_EXTERN const NSInteger AKTelephoneCallsMax;

@interface AKTelephoneCall : NSObject {
	id delegate;
	
	NSNumber *identifier;
	NSString *localInfo;
	NSString *remoteInfo;
	NSNumber *lastStatus;
	NSString *lastStatusText;
	
	// Account the call belongs to
	AKTelephoneAccount *account;
}

@property(readwrite, assign) id delegate;
@property(readwrite, copy) NSNumber *identifier;
@property(readwrite, copy) NSString *localInfo;
@property(readwrite, copy) NSString *remoteInfo;
@property(readonly, copy) NSNumber *state;
@property(readonly, copy) NSString *stateText;
@property(readwrite, copy) NSNumber *lastStatus;
@property(readwrite, copy) NSString *lastStatusText;
@property(readonly, assign, getter=isActive) BOOL active;
@property(readwrite, assign) AKTelephoneAccount *account;

// Designated initializer
- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount
					identifier:(NSNumber *)anIdentifier;

- (void)answer;
- (void)hangUp;
- (void)ringbackStart;
- (void)ringbackStop;

@end

// Callbacks from PJSUA
void AKIncomingCallReceived(pjsua_acc_id, pjsua_call_id, pjsip_rx_data *);
void AKCallStateChanged(pjsua_call_id, pjsip_event *);
void AKCallMediaStateChanged(pjsua_call_id);


@interface NSObject(AKTelephoneCallNotifications)
- (void)telephoneCallCalling:(NSNotification *)notification;
- (void)telephoneCallIncoming:(NSNotification *)notification;
- (void)telephoneCallEarly:(NSNotification *)notification;
- (void)telephoneCallConnecting:(NSNotification *)notification;
- (void)telephoneCallDidConfirm:(NSNotification *)notification;
- (void)telephoneCallDidDisconnect:(NSNotification *)notification;
@end

// Notifications

// Calling. After INVITE is sent
APPKIT_EXTERN NSString *AKTelephoneCallCallingNotification;

// Incoming. After INVITE is received. Delegate is not subscribed to this notification
APPKIT_EXTERN NSString *AKTelephoneCallIncomingNotification;

// Early. After response with To tag
APPKIT_EXTERN NSString *AKTelephoneCallEarlyNotification;	// @"AKTelephoneCallState", @"AKSIPEventCode", @"AKSIPEventReason"

// Connecting. After 2xx is sent/received; 
APPKIT_EXTERN NSString *AKTelephoneCallConnectingNotification;

// Confirmed. After ACK is sent/received
APPKIT_EXTERN NSString *AKTelephoneCallDidConfirmNotification;

// Disconnected. Session is terminated
APPKIT_EXTERN NSString *AKTelephoneCallDidDisconnectNotification;