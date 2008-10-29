//
//  AKTelephoneCall.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 16.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "NSString+PJSUA.h"

#define THIS_FILE "AKTelephoneCall.m"


const NSInteger AKTelephoneCallsMax = 4;

NSString *AKTelephoneCallCallingNotification = @"AKTelephoneCallCalling";
NSString *AKTelephoneCallIncomingNotification = @"AKTelephoneCallIncoming";
NSString *AKTelephoneCallEarlyNotification = @"AKTelephoneCallEarly";
NSString *AKTelephoneCallConnectingNotification = @"AKTelephoneCallConnecting";
NSString *AKTelephoneCallDidConfirmNotification = @"AKTelephoneCallDidConfirm";
NSString *AKTelephoneCallDidDisconnectNotification = @"AKTelephoneCallDidDisconnect";

@implementation AKTelephoneCall

@dynamic delegate;
@synthesize identifier;
@synthesize localInfo;
@synthesize remoteInfo;
@dynamic state;
@dynamic stateText;
@synthesize lastStatus;
@synthesize lastStatusText;
@dynamic active;
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

- (NSInteger)state
{
	pjsua_call_info callInfo;
	
	pjsua_call_get_info([self identifier], &callInfo);
	
	return callInfo.state;
}

- (NSString *)stateText
{
	pjsua_call_info callInfo;
	pj_status_t status;
	
	status = pjsua_call_get_info([self identifier], &callInfo);
	if (status != PJ_SUCCESS)
		return nil;
	
	return [NSString stringWithPJString:callInfo.state_text];
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
	
	return self;
}

- (id)init
{	
	return [self initWithTelephoneAccount:nil identifier:PJSUA_INVALID_ID];
}

- (void)dealloc
{
	if ([self identifier] != PJSUA_INVALID_ID && [self isActive])
		[self hangUp];
	
	[self setDelegate:nil];
	
	[localInfo release];
	[remoteInfo release];
	[lastStatusText release];
	[self setAccount:nil];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <=> %@", [self localInfo], [self remoteInfo]];
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
	
	NSString *remoteInfo = [NSString stringWithPJString:callInfo.remote_info];
	NSString *localInfo = [NSString stringWithPJString:callInfo.local_info];
	
	AKTelephoneAccount *theAccount = [[AKTelephone sharedTelephone] accountByIdentifier:accountIdentifier];
	
	// AKTelephoneCall object is created here when the call is incoming
	AKTelephoneCall *theCall = [[AKTelephoneCall alloc] initWithTelephoneAccount:theAccount
																	  identifier:callIdentifier];
	[theCall setRemoteInfo:remoteInfo];
	[theCall setLocalInfo:localInfo];
	
	// Keep the new call in the account's calls array
	[[theAccount calls] addObject:theCall];
	NSLog(@"%@ was added to the account %@", theCall, theAccount);
	
	if ([[theAccount delegate] respondsToSelector:@selector(telephoneAccount:didReceiveCall:)])
		[[theAccount delegate] telephoneAccount:theAccount didReceiveCall:theCall];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneCallIncomingNotification
//														object:theCall];
	
	[theCall release];
	
	[pool release];
}

// Track changes in calls state. Send notifications
void AKCallStateChanged(pjsua_call_id callIdentifier, pjsip_event *sipEvent)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	pjsua_call_info callInfo;
	pjsua_call_get_info(callIdentifier, &callInfo);
	
	AKTelephoneCall *theCall = [[[AKTelephone sharedTelephone] telephoneCallByIdentifier:callIdentifier] retain];
	
	NSString *lastStatusText, *stateText, *reasonText;
	NSDictionary *userInfo;
	
	if (callInfo.state == PJSIP_INV_STATE_DISCONNECTED) {
		[theCall ringbackStop];
		
		PJ_LOG(3, (THIS_FILE, "Call %d is DISCONNECTED [reason = %d (%s)]",
				   callIdentifier,
				   callInfo.last_status,
				   callInfo.last_status_text.ptr));
		
		lastStatusText = [NSString stringWithPJString:callInfo.last_status_text];
		
		[theCall setLastStatus:callInfo.last_status];
		[theCall setLastStatusText:lastStatusText];
		[theCall setIdentifier:PJSUA_INVALID_ID];
		
		[notificationCenter postNotificationName:AKTelephoneCallDidDisconnectNotification
										  object:theCall];
		
		// Finally, remove the call from its account's calls array
		NSLog(@"%@ will be removed from the account %@", theCall, [theCall account]);
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
			
			stateText = [NSString stringWithPJString:callInfo.state_text];
			reasonText = [NSString stringWithPJString:reason];
			userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
						stateText, @"AKTelephoneCallState",
						[NSNumber numberWithInt:code], @"AKSIPEventCode",
						reasonText, @"AKSIPEventReason",
						nil];
			
			[notificationCenter postNotificationName:AKTelephoneCallEarlyNotification
											  object:theCall
											userInfo:userInfo];
			
		} else {
			PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s",
					   callIdentifier,
					   callInfo.state_text.ptr));
			
			stateText = [NSString stringWithPJString:callInfo.state_text];
			
			// Incoming call notification is posted in another funcion: AKIncomingCallReceived()
			NSString *notificationName = nil;
			switch (callInfo.state) {
				case PJSIP_INV_STATE_CALLING:
					notificationName = AKTelephoneCallCallingNotification;
					break;
					//				case PJSIP_INV_STATE_INCOMING:
					//					notificationName = AKTelephoneCallIncomingNotification;
					//					break;
				case PJSIP_INV_STATE_CONNECTING:
					notificationName = AKTelephoneCallConnectingNotification;
					break;
				case PJSIP_INV_STATE_CONFIRMED:
					notificationName = AKTelephoneCallDidConfirmNotification;
					break;
				default:
					break;
			}
			
			if (notificationName != nil)
				[notificationCenter postNotificationName:notificationName
												  object:theCall];
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
