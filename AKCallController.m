//
//  AKCallController.m
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

#import "AKCallController.h"
#import "AKTelephone.h"
#import "AKTelephoneCall.h"
#import "NSWindowAdditions.h"


NSString *AKTelephoneCallWindowWillCloseNotification = @"AKTelephoneCallWindowWillClose";

@implementation AKCallController

@synthesize call;
@dynamic accountController;
@synthesize status;

@synthesize incomingCallView;
@synthesize activeCallView;
@synthesize endedCallView;
@synthesize callProgressIndicator;

- (AKAccountController *)accountController
{
	return accountController;
}

- (void)setAccountController:(AKAccountController *)anAccountController
{
	if (accountController == anAccountController)
		return;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if (accountController != nil)
		[notificationCenter removeObserver:accountController name:nil object:self];
	
	if (anAccountController != nil) {
		if ([anAccountController respondsToSelector:@selector(telephoneCallWindowWillClose:)])
			[notificationCenter addObserver:anAccountController
								   selector:@selector(telephoneCallWindowWillClose:)
									   name:AKTelephoneCallWindowWillCloseNotification
									 object:self];
	}
	
	accountController = anAccountController;
}

- (id)initWithTelephoneCall:(AKTelephoneCall *)aCall
		  accountController:(AKAccountController *)anAccountController
{
	self = [super initWithWindowNibName:@"Call"];
	if (self == nil)
		return nil;
	
	[self setCall:aCall];
	[call setDelegate:self];
	
	[self setAccountController:anAccountController];
	
	return self;
}

- (id)init
{	
	return [self initWithTelephoneCall:nil accountController:nil];
}

- (void)dealloc
{
	if ([[[self call] delegate] isEqual:self])
		[[self call] setDelegate:nil];
	
	[call release];
	
	[self setAccountController:nil];
	
	[super dealloc];
}

- (NSString *)description
{
	return [[self call] description];
}

- (IBAction)acceptCall:(id)sender
{
	[[self call] answer];
}

- (IBAction)hangUp:(id)sender
{
	[[self call] hangUp];
	[hangUpButton setEnabled:NO];
}


#pragma mark -

// If call window is to be closed, hang up the call and send notification
- (void)windowWillClose:(NSNotification *)notification
{
	if ([[self call] identifier] != AKTelephoneInvalidIdentifier && [[self call] isActive])
		[[self call] hangUp];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneCallWindowWillCloseNotification
														object:self];
}

- (void)telephoneCallCalling:(NSNotification *)notification
{
	[self setStatus:@"Calling..."];
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallEarly:(NSNotification *)notification
{
	NSNumber *sipEventCode = [[notification userInfo] objectForKey:@"AKSIPEventCode"];
	if ([sipEventCode isEqualToNumber:[NSNumber numberWithInt:PJSIP_SC_RINGING]]) {
		[callProgressIndicator stopAnimation:self];
		[self setStatus:@"Ringing"];
	}
	
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallDidConfirm:(NSNotification *)notification
{
	[callProgressIndicator stopAnimation:self];
	[self setStatus:@"Connected"];
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallDidDisconnect:(NSNotification *)notification
{
	if ([[self call] lastStatus] == PJSIP_SC_BUSY_EVERYWHERE)
		[self setStatus:@"Busy"];
	else
		[self setStatus:@"Call ended"];
	
	[[self window] resizeAndSwapToContentView:[self endedCallView] animate:YES];
	
	[callProgressIndicator stopAnimation:self];
	[hangUpButton setEnabled:NO];
	[acceptCallButton setEnabled:NO];
	[declineCallButton setEnabled:NO];
}

@end
