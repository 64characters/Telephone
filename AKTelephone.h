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

extern NSString *AKSoundDeviceName;
extern NSString *AKSoundDeviceInputCount;
extern NSString *AKSoundDeviceOutputCount;
extern NSString *AKSoundDeviceDefaultSamplesPerSecond;

typedef enum _AKTelephoneReadyState {
	AKTelephoneCreated				= 1,	// After pjsua_create()
	AKTelephoneConfigured			= 2,	// After pjsua_init()
	AKTelephoneTransportCreated		= 3,	// After pjsua_transport_create()
	AKTelephoneStarted				= 4		// After pjsua_start(), all OK
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
	pj_pool_t *pjPool;
	NSInteger ringbackSlot;
	NSInteger ringbackCount;
	pjmedia_port *ringbackPort;
}

@property(nonatomic, readwrite, assign) id delegate;
@property(nonatomic, readonly, retain) NSMutableArray *accounts;
@property(nonatomic, readonly, retain) NSArray *soundDevices;
@property(nonatomic, readwrite, assign) AKTelephoneReadyState readyState;
@property(nonatomic, readonly, assign) AKTelephoneCallData *callData;
@property(nonatomic, readonly, assign) pj_pool_t *pjPool;
@property(nonatomic, readonly, assign) NSInteger ringbackSlot;
@property(nonatomic, readwrite, assign) NSInteger ringbackCount;
@property(nonatomic, readonly, assign) pjmedia_port *ringbackPort;

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
- (AKTelephoneAccount *)accountByIdentifier:(NSInteger)anIdentifier;

// Dealing with calls
- (AKTelephoneCall *)telephoneCallByIdentifier:(NSInteger)anIdentifier;
- (void)hangUpAllCalls;

// Set new input and output sound devices.
// If NSNotFound or -1 is passed as either parameter, first matched device will be used.
- (BOOL)setSoundInputDevice:(NSInteger)input soundOutputDevice:(NSInteger)output;

// Update list of sound devices. Posts AKTelephoneDidUpdateSoundDevicesNotification.
// After calling this method, setSoundInputDevice:soundOutputDevice: must be called to set appropriate IO.
- (void)updateSoundDevices;

// Destroy undelying sip user agent correctly
- (BOOL)destroyUserAgent;

@end


// Callback from PJSUA
void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result);

@interface NSObject(AKTelephoneNotifications)
- (void)telephoneDidDetectNAT:(NSNotification *)notification;
- (void)telephoneDidUpdateSoundDevices:(NSNotification *)notification;
@end

// Notifications
extern NSString *AKTelephoneDidDetectNATNotification;
extern NSString *AKTelephoneDidUpdateSoundDevicesNotification;
