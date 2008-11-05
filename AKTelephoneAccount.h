//
//  AKTelephoneAccount.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <pjsua-lib/pjsua.h>


@class AKTelephoneCall;

// Keys for AKTelephoneAccount properties
extern NSString *AKTelephoneAccountFullName;
extern NSString *AKTelephoneAccountSIPAddress;
extern NSString *AKTelephoneAccountRegistrar;
extern NSString *AKTelephoneAccountRealm;
extern NSString *AKTelephoneAccountUsername;

@interface AKTelephoneAccount : NSObject {
	id delegate;
	
	NSString *fullName;
	NSString *SIPAddress;
	NSString *registrar;
	NSString *realm;
	NSString *username;
	
	NSInteger identifier;
	
	NSMutableArray *calls;
}

@property(nonatomic, readwrite, assign) id delegate;
@property(nonatomic, readwrite, copy) NSString *fullName;
@property(nonatomic, readwrite, copy) NSString *SIPAddress;
@property(nonatomic, readwrite, copy) NSString *registrar;
@property(nonatomic, readwrite, copy) NSString *realm;
@property(nonatomic, readwrite, copy) NSString *username;
@property(nonatomic, readwrite, assign) NSInteger identifier;
@property(nonatomic, readwrite, assign, getter=isRegistered) BOOL registered;
@property(nonatomic, readonly, assign) NSInteger registrationStatus;
@property(nonatomic, readonly, copy) NSString *registrationStatusText;
@property(nonatomic, readonly, assign) NSInteger registrationExpireTime;
@property(nonatomic, readwrite, assign, getter=isOnline) BOOL online;
@property(nonatomic, readonly, copy) NSString *onlineStatusText;
@property(nonatomic, readonly, retain) NSMutableArray *calls;

+ (id)telephoneAccountWithFullName:(NSString *)aFullName
						SIPAddress:(NSString *)aSIPAddress
						 registrar:(NSString *)aRegistrar
							 realm:(NSString *)aRealm
						  username:(NSString *)aUsername;

- (id)initWithFullName:(NSString *)aFullName
			SIPAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername;

- (AKTelephoneCall *)makeCallTo:(NSString *)destinationURI;
- (BOOL)unregister;

@end

// Callback from PJSUA
void AKTelephoneAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier);


@interface NSObject(AKTelephoneAccountNotifications)
- (void)telephoneAccountRegistrationDidChange:(NSNotification *)notification;
@end

@interface NSObject(AKTelephoneAccountDelegate)
- (void)telephoneAccount:(AKTelephoneAccount *)sender didReceiveCall:(AKTelephoneCall *)aCall;
@end

// Notifications
extern NSString *AKTelephoneAccountRegistrationDidChangeNotification;
