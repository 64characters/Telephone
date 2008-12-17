//
//  AKTelephone.m
//  Telephone
//
//  Copyright (c) 2008 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <pjsua-lib/pjsua.h>

#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "NSStringAdditions.h"

#define THIS_FILE "AKTelephone.m"


const NSInteger AKTelephoneInvalidIdentifier = PJSUA_INVALID_ID;

NSString * const AKTelephoneDidDetectNATNotification = @"AKTelephoneDidDetectNAT";

// Generic config defaults.
NSString * const AKTelephoneSTUNServerHostDefault = @"";
const NSInteger AKTelephoneSTUNServerPortDefault = 3478;
NSString * const AKTelephoneLogFileNameDefault = @"~/Library/Logs/Telephone.log";
const NSInteger AKTelephoneLogLevelDefault = 3;
const NSInteger AKTelephoneConsoleLogLevelDefault = 0;
const BOOL AKTelephoneDetectsVoiceActivityDefault = YES;
const NSInteger AKTelephoneTransportPortDefault = 0;	// 0 for any available port.

static AKTelephone *sharedTelephone = nil;

typedef enum _AKTelephoneRingtones {
	AKRingbackFrequency1	= 440,
	AKRingbackFrequency2	= 480,
	AKRingbackOnDuration	= 2000,
	AKRingbackOffDuration	= 4000,
	AKRingbackCount			= 1,
	AKRingbackInterval		= 4000
} AKTelephoneRingtones;


@interface AKTelephone()

@property(readwrite, assign) BOOL started;
@property(readwrite, assign) BOOL soundStopped;

@end


@implementation AKTelephone

@dynamic delegate;
@synthesize accounts;
@synthesize started;
@synthesize soundStopped;
@dynamic activeCallsCount;
@dynamic callData;
@synthesize pjPool;
@synthesize ringbackSlot;
@synthesize ringbackCount;
@synthesize ringbackPort;

@synthesize STUNServerHost;
@dynamic STUNServerPort;
@synthesize userAgentString;
@dynamic logFileName;
@synthesize logLevel;
@synthesize consoleLogLevel;
@synthesize detectsVoiceActivity;
@dynamic transportPort;

- (id <AKTelephoneDelegate>)delegate
{
	return delegate;
}

- (void)setDelegate:(id <AKTelephoneDelegate>)aDelegate
{
	if (delegate == aDelegate)
		return;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if (delegate != nil)
		[notificationCenter removeObserver:delegate name:nil object:self];
	
	if (aDelegate != nil) {
		if ([aDelegate respondsToSelector:@selector(telephoneDidDetectNAT:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneDidDetectNAT:)
									   name:AKTelephoneDidDetectNATNotification
									 object:self];
	}
	
	delegate = aDelegate;
}

- (NSUInteger)activeCallsCount
{
	return pjsua_call_get_count();
}

- (AKTelephoneCallData *)callData
{
	return callData;
}

- (NSUInteger)STUNServerPort
{
	return STUNServerPort;
}

- (void)setSTUNServerPort:(NSUInteger)port
{
	if (port > 0 && port < 65535)
		STUNServerPort = port;
	else
		STUNServerPort = AKTelephoneSTUNServerPortDefault;
}

- (NSString *)logFileName
{
	return [[logFileName copy] autorelease];
}

- (void)setLogFileName:(NSString *)pathToFile
{
	if (logFileName != pathToFile) {
		if ([pathToFile length] > 0) {
			[logFileName release];
			logFileName = [pathToFile copy];
		} else {
			[logFileName release];
			logFileName = AKTelephoneLogFileNameDefault;
		}
			
	}
}

- (NSUInteger)transportPort
{
	return transportPort;
}

- (void)setTransportPort:(NSUInteger)port
{
	if (port > 0 && port < 65535)
		transportPort = port;
	else
		transportPort = AKTelephoneTransportPortDefault;
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
	[self setStarted:NO];
	[self setSoundStopped:YES];
	
	[self setSTUNServerHost:AKTelephoneSTUNServerHostDefault];
	[self setSTUNServerPort:AKTelephoneSTUNServerPortDefault];
	[self setLogFileName:AKTelephoneLogFileNameDefault];
	[self setLogLevel:AKTelephoneLogLevelDefault];
	[self setConsoleLogLevel:AKTelephoneConsoleLogLevelDefault];
	[self setDetectsVoiceActivity:AKTelephoneDetectsVoiceActivityDefault];
	[self setTransportPort:AKTelephoneTransportPortDefault];
	
	return self;
}

- (id)init
{
	return [self initWithDelegate:nil];
}

- (void)dealloc
{
	[accounts release];
	[STUNServerHost release];
	[logFileName release];
	
	[super dealloc];
}


#pragma mark -

- (BOOL)startUserAgent
{
	pj_status_t status;
	
	// Create PJSUA.
	status = pjsua_create();
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating PJSUA");
		return NO;
	}
	// Create pool for PJSUA.
	pjPool = pjsua_pool_create("telephone-pjsua", 1000, 1000);
	
	pjsua_config userAgentConfig;
	pjsua_logging_config loggingConfig;
	pjsua_media_config mediaConfig;
	pjsua_transport_config transportConfig;
	
	pjsua_config_default(&userAgentConfig);
	pjsua_logging_config_default(&loggingConfig);
	pjsua_media_config_default(&mediaConfig);
	pjsua_transport_config_default(&transportConfig);
	
	ringbackSlot = PJSUA_INVALID_ID;
	userAgentConfig.max_calls = AKTelephoneCallsMax;
	
	if ([[self STUNServerHost] length] > 0)
		userAgentConfig.stun_host = [[NSString stringWithFormat:@"%@:%u",
									  [self STUNServerHost], [self STUNServerPort]]
									 pjString];
	userAgentConfig.user_agent = [[self userAgentString] pjString];
	loggingConfig.log_filename = [[[self logFileName] stringByExpandingTildeInPath] pjString];
	loggingConfig.level = [self logLevel];
	loggingConfig.console_level = [self consoleLogLevel];
	mediaConfig.no_vad = ![self detectsVoiceActivity];
	transportConfig.port = [self transportPort];
	
	userAgentConfig.cb.on_incoming_call = AKIncomingCallReceived;
	userAgentConfig.cb.on_call_media_state = AKCallMediaStateChanged;
	userAgentConfig.cb.on_call_state = AKCallStateChanged;
	userAgentConfig.cb.on_reg_state = AKTelephoneAccountRegistrationStateChanged;
	userAgentConfig.cb.on_nat_detect = AKTelephoneDetectedNAT;
	
	// Initialize PJSUA.
	status = pjsua_init(&userAgentConfig, &loggingConfig, &mediaConfig);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error initializing PJSUA");
		[self destroyUserAgent];
		return NO;
	}
	
	// Create ringback tones.
	unsigned i, samplesPerFrame;
	pjmedia_tone_desc tone[AKRingbackCount];
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
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating ringback tones");
		[self destroyUserAgent];
		return NO;
	}
	
	pj_bzero(&tone, sizeof(tone));
	for (i = 0; i < AKRingbackCount; ++i) {
		tone[i].freq1 = AKRingbackFrequency1;
		tone[i].freq2 = AKRingbackFrequency2;
		tone[i].on_msec = AKRingbackOnDuration;
		tone[i].off_msec = AKRingbackOffDuration;
	}
	tone[AKRingbackCount - 1].off_msec = AKRingbackInterval;
	
	pjmedia_tonegen_play(ringbackPort, AKRingbackCount, tone, PJMEDIA_TONEGEN_LOOP);
	
	status = pjsua_conf_add_port(pjPool, ringbackPort, &ringbackSlot);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error adding media port for ringback tones");
		[self destroyUserAgent];
		return NO;
	}
	
	// Add UDP transport.
	pjsua_transport_id transportIdentifier;
	status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, &transportIdentifier);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating transport");
		[self destroyUserAgent];
		return NO;
	}
	
	// Get transport port chosen by PJSUA.
	if ([self transportPort] == 0) {
		pjsua_transport_info transportInfo;
		status = pjsua_transport_get_info(transportIdentifier, &transportInfo);
		if (status != PJ_SUCCESS)
			NSLog(@"Error getting transport info");
		[self setTransportPort:transportInfo.local_name.port];
	}
	NSLog(@"Bound to local port %u", [self transportPort]);
	
	// Start PJSUA.
	status = pjsua_start();
	if (status != PJ_SUCCESS) {
		NSLog(@"Error starting PJSUA");
		[self destroyUserAgent];
		return NO;
	}
	
	[self setStarted:YES];
	
	return YES;
}

- (BOOL)destroyUserAgent
{
	[self setStarted:NO];
	
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
	
	// Destroy PJSUA.
	pj_status_t status;
	status = pjsua_destroy();
	
	if (status != PJ_SUCCESS) {
		NSLog(@"Error destroying PJSUA");
		return NO;
	}
	
	return YES;
}

- (BOOL)addAccount:(AKTelephoneAccount *)anAccount withPassword:(NSString *)aPassword
{
	if ([[self delegate] respondsToSelector:@selector(telephoneShouldAddAccount:)])
		if (![[self delegate] telephoneShouldAddAccount:anAccount])
			return NO;
	
	pjsua_acc_config accountConfig;
	pjsua_acc_config_default(&accountConfig);
	
	NSString *fullSIPURL = [NSString stringWithFormat:@"%@ <sip:%@>", [anAccount fullName], [anAccount SIPAddress]];
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
	if (![self started] || [anAccount identifier] == PJSUA_INVALID_ID)
		return NO;
	
	pj_status_t status = pjsua_acc_del([anAccount identifier]);
	if (status != PJ_SUCCESS)
		return NO;
	
	[[self accounts] removeObject:anAccount];
	[anAccount setIdentifier:PJSUA_INVALID_ID];
	
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

- (BOOL)setSoundInputDevice:(NSInteger)input soundOutputDevice:(NSInteger)output
{
	if (![self started])
		return NO;
	
	pj_status_t status = pjsua_set_snd_dev(input, output);
	
	[self setSoundStopped:NO];
	
	return (status == PJ_SUCCESS) ? YES : NO;
}

- (BOOL)stopSound
{
	if (![self started])
		return NO;
	
	pj_status_t status = pjsua_set_null_snd_dev();
	
	[self setSoundStopped:YES];

	return (status == PJ_SUCCESS) ? YES : NO;
}

// This method will leave application silent.
// setSoundInputDevice:soundOutputDevice: must be called explicitly after calling this method to set sound IO.
// Usually, application controller is responsible of sending setSoundInputDevice:soundOutputDevice: to set sound IO after this method is called.
- (void)updateAudioDevices
{
	if (![self started])
		return;
	
	// Stop sound device and disconnect it from the conference.
	pjsua_set_null_snd_dev();
	
	// Reinit sound device.
	pjmedia_snd_deinit();
	pjmedia_snd_init(pjsua_get_pool_factory());
}

@end


void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (result->status != PJ_SUCCESS)
		pjsua_perror(THIS_FILE, "NAT detection failed", result->status);
	else {
		PJ_LOG(3, (THIS_FILE, "NAT detected as %s", result->nat_type_name));
		NSNotification *notification = [NSNotification notificationWithName:AKTelephoneDidDetectNATNotification
																	 object:[AKTelephone sharedTelephone]];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
															   withObject:notification
															waitUntilDone:NO];
	}
	
	[pool release];
}
