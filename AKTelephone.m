//
//  AKTelephone.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <pjsua-lib/pjsua.h>

#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "NSString+PJSUA.h"

#define THIS_FILE "AKTelephone.m"

// Ringtones.
#define RINGBACK_FREQ1		440
#define RINGBACK_FREQ2		480
#define RINGBACK_ON			2000
#define RINGBACK_OFF		4000
#define RINGBACK_CNT		1
#define RINGBACK_INTERVAL	4000

NSString *AKTelephoneDidDetectNATNotification = @"AKTelephoneDidDetectNAT";

static AKTelephone *sharedTelephone = nil;

@implementation AKTelephone

@dynamic delegate;
@synthesize accounts;
@synthesize readyState;
@dynamic callData;
@synthesize pjPool;
@synthesize ringbackSlot;
@synthesize ringbackCount;
@synthesize ringbackPort;

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)aDelegate
{
	if (delegate == aDelegate)
		return;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if (delegate != nil)
		[notificationCenter removeObserver:delegate name:nil object:self];
	
	if (aDelegate != nil)
		if ([aDelegate respondsToSelector:@selector(telephoneDidDetectNAT:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneDidDetectNAT:)
									   name:AKTelephoneDidDetectNATNotification
									 object:self];
	delegate = aDelegate;
}

- (AKTelephoneCallData *)callData
{
	return callData;
}


#pragma mark Telephone singleton instance

+ (id)telephoneWithDelegate:(id)aDelegate
{
	@synchronized(self) {
		if (sharedTelephone == nil)
			[[self alloc] initWithDelegate:aDelegate];	// Assignment not done here
	}
	
	return sharedTelephone;
}

+ (id)telephone
{
	return [self telephoneWithDelegate:nil];
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedTelephone == nil) {
			sharedTelephone = [super allocWithZone:zone];
			return sharedTelephone;		// Assignment and return on first allocation
		}
	}
	
	return nil;		// On subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return UINT_MAX;	// Denotes an object that cannot be released
}

- (void)release
{
	// Do nothing
}

- (id)autorelease
{
	return self;
}


#pragma mark -

+ (AKTelephone *)sharedTelephone
{
	return sharedTelephone;
}

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
	if (self == nil)
		return nil;
	
	[self setDelegate:aDelegate];
	accounts = [[NSMutableArray alloc] init];
	
	pjsua_config_default(&userAgentConfig);
	pjsua_logging_config_default(&loggingConfig);
	pjsua_media_config_default(&mediaConfig);
	pjsua_transport_config_default(&transportConfig);
	
	ringbackSlot = PJSUA_INVALID_ID;
	userAgentConfig.max_calls = AKTelephoneCallsMax;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *stunServerHost = [defaults stringForKey:AKSTUNServerHost];
	if (stunServerHost != nil)
		userAgentConfig.stun_host = [[NSString stringWithFormat:@"%@:%@",
									  stunServerHost, [defaults objectForKey:AKSTUNServerPort]]
									 pjString];
	
	loggingConfig.log_filename = [[[defaults stringForKey:AKLogFileName]
								   stringByExpandingTildeInPath]
								  pjString];
	loggingConfig.level = [defaults integerForKey:AKLogLevel];
	loggingConfig.console_level = [defaults integerForKey:AKConsoleLogLevel];
	
	mediaConfig.no_vad = ![defaults boolForKey:AKVoiceActivityDetection];
	
	transportConfig.port = [defaults integerForKey:AKTransportPort];
	
	userAgentConfig.cb.on_incoming_call = AKIncomingCallReceived;
	userAgentConfig.cb.on_call_media_state = AKCallMediaStateChanged;
	userAgentConfig.cb.on_call_state = AKCallStateChanged;
	userAgentConfig.cb.on_reg_state = AKTelephoneAccountRegistrationStateChanged;
	userAgentConfig.cb.on_nat_detect = AKTelephoneDetectedNAT;
	
	pj_status_t status;
	
	// Create pjsua.
	status = pjsua_create();
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating pjsua");
		[self release];
		return nil;
	}
	// Create pool for pjsua.
	pjPool = pjsua_pool_create("telephone-pjsua", 1000, 1000);
	[self setReadyState:AKTelephoneCreated];
	
	// Initialize pjsua.
	status = pjsua_init(&userAgentConfig, &loggingConfig, &mediaConfig);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error initializing pjsua");
		[self release];
		return nil;
	}
	
	// Create ringback tones.
	unsigned i, samplesPerFrame;
	pjmedia_tone_desc tone[RINGBACK_CNT];
	pj_str_t name;
	
	samplesPerFrame = mediaConfig.audio_frame_ptime *
	mediaConfig.clock_rate *
	mediaConfig.channel_count / 1000;
	
	name = pj_str("ringback");
	status = pjmedia_tonegen_create2(pjPool, &name,
									 mediaConfig.clock_rate,
									 mediaConfig.channel_count,
									 samplesPerFrame, 16, PJMEDIA_TONEGEN_LOOP,
									 &ringbackPort);
	if (status != PJ_SUCCESS)
		NSLog(@"Error creating ringback tones");
	
	pj_bzero(&tone, sizeof(tone));
	for (i = 0; i < RINGBACK_CNT; ++i) {
		tone[i].freq1 = RINGBACK_FREQ1;
		tone[i].freq2 = RINGBACK_FREQ2;
		tone[i].on_msec = RINGBACK_ON;
		tone[i].off_msec = RINGBACK_OFF;
	}
	tone[RINGBACK_CNT - 1].off_msec = RINGBACK_INTERVAL;
	
	pjmedia_tonegen_play(ringbackPort, RINGBACK_CNT, tone, PJMEDIA_TONEGEN_LOOP);
	
	status = pjsua_conf_add_port(pjPool, ringbackPort, &ringbackSlot);
	if (status != PJ_SUCCESS)
		NSLog(@"Error adding media port for ringback tones");
	
	[self setReadyState:AKTelephoneConfigured];
	
	// Add UDP transport.
	status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, NULL);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating transport");
		[self release];
		return nil;
	}
	[self setReadyState:AKTelephoneTransportCreated];
	
	return self;
}

- (id)init
{
	return [self initWithDelegate:nil];
}

- (void)dealloc
{
	[accounts release];
	
	[super dealloc];
}


#pragma mark -

- (BOOL)start
{	
	pj_status_t status = pjsua_start();
	if (status != PJ_SUCCESS)
		return NO;
	
	[self setReadyState:AKTelephoneStarted];
	
	return YES;
}

- (BOOL)addAccount:(AKTelephoneAccount *)anAccount withPassword:(NSString *)aPassword
{
	pjsua_acc_config accountConfig;
	pjsua_acc_config_default(&accountConfig);
	
	NSString *fullSIPURL = [NSString stringWithFormat:@"%@ <sip:%@>", [anAccount fullName], [anAccount sipAddress]];
	accountConfig.id = [fullSIPURL pjString];
	
	NSString *registerURI = [NSString stringWithFormat:@"sip:%@", [anAccount registrar]];
	accountConfig.reg_uri = [registerURI pjString];
	
	accountConfig.cred_count = 1;
	accountConfig.cred_info[0].realm = pj_str("*");
	accountConfig.cred_info[0].scheme = pj_str("digest");
	accountConfig.cred_info[0].username = [[anAccount username] pjString];
	accountConfig.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
	accountConfig.cred_info[0].data = [aPassword pjString];
	
	pjsua_acc_id accountIdentifier;
	pj_status_t status = pjsua_acc_add(&accountConfig, PJ_FALSE, &accountIdentifier);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error adding account %@ with status %d", anAccount, status);
		return NO;
	}
	
	[anAccount setIdentifier:accountIdentifier];
	
	[[self accounts] addObject:anAccount];
	
	[anAccount setOnline:YES];
	
	return YES;
}

- (BOOL)removeAccount:(AKTelephoneAccount *)anAccount
{
	pj_status_t status = pjsua_acc_del([anAccount identifier]);
	if (status != PJ_SUCCESS)
		return NO;
	
	NSLog(@"Removing account %@ with id %d", anAccount, [anAccount identifier]);
	[[self accounts] removeObject:anAccount];
	
	return YES;
}

- (AKTelephoneAccount *)accountByIdentifier:(NSInteger)anIdentifier
{
	for (AKTelephoneAccount *anAccount in [self accounts])
		if ([anAccount identifier] == anIdentifier)
			return [[anAccount retain] autorelease];
	
	return nil;
}

- (AKTelephoneCall *)telephoneCallByIdentifier:(NSInteger)anIdentifier
{
	for (AKTelephoneAccount *anAccount in [self accounts])
		for (AKTelephoneCall *aCall in [anAccount calls])
			if ([aCall identifier] == anIdentifier)
				return [[aCall retain] autorelease];
	
	return nil;
}

- (void)hangUpAllCalls
{
	pjsua_call_hangup_all();
}

- (BOOL)destroyUserAgent
{
	// Close ringback port.
	if (ringbackPort != NULL &&
		ringbackSlot != PJSUA_INVALID_ID)
	{
		pjsua_conf_remove_port(ringbackSlot);
		ringbackSlot = PJSUA_INVALID_ID;
		pjmedia_port_destroy(ringbackPort);
		ringbackPort = NULL;
	}
	
	if (pjPool != NULL) {
		pj_pool_release(pjPool);
		pjPool = NULL;
	}
	
	pj_status_t status;
	status = pjsua_destroy();
	
	return (status == PJ_SUCCESS) ? YES : NO;
}

@end


void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (result->status != PJ_SUCCESS)
		pjsua_perror(THIS_FILE, "NAT detection failed", result->status);
	else {
		PJ_LOG(3, (THIS_FILE, "NAT detected as %s", result->nat_type_name));
		[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneDidDetectNATNotification
															object:[AKTelephone sharedTelephone]];
	}
	
	[pool release];
}
