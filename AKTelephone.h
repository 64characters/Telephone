//
//  AKTelephone.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>


@class AKTelephoneAccount, AKTelephoneCall;

// Ready state enumerated in reversed order
typedef enum _AKTelephoneReadyState {
	AKTelephoneStarted				= 0,	// After pjsua_start(), all OK
	AKTelephoneTransportCreated		= 1,	// After pjsua_transport_create()
	AKTelephoneConfigured			= 2,	// After pjsua_init()
	AKTelephoneCreated				= 3		// After pjsua_create()
} AKTelephoneReadyState;

typedef struct _AKTelephoneCallData {
	pj_timer_entry timer;
	pj_bool_t ringbackOn;
	pj_bool_t ringbackOff;
} AKTelephoneCallData;

@interface AKTelephone : NSObject {
	id delegate;
	
	NSMutableArray *accounts;
	AKTelephoneReadyState readyState;

	// PJSUA config
	pjsua_config userAgentConfig;
	pjsua_logging_config loggingConfig;
	pjsua_media_config mediaConfig;
	pjsua_transport_config transportConfig;
	AKTelephoneCallData callData[PJSUA_MAX_CALLS];
	pj_pool_t *pool;
	NSInteger ringbackSlot;
	NSInteger ringbackCount;
	pjmedia_port *ringbackPort;
}

@property(readwrite, assign) id delegate;
@property(readonly, retain) NSMutableArray *accounts;
@property(readwrite, assign) AKTelephoneReadyState readyState;
@property(readonly, assign) AKTelephoneCallData *callData;
@property(readonly, assign) NSInteger ringbackSlot;
@property(readwrite, assign) NSInteger ringbackCount;
@property(readonly, assign) pjmedia_port *ringbackPort;

+ (id)telephoneWithDelegate:(id)aDelegate;
+ (id)telephone;
+ (AKTelephone *)sharedTelephone;

// Designated initializer
- (id)initWithDelegate:(id)aDelegate;

// Start Telephone
- (BOOL)start;

// Dealing with accounts
- (BOOL)addAccount:(AKTelephoneAccount *)anAccount withPassword:(NSString *)aPassword;
- (BOOL)removeAccount:(AKTelephoneAccount *)account;
- (AKTelephoneAccount *)accountByIdentifier:(NSNumber *)anIdentifier;

// Dealing with calls
- (AKTelephoneCall *)telephoneCallByIdentifier:(NSNumber *)anIdentifier;
- (void)hangUpAllCalls;

// Destroy undelying sip user agent correctly
- (BOOL)destroyUserAgent;

@end


// Callback from PJSUA
void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result);


@interface NSObject(AKTelephoneNotifications)
- (void)telephoneDidDetectNAT:(NSNotification *)notification;
@end

// Notifications
APPKIT_EXTERN NSString *AKTelephoneDidDetectNATNotification;
