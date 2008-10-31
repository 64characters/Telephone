//
//  AKTelephoneCall.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 16.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <pjsua-lib/pjsua.h>


@class AKTelephoneAccount, AKSIPURI;

extern const NSInteger AKTelephoneCallsMax;

@interface AKTelephoneCall : NSObject {
	id delegate;
	
	NSInteger identifier;
	AKSIPURI *localURI;
	AKSIPURI *remoteURI;
	NSInteger lastStatus;
	NSString *lastStatusText;
	
	// Account the call belongs to
	AKTelephoneAccount *account;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) NSInteger identifier;
@property(readwrite, retain) AKSIPURI *localURI;
@property(readwrite, retain) AKSIPURI *remoteURI;
@property(readonly, assign) NSInteger state;
@property(readonly, copy) NSString *stateText;
@property(readwrite, assign) NSInteger lastStatus;
@property(readwrite, copy) NSString *lastStatusText;
@property(readonly, assign, getter=isActive) BOOL active;
@property(readwrite, assign) AKTelephoneAccount *account;

// Designated initializer
- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount
					identifier:(NSInteger)anIdentifier;

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
extern NSString *AKTelephoneCallCallingNotification;

// Incoming. After INVITE is received. Delegate is not subscribed to this notification
extern NSString *AKTelephoneCallIncomingNotification;

// Early. After response with To tag
extern NSString *AKTelephoneCallEarlyNotification;	// @"AKTelephoneCallState", @"AKSIPEventCode", @"AKSIPEventReason"

// Connecting. After 2xx is sent/received; 
extern NSString *AKTelephoneCallConnectingNotification;

// Confirmed. After ACK is sent/received
extern NSString *AKTelephoneCallDidConfirmNotification;

// Disconnected. Session is terminated
extern NSString *AKTelephoneCallDidDisconnectNotification;
