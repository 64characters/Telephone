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

@property(nonatomic, readwrite, assign) id delegate;
@property(nonatomic, readwrite, assign) NSInteger identifier;
@property(nonatomic, readwrite, retain) AKSIPURI *localURI;
@property(nonatomic, readwrite, retain) AKSIPURI *remoteURI;
@property(nonatomic, readonly, assign) NSInteger state;
@property(nonatomic, readonly, copy) NSString *stateText;
@property(nonatomic, readwrite, assign) NSInteger lastStatus;
@property(nonatomic, readwrite, copy) NSString *lastStatusText;
@property(nonatomic, readonly, assign, getter=isActive) BOOL active;
@property(nonatomic, readwrite, assign) AKTelephoneAccount *account;

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
