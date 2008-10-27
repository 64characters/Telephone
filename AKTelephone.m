//
//  AKTelephone.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <pjsua-lib/pjsua.h>

#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "AKTelephoneConfig.h"
#import "NSNumber+PJSUA.h"
#import "NSString+PJSUA.h"


NSString *AKTelephoneDidDetectNATNotification = @"AKTelephoneDidDetectNAT";

static AKTelephone *sharedTelephone = nil;

@implementation AKTelephone

@dynamic delegate;
@synthesize accounts;
@synthesize readyState;

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


#pragma mark Telephone singleton instance

+ (id)telephoneWithConfig:(AKTelephoneConfig *)config delegate:(id)aDelegate
{
	@synchronized(self) {
		if (sharedTelephone == nil)
			[[self alloc] initWithConfig:config delegate:aDelegate];	// Assignment not done here
	}
	
	return sharedTelephone;
}

+ (id)telephoneWithConfig:(AKTelephoneConfig *)config
{
	return [self telephoneWithConfig:config delegate:nil];
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

- (id)initWithConfig:(AKTelephoneConfig *)config delegate:(id)aDelegate
{
	self = [super init];
	if (self == nil)
		return nil;
	
	[self setDelegate:aDelegate];
	accounts = [[NSMutableArray alloc] init];

	pj_status_t status;
	
	NSLog(@"pjsua_create()");
	status = pjsua_create();
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating pjsua");
		[self release];
		return nil;
	}
	[self setReadyState:AKTelephoneCreated];
	
	NSLog(@"pjsua_init()");
	status = pjsua_init([config userAgentConfig], [config loggingConfig], [config mediaConfig]);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error initializing pjsua");
		[self release];
		return nil;
	}
	[self setReadyState:AKTelephoneConfigured];
	
	NSLog(@"pjsua_transport_create()");
	status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, [config transportConfig], NULL);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error creating transport");
		[self release];
		return nil;
	}
	[self setReadyState:AKTelephoneTransportCreated];
	
	NSLog(@"pjsua_start()");
	status = pjsua_start();
	if (status != PJ_SUCCESS) {
		NSLog(@"Error starting pjsua");
		[self release];
		return nil;
	}
	[self setReadyState:AKTelephoneStarted];
	
	return self;
}

- (id)initWithConfig:(AKTelephoneConfig *)config
{	
	return [self initWithConfig:config delegate:nil];
}

- (id)init
{
	return [self initWithConfig:[AKTelephoneConfig telephoneConfig]];
}

- (void)dealloc
{
	[accounts release];
	
	[super dealloc];
}


#pragma mark -

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
	
	[anAccount setIdentifier:[NSNumber numberWithPJSUAAccountIdentifier:accountIdentifier]];
	
	[[self accounts] addObject:anAccount];
	
	[anAccount setOnline:YES];
	
	return YES;
}

- (BOOL)removeAccount:(AKTelephoneAccount *)anAccount
{
	pj_status_t status = pjsua_acc_del([[anAccount identifier] pjsuaAccountIdentifierValue]);
	if (status != PJ_SUCCESS)
		return NO;
	
	NSLog(@"Removing account %@ with id %@", anAccount, [anAccount identifier]);
	[[self accounts] removeObject:anAccount];
	
	return YES;
}

- (AKTelephoneAccount *)accountByIdentifier:(NSNumber *)anIdentifier
{
	for (AKTelephoneAccount *anAccount in [self accounts])
		if ([[anAccount identifier] isEqualToNumber:anIdentifier])
			return [[anAccount retain] autorelease];
	
	return nil;
}

- (AKTelephoneCall *)telephoneCallByIdentifier:(NSNumber *)anIdentifier
{
	for (AKTelephoneAccount *anAccount in [self accounts])
		for (AKTelephoneCall *aCall in [anAccount calls])
			if ([[aCall identifier] isEqualToNumber:anIdentifier])
				return [[aCall retain] autorelease];
	
	return nil;
}

- (void)hangUpAllCalls
{
	pjsua_call_hangup_all();
}

- (void)destroyUserAgent
{
	pjsua_destroy();
}

@end


void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (result->status != PJ_SUCCESS)
		pjsua_perror("AKTelephone.h", "NAT detection failed", result->status);
	else {
		PJ_LOG(3, ("AKTelephone.h", "NAT detected as %s", result->nat_type_name));
		[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneDidDetectNATNotification
															object:[AKTelephone sharedTelephone]];
	}
	
	[pool release];
}
