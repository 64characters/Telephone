//
//  AKTelephoneConfig.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKPreferenceController.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "AKTelephoneConfig.h"
#import "NSString+PJSUA.h"


@implementation AKTelephoneConfig

@dynamic userAgentConfig;
@dynamic loggingConfig;
@dynamic mediaConfig;
@dynamic transportConfig;

- (pjsua_config *)userAgentConfig
{
	return &userAgentConfig;
}

- (pjsua_logging_config *)loggingConfig
{
	return &loggingConfig;
}

- (pjsua_media_config *)mediaConfig
{
	return &mediaConfig;
}

- (pjsua_transport_config *)transportConfig
{
	return &transportConfig;
}

- (id)init
{
	self = [super init];
	if (self == nil)
		return nil;
	
	pjsua_config_default(&userAgentConfig);
	pjsua_logging_config_default(&loggingConfig);
	pjsua_media_config_default(&mediaConfig);
	pjsua_transport_config_default(&transportConfig);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userAgentConfig.max_calls = AKTelephoneCallsMax;
	
	NSString *stunServerHost = [defaults stringForKey:AKSTUNServerHost];
	if (stunServerHost != nil)
		userAgentConfig.stun_host = [[NSString stringWithFormat:@"%@:%@",
									  stunServerHost, [defaults objectForKey:AKSTUNServerPort]]
									 pjString];
	
	loggingConfig.log_filename = [[[defaults stringForKey:AKLogFileName]
								   stringByExpandingTildeInPath]
								  pjString];
	loggingConfig.level = 5;
	loggingConfig.console_level = 3;
	
	mediaConfig.no_vad = ![defaults boolForKey:AKVoiceActivityDetection];
	
	transportConfig.port = [defaults integerForKey:AKTransportPort];
	
	userAgentConfig.cb.on_incoming_call = AKIncomingCallReceived;
	userAgentConfig.cb.on_call_media_state = AKCallMediaStateChanged;
	userAgentConfig.cb.on_call_state = AKCallStateChanged;
	userAgentConfig.cb.on_reg_state = AKTelephoneAccountRegistrationStateChanged;
	
	return self;
}

+ (id)telephoneConfig
{
	return [[[self alloc] init] autorelease];
}

@end
