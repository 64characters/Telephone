//
//  AKTelephoneCall.m
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

#import "AKSIPURI.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "NSStringAdditions.h"

#define THIS_FILE "AKTelephoneCall.m"


const NSInteger AKTelephoneCallsMax = 4;

NSString * const AKTelephoneCallCallingNotification = @"AKTelephoneCallCalling";
NSString * const AKTelephoneCallIncomingNotification = @"AKTelephoneCallIncoming";
NSString * const AKTelephoneCallEarlyNotification = @"AKTelephoneCallEarly";
NSString * const AKTelephoneCallConnectingNotification = @"AKTelephoneCallConnecting";
NSString * const AKTelephoneCallDidConfirmNotification = @"AKTelephoneCallDidConfirm";
NSString * const AKTelephoneCallDidDisconnectNotification = @"AKTelephoneCallDidDisconnect";

@implementation AKTelephoneCall

@dynamic delegate;
@synthesize identifier;
@synthesize localURI;
@synthesize remoteURI;
@synthesize state;
@synthesize stateText;
@synthesize lastStatus;
@synthesize lastStatusText;
@dynamic active;
@synthesize incoming;
@synthesize account;

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
	
	if (aDelegate != nil) {
		// Subscribe to notifications
		if ([aDelegate respondsToSelector:@selector(telephoneCallCalling:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallCalling:)
									   name:AKTelephoneCallCallingNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(telephoneCallIncoming:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallIncoming:)
									   name:AKTelephoneCallIncomingNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(telephoneCallEarly:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallEarly:)
									   name:AKTelephoneCallEarlyNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(telephoneCallConnecting:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallConnecting:)
									   name:AKTelephoneCallConnectingNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(telephoneCallDidConfirm:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallDidConfirm:)
									   name:AKTelephoneCallDidConfirmNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(telephoneCallDidDisconnect:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(telephoneCallDidDisconnect:)
									   name:AKTelephoneCallDidDisconnectNotification
									 object:self];
	}
	
	delegate = aDelegate;
}

- (BOOL)isActive
{
	if (pjsua_call_is_active([self identifier]))
		return YES;
	else
		return NO;
}


#pragma mark -

- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount identifier:(NSInteger)anIdentifier
{
	self = [super init];
	if (self == nil)
		return nil;
	
	[self setIdentifier:anIdentifier];
	[self setAccount:anAccount];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(anIdentifier, &callInfo);
	[self setRemoteURI:[AKSIPURI SIPURIWithString:[NSString stringWithPJString:callInfo.remote_info]]];
	[self setLocalURI:[AKSIPURI SIPURIWithString:[NSString stringWithPJString:callInfo.local_info]]];
	
	[self setIncoming:NO];
	
	return self;
}

- (id)init
{	
	return [self initWithTelephoneAccount:nil identifier:PJSUA_INVALID_ID];
}

- (void)dealloc
{
	if ([[AKTelephone sharedTelephone] started] && [self identifier] != PJSUA_INVALID_ID && [self isActive])
		[self hangUp];
	
	[self setDelegate:nil];
	
	[localURI release];
	[remoteURI release];
	[lastStatusText release];
	[self setAccount:nil];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <=> %@", [self localURI], [self remoteURI]];
}

- (void)answer
{
	pj_status_t status = pjsua_call_answer([self identifier], 200, NULL, NULL);
	if (status != PJ_SUCCESS)
		NSLog(@"Error answering call %@", self);
}

- (void)hangUp
{
	pj_status_t status = pjsua_call_hangup([self identifier], 0, NULL, NULL);
	if (status != PJ_SUCCESS)
		NSLog(@"Error hanging up call %@", self);
}

- (void)ringbackStart
{
	AKTelephone *telephone = [AKTelephone sharedTelephone];
	
	// Use dot syntax for properties to prevent square bracket clutter.
	if (telephone.callData[self.identifier].ringbackOn)
		return;
	
	telephone.callData[self.identifier].ringbackOn = PJ_TRUE;
	
	[telephone setRingbackCount:[telephone ringbackCount] + 1];
	if ([telephone ringbackCount] == 1 && [telephone ringbackSlot] != PJSUA_INVALID_ID)
		pjsua_conf_connect([telephone ringbackSlot], 0);
}

- (void)ringbackStop
{
	AKTelephone *telephone = [AKTelephone sharedTelephone];
	
	// Use dot syntax for properties to prevent square bracket clutter.
	if (telephone.callData[self.identifier].ringbackOn) {
		telephone.callData[self.identifier].ringbackOn = PJ_FALSE;
		
		pj_assert([telephone ringbackCount] > 0);
		
		[telephone setRingbackCount:[telephone ringbackCount] - 1];
		if ([telephone ringbackCount] == 0 && [telephone ringbackSlot] != PJSUA_INVALID_ID) {
			pjsua_conf_disconnect([telephone ringbackSlot], 0);
			pjmedia_tonegen_rewind([telephone ringbackPort]);
		}
	}
}

- (void)sendDTMFDigits:(NSString *)digits
{
	pj_status_t status;
	pj_str_t pjDigits = [digits pjString];
	
	// Try to send RFC2833 DTMF first.
	status = pjsua_call_dial_dtmf([self identifier], &pjDigits);
	
	if (status != PJ_SUCCESS) {		// Okay, that didn't work. Send INFO DTMF.
		const pj_str_t SIPINFO = pj_str("INFO");
		
		for (NSUInteger i = 0; i < [digits length]; ++i) {
			pjsua_msg_data messageData;
			pjsua_msg_data_init(&messageData);
			messageData.content_type = pj_str("application/dtmf-relay");
			
			NSString *messageBody = [NSString stringWithFormat:@"Signal=%C\r\nDuration=160",
									 [digits characterAtIndex:i]];
			messageData.msg_body = [messageBody pjString];
			
			status = pjsua_call_send_request([self identifier], &SIPINFO, &messageData);
			if (status != PJ_SUCCESS)
				NSLog(@"Error sending DTMF");
		}
	}
}

@end


#pragma mark -
#pragma mark Callbacks

// When incoming call is received, create call object, set its info,
// attach to the account, add to the array, send notification
void AKIncomingCallReceived(pjsua_acc_id accountIdentifier, pjsua_call_id callIdentifier, pjsip_rx_data *messageData)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	
	PJ_LOG(3, (THIS_FILE,
			   "Incoming call for account %d!\n"
			   "From: %s\n"
			   "To: %s\n",
			   accountIdentifier,
			   callInfo.remote_info.ptr,
			   callInfo.local_info.ptr));
	
	AKTelephoneAccount *theAccount = [[AKTelephone sharedTelephone] accountByIdentifier:accountIdentifier];
	
	// AKTelephoneCall object is created here when the call is incoming
	AKTelephoneCall *theCall = [[AKTelephoneCall alloc] initWithTelephoneAccount:theAccount
																	  identifier:callIdentifier];
	[theCall setState:callInfo.state];
	[theCall setStateText:[NSString stringWithPJString:callInfo.state_text]];
	[theCall setLastStatus:callInfo.last_status];
	[theCall setLastStatusText:[NSString stringWithPJString:callInfo.last_status_text]];
	[theCall setIncoming:YES];
	
	// Keep the new call in the account's calls array
	[[theAccount calls] addObject:theCall];
	
	if ([[theAccount delegate] respondsToSelector:@selector(telephoneAccountDidReceiveCall:)])
		[[theAccount delegate] performSelectorOnMainThread:@selector(telephoneAccountDidReceiveCall:)
												withObject:theCall
											 waitUntilDone:NO];
	
	NSNotification *notification = [NSNotification notificationWithName:AKTelephoneCallIncomingNotification
																 object:theCall];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
														   withObject:notification
														waitUntilDone:NO];
	[theCall release];
	
	[pool release];
}

// Track changes in calls state. Send notifications
void AKCallStateChanged(pjsua_call_id callIdentifier, pjsip_event *sipEvent)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSNotification *notification = nil;
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	
	AKTelephoneCall *theCall = [[[AKTelephone sharedTelephone] telephoneCallByIdentifier:callIdentifier] retain];
	
	[theCall setState:callInfo.state];
	[theCall setStateText:[NSString stringWithPJString:callInfo.state_text]];
	[theCall setLastStatus:callInfo.last_status];
	[theCall setLastStatusText:[NSString stringWithPJString:callInfo.last_status_text]];
	
	if (callInfo.state == PJSIP_INV_STATE_DISCONNECTED) {
		[theCall ringbackStop];
		
		PJ_LOG(3, (THIS_FILE, "Call %d is DISCONNECTED [reason = %d (%s)]",
				   callIdentifier,
				   callInfo.last_status,
				   callInfo.last_status_text.ptr));
		
		[theCall setIdentifier:PJSUA_INVALID_ID];
		
		notification = [NSNotification notificationWithName:AKTelephoneCallDidDisconnectNotification
													 object:theCall];
		[notificationCenter performSelectorOnMainThread:@selector(postNotification:)
											 withObject:notification
										  waitUntilDone:NO];
		
		// Finally, remove the call from its account's calls array
		[[[theCall account] calls] removeObject:theCall];
		
	} else {
		if (callInfo.state == PJSIP_INV_STATE_EARLY) {
			// pj_str_t is a struct with NOT null-terminated string
			pj_str_t reason;
			pjsip_msg *msg;
			int code;
			
			// This can only occur because of TX or RX message
			pj_assert(sipEvent->type == PJSIP_EVENT_TSX_STATE);
			
			if (sipEvent->body.tsx_state.type == PJSIP_EVENT_RX_MSG)
				msg = sipEvent->body.tsx_state.src.rdata->msg_info.msg;
			else
				msg = sipEvent->body.tsx_state.src.tdata->msg;
			
			code = msg->line.status.code;
			reason = msg->line.status.reason;
			
			// Start ringback for 180 for UAC unless there's SDP in 180
			if (callInfo.role == PJSIP_ROLE_UAC && code == 180 &&
				msg->body == NULL && callInfo.media_status == PJSUA_CALL_MEDIA_NONE)
			{
				[theCall ringbackStart];
			}
			
			PJ_LOG(3,(THIS_FILE, "Call %d state changed to %s (%d %.*s)",
					  callIdentifier, callInfo.state_text.ptr,
					  code, (int)reason.slen, reason.ptr));
			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:code], @"AKSIPEventCode",
									  [NSString stringWithPJString:reason], @"AKSIPEventReason",
									  nil];
			
			notification = [NSNotification notificationWithName:AKTelephoneCallEarlyNotification
														 object:theCall
													   userInfo:userInfo];
			[notificationCenter performSelectorOnMainThread:@selector(postNotification:)
												 withObject:notification
											  waitUntilDone:NO];
		} else {
			PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s",
					   callIdentifier,
					   callInfo.state_text.ptr));
			
			// Incoming call notification is posted in another funcion: AKIncomingCallReceived()
			NSString *notificationName = nil;
			switch (callInfo.state) {
				case PJSIP_INV_STATE_CALLING:
					notificationName = AKTelephoneCallCallingNotification;
					break;
				case PJSIP_INV_STATE_CONNECTING:
					notificationName = AKTelephoneCallConnectingNotification;
					break;
				case PJSIP_INV_STATE_CONFIRMED:
					notificationName = AKTelephoneCallDidConfirmNotification;
					break;
				default:
					break;
			}
			
			if (notificationName != nil) {
				notification = [NSNotification notificationWithName:notificationName
															 object:theCall];
				[notificationCenter performSelectorOnMainThread:@selector(postNotification:)
													 withObject:notification
												  waitUntilDone:NO];
			}
		}
	}
	
	[theCall release];
	
	[pool release];
}

// Track and log media changes
void AKCallMediaStateChanged(pjsua_call_id callIdentifier)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	
	AKTelephoneCall *theCall = [[[AKTelephone sharedTelephone] telephoneCallByIdentifier:callIdentifier] retain];
	[theCall ringbackStop];
	[theCall release];
	
	if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
		// When media is active, connect call to sound device
		pjsua_conf_connect(callInfo.conf_slot, 0);
		pjsua_conf_connect(0, callInfo.conf_slot);
		
		PJ_LOG(3, (THIS_FILE, "Media for call %d is active", callIdentifier));
		
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is suspended (hold) by local",
				   callIdentifier));
		
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is suspended (hold) by remote",
				   callIdentifier));
		
	} else if (callInfo.media_status == PJSUA_CALL_MEDIA_ERROR) {
		pj_str_t reason = pj_str("ICE negotiation failed");
		PJ_LOG(1, (THIS_FILE, "Media has reported error, disconnecting call"));
		
		pjsua_call_hangup(callIdentifier, 500, &reason, NULL);
		
	} else {
		PJ_LOG(3, (THIS_FILE, "Media for call %d is inactive", callIdentifier));
	}
	
	[pool release];
}
