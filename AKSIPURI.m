//
//  AKSIPURI.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <pjsua-lib/pjsua.h>

#import "AKSIPURI.h"
#import "AKTelephone.h"
#import "NSString+PJSUA.h"


@implementation AKSIPURI

@dynamic SIPAddress;
@synthesize displayName;
@synthesize user;
@synthesize password;
@synthesize host;
@synthesize port;
@synthesize userParameter;
@synthesize methodParameter;
@synthesize transportParameter;
@synthesize TTLParameter;
@synthesize looseRoutingParameter;
@synthesize maddrParameter;

- (NSString *)SIPAddress
{
	if ([[self user] isEqualToString:@""])
		return [self host];
	else
		return [NSString stringWithFormat:@"%@@%@", [self user], [self host]];
}

- (id)initWithString:(NSString *)SIPURIString
{
	self = [super init];
	if (self == nil)
		return nil;
	
	pjsip_name_addr *nameAddr;
	nameAddr = (pjsip_name_addr *)pjsip_parse_uri([[AKTelephone sharedTelephone] pjPool],
												  (char *)[SIPURIString cStringUsingEncoding:NSASCIIStringEncoding],
												  [SIPURIString length], PJSIP_PARSE_URI_AS_NAMEADDR);
	if (nameAddr == NULL)
		return nil;
	
	[self setDisplayName:[NSString stringWithPJString:nameAddr->display]];
	
	pjsip_sip_uri *uri = (pjsip_sip_uri *)pjsip_uri_get_uri(nameAddr);
	[self setUser:[NSString stringWithPJString:uri->user]];
	[self setPassword:[NSString stringWithPJString:uri->passwd]];
	[self setHost:[NSString stringWithPJString:uri->host]];
	[self setPort:uri->port];
	[self setUserParameter:[NSString stringWithPJString:uri->user_param]];
	[self setMethodParameter:[NSString stringWithPJString:uri->method_param]];
	[self setTransportParameter:[NSString stringWithPJString:uri->transport_param]];
	[self setTTLParameter:uri->ttl_param];
	[self setLooseRoutingParameter:uri->lr_param];
	[self setMaddrParameter:[NSString stringWithPJString:uri->maddr_param]];
	
	return self;
}

- (id)init
{
	return [self initWithString:nil];
}

+ (id)SIPURIWithString:(NSString *)SIPURIString
{
	return [[[self alloc] initWithString:SIPURIString] autorelease];
}

- (void)dealloc
{
	[displayName release];
	[user release];
	[password release];
	[host release];
	[userParameter release];
	[methodParameter release];
	[transportParameter release];
	[maddrParameter release];
	
	[super dealloc];
}

- (NSString *)description
{
	if ([[self displayName] isEqualToString:@""])
		return [NSString stringWithFormat:@"<sip:%@>", [self SIPAddress]];
	else
		return [NSString stringWithFormat:@"\"%@\" <sip:%@>", [self displayName], [self SIPAddress]];
}

@end
