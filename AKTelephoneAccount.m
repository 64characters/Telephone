//
//  AKTelephoneAccount.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <pjsua-lib/pjsua.h>

#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "NSNumber+PJSUA.h"
#import "NSString+PJSUA.h"


NSString *AKTelephoneAccountFullName = @"fullName";
NSString *AKTelephoneAccountSIPAddress = @"sipAddress";
NSString *AKTelephoneAccountRegistrar = @"registrar";
NSString *AKTelephoneAccountRealm = @"realm";
NSString *AKTelephoneAccountUsername = @"username";

NSString *AKTelephoneAccountRegistrationDidChangeNotification = @"AKTelephoneAccountRegistrationDidChange";
NSString *AKTelephoneAccountDidReceiveCallNotification = @"AKTelephoneAccountDidReceiveCall";

@implementation AKTelephoneAccount

@dynamic delegate;
@synthesize fullName;
@synthesize sipAddress;
@synthesize registrar;
@synthesize realm;
@synthesize username;
@synthesize identifier;
@dynamic registered;
@dynamic registrationStatus;
@dynamic registrationStatusText;
@dynamic registrationExpireTime;
@dynamic online;
@dynamic onlineStatusText;
@synthesize calls;

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
		if ([aDelegate respondsToSelector:@selector(telephoneAccountRegistrationDidChange:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneAccountRegistrationDidChange:)
									   name:AKTelephoneAccountRegistrationDidChangeNotification
									 object:self];
	delegate = aDelegate;
}

- (BOOL)isRegistered
{	
	return ([[self registrationStatus] intValue] / 100 == 2) && ([[self registrationExpireTime] intValue] > 0);
}

- (void)setRegistered:(BOOL)value
{
	if (value) {
		pjsua_acc_set_registration([self identifier], PJ_TRUE);
		[self setOnline:YES];
	} else {
		[self setOnline:NO];
		pjsua_acc_set_registration([self identifier], PJ_FALSE);
	}
}

- (NSNumber *)registrationStatus
{
	pjsua_acc_info accountInfo;
	pj_status_t status;
	
	status = pjsua_acc_get_info([self identifier], &accountInfo);
	if (status != PJ_SUCCESS)
		return nil;
	
	return [NSNumber numberWithInt:accountInfo.status];
}

- (NSString *)registrationStatusText
{
	pjsua_acc_info accountInfo;
	pj_status_t status;
	
	status = pjsua_acc_get_info([self identifier], &accountInfo);
	if (status != PJ_SUCCESS)
		return nil;
	
	return [NSString stringWithPJString:accountInfo.status_text];
}

- (NSNumber *)registrationExpireTime
{
	pjsua_acc_info accountInfo;
	pj_status_t status;
	
	status = pjsua_acc_get_info([self identifier], &accountInfo);
	if (status != PJ_SUCCESS)
		return nil;
	
	return [NSNumber numberWithInt:accountInfo.expires];
}

- (BOOL)isOnline
{
	pjsua_acc_info accountInfo;
	pj_status_t status;
	
	status = pjsua_acc_get_info([self identifier], &accountInfo);
	if (status != PJ_SUCCESS)
		return NO;
	
	return (accountInfo.online_status == PJ_TRUE) ? YES : NO;
}

- (void)setOnline:(BOOL)value
{
	if (value)
		pjsua_acc_set_online_status([self identifier], PJ_TRUE);
	else
		pjsua_acc_set_online_status([self identifier], PJ_FALSE);
}

- (NSString *)onlineStatusText
{
	pjsua_acc_info accountInfo;
	pj_status_t status;
	
	status = pjsua_acc_get_info([self identifier], &accountInfo);
	if (status != PJ_SUCCESS)
		return nil;
	
	return [NSString stringWithPJString:accountInfo.online_status_text];
}

+ (id)telephoneAccountWithFullName:(NSString *)aFullName
						sipAddress:(NSString *)aSIPAddress
						 registrar:(NSString *)aRegistrar
							 realm:(NSString *)aRealm
						  username:(NSString *)aUsername
{
	return [[[AKTelephoneAccount alloc] initWithFullName:aFullName
											  sipAddress:aSIPAddress
											   registrar:aRegistrar
												   realm:aRealm
												username:aUsername]
			autorelease];
}

- (id)initWithFullName:(NSString *)aFullName
			sipAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername
{
	self = [super init];
	if (self == nil)
		return nil;
	
	[self setFullName:aFullName];
	[self setSipAddress:aSIPAddress];
	[self setRegistrar:aRegistrar];
	[self setRealm:aRealm];
	[self setUsername:aUsername];
	[self setIdentifier:PJSUA_INVALID_ID];
	
	calls = [[NSMutableArray alloc] init];
	
	return self;
}

- (id)init
{
	return [self initWithFullName:nil
					   sipAddress:nil
						registrar:nil
							realm:nil
						 username:nil];
}

- (void)dealloc
{
	[self setDelegate:nil];
	
	[fullName release];
	[sipAddress release];
	[registrar release];
	[realm release];
	[username release];
	
	[calls release];
	
	[super dealloc];
}

- (NSString *)description
{
	return [self sipAddress];
}

// Make outgoing call, create call object, set its info, add to the array
- (AKTelephoneCall *)makeCallTo:(NSString *)destinationURI
{
	pjsua_call_id callIdentifier;
	pj_str_t uri = [destinationURI pjString];
	
	pj_status_t status = pjsua_call_make_call([self identifier], &uri, 0, NULL, NULL, &callIdentifier);
	if (status != PJ_SUCCESS) {
		NSLog(@"Error making call to %@ via account %@", destinationURI, self);
		return nil;
	}
	
	NSLog(@"Calling %@ via account %@", destinationURI, self);
	
	// AKTelephoneCall object is created here when the call is outgoing
	AKTelephoneCall *theCall = [[AKTelephoneCall alloc]	initWithTelephoneAccount:self
																	  identifier:callIdentifier];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	[theCall setRemoteInfo:[NSString stringWithPJString:callInfo.remote_info]];
	[theCall setLocalInfo:[NSString stringWithPJString:callInfo.local_info]];
	
	// Keep this call in the calls array for this account
	[[self calls] addObject:theCall];
	NSLog(@"%@ was added to the account %@", theCall, self);
	
	return [theCall autorelease];
}

- (BOOL)unregister
{
	pj_status_t status;
	status = pjsua_acc_set_registration([self identifier], PJ_FALSE);
	
	return (status == PJ_SUCCESS) ? YES : NO;
}

@end


#pragma mark -
#pragma mark Callbacks

void AKTelephoneAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	AKTelephoneAccount *anAccount = [[AKTelephone sharedTelephone] accountByIdentifier:accountIdentifier];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneAccountRegistrationDidChangeNotification
														object:anAccount];
	[pool release];
}
