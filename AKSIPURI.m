//
//  AKSIPURI.m
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

#import "AKSIPURI.h"
#import "AKTelephone.h"
#import "NSStringAdditions.h"


@interface AKSIPURI()

@property(readwrite, copy) NSString *displayName;
@property(readwrite, copy) NSString *user;
@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *host;
@property(readwrite, assign) NSInteger port;
@property(readwrite, copy) NSString *userParameter;
@property(readwrite, copy) NSString *methodParameter;
@property(readwrite, copy) NSString *transportParameter;
@property(readwrite, assign) NSInteger TTLParameter;
@property(readwrite, assign) NSInteger looseRoutingParameter;
@property(readwrite, copy) NSString *maddrParameter;

@end

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
	if ([[self user] length] > 0)
		return [NSString stringWithFormat:@"%@@%@", [self user], [self host]];
	else
		return [self host];
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
	
	NSString *aDisplayName = [NSString stringWithPJString:nameAddr->display];
	if ([aDisplayName isEqualToString:@""])
		[self setDisplayName:@"Anonymous"];
	else
		[self setDisplayName:aDisplayName];
	
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
	return [NSString stringWithFormat:@"\"%@\" <sip:%@>", [self displayName], [self SIPAddress]];
}

@end
