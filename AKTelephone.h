//
//  AKTelephone.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AKTelephoneAccount, AKTelephoneCall, AKTelephoneConfig;

// Ready state enumerated in reversed order
typedef enum _AKTelephoneReadyState {
	AKTelephoneStarted				= 0,	// After pjsua_start(), all OK
	AKTelephoneTransportCreated		= 1,	// After pjsua_transport_create()
	AKTelephoneConfigured			= 2,	// After pjsua_init()
	AKTelephoneCreated				= 3		// After pjsua_create()
} AKTelephoneReadyState;

@interface AKTelephone : NSObject {
	NSMutableArray *accounts;
	AKTelephoneReadyState readyState;
}

@property(readonly, retain) NSMutableArray *accounts;
@property(readwrite, assign) AKTelephoneReadyState readyState;

+ (id)telephoneWithConfig:(AKTelephoneConfig *)config;
+ (AKTelephone *)sharedTelephone;

// Designated initializer
- (id)initWithConfig:(AKTelephoneConfig *)config;

// Dealing with accounts
- (BOOL)addAccount:(AKTelephoneAccount *)anAccount withPassword:(NSString *)aPassword;
- (BOOL)removeAccount:(AKTelephoneAccount *)account;
- (AKTelephoneAccount *)accountByIdentifier:(NSNumber *)anIdentifier;

// Dealing with calls
- (AKTelephoneCall *)telephoneCallByIdentifier:(NSNumber *)anIdentifier;
- (void)hangUpAllCalls;

// Destroy undelying sip user agent correctly
- (void)destroyUserAgent;

@end
