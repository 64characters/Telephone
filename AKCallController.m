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

#import "AKActiveCallView.h"
#import "AKCallController.h"
#import "AKTelephone.h"
#import "AKTelephoneCall.h"
#import "AppController.h"
#import "NSWindowAdditions.h"


NSString * const AKTelephoneCallWindowWillCloseNotification = @"AKTelephoneCallWindowWillClose";

@implementation AKCallController

@synthesize call;
@dynamic accountController;
@synthesize displayedName;
@synthesize status;
@synthesize callStartTime;
@synthesize callTimer;

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
	[self setCallStartTime:0.0];
	[self setCallTimer:nil];
	
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
	if ([[self call] isIncoming])
		[[NSApp delegate] stopIncomingCallSoundTimer];
	
	// Return to the normal window level.
	[[self window] setLevel:NSNormalWindowLevel];
	
	[[self call] answer];
}

- (IBAction)hangUp:(id)sender
{
	if ([[self call] isIncoming])
		[[NSApp delegate] stopIncomingCallSoundTimer];
	
	// Return to the normal window level.
	[[self window] setLevel:NSNormalWindowLevel];
	
	[[self call] hangUp];
	[hangUpButton setEnabled:NO];
}

- (void)startCallTimer
{
	[self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
	[self setCallTimer:[NSTimer scheduledTimerWithTimeInterval:0.2
														target:self
													  selector:@selector(callTimerTick:)
													  userInfo:nil
													   repeats:YES]];
}

- (void)stopCallTimer
{
	if ([self callTimer] != nil) {
		[[self callTimer] invalidate];
		[self setCallTimer:nil];
	}
}

- (void)callTimerTick:(NSTimer *)theTimer
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSInteger seconds = (NSInteger)(now - [self callStartTime]);
	
	if (seconds < 3600)
		[self setStatus:[NSString stringWithFormat:@"%02d:%02d",
						 (seconds / 60) % 60,
						 seconds % 60]];
	else
		[self setStatus:[NSString stringWithFormat:@"%02d:%02d:%02d",
						 (seconds / 3600) % 24,
						 (seconds / 60) % 60,
						 seconds % 60]];
}


#pragma mark -
#pragma mark NSWindow delegate methods

// If call window is to be closed, hang up the call and send notification
- (void)windowWillClose:(NSNotification *)notification
{
	// Make shure the timer is stopped even if the call hasn't received disconnect.
	[self stopCallTimer];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneCallWindowWillCloseNotification
														object:self];
	
	if ([[self call] identifier] != AKTelephoneInvalidIdentifier && [[self call] isActive])
		[self hangUp:nil];
}


#pragma mark -
#pragma mark AKTelephoneCall notifications

- (void)telephoneCallCalling:(NSNotification *)notification
{
	[self setStatus:[NSLocalizedString(@"Calling...", @"Outgoing call in progress.") lowercaseString]];
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallEarly:(NSNotification *)notification
{
	NSNumber *sipEventCode = [[notification userInfo] objectForKey:@"AKSIPEventCode"];
	if ([sipEventCode isEqualToNumber:[NSNumber numberWithInt:PJSIP_SC_RINGING]]) {
		[callProgressIndicator stopAnimation:self];
		[self setStatus:[NSLocalizedString(@"Ringing", @"Remote party ringing.") lowercaseString]];
	}
	
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallDidConfirm:(NSNotification *)notification
{
	if ([[notification object] isIncoming])
		[[NSApp delegate] stopIncomingCallSoundTimer];
	
	[callProgressIndicator stopAnimation:self];
	[self setStatus:@"00:00"];
	
	[self startCallTimer];
	
	[[self window] resizeAndSwapToContentView:[self activeCallView] animate:YES];
	if ([[self activeCallView] acceptsFirstResponder])
		[[self window] makeFirstResponder:[self activeCallView]];
}

- (void)telephoneCallDidDisconnect:(NSNotification *)notification
{
	[self stopCallTimer];
	
	if ([[notification object] isIncoming]) {
		// Stop ringing sound.
		[[NSApp delegate] stopIncomingCallSoundTimer];
		// Set normal window level.
		[[self window] setLevel:NSNormalWindowLevel];
	}
	
	NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
	switch ([[self call] lastStatus]) {
		case PJSIP_SC_OK:
			[self setStatus:[NSLocalizedString(@"Call ended", @"Call ended.") lowercaseString]];
			break;
		case PJSIP_SC_NOT_FOUND:
			[self setStatus:[NSLocalizedString(@"Address not found", @"Address not found.") lowercaseString]];
			break;

		case PJSIP_SC_BUSY_HERE:
		case PJSIP_SC_BUSY_EVERYWHERE:
			[self setStatus:[NSLocalizedString(@"Busy", @"Busy.") lowercaseString]];
			break;
		case PJSIP_SC_DECLINE:
			[self setStatus:[NSLocalizedString(@"Call declined", @"Call declined.") lowercaseString]];
				break;
		default:
			if ([preferredLocalization isEqualToString:@"English"])
				[self setStatus:[[[self call] lastStatusText] lowercaseString]];
			else
				[self setStatus:[[[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]] lowercaseString]];
			break;
	}
	
	[[self window] resizeAndSwapToContentView:[self endedCallView] animate:YES];
	
	[callProgressIndicator stopAnimation:self];
	[hangUpButton setEnabled:NO];
	[acceptCallButton setEnabled:NO];
	[declineCallButton setEnabled:NO];
}


#pragma mark -
#pragma mark AKActiveCallViewDelegate protocol

- (void)activeCallView:(AKActiveCallView *)sender didReceiveText:(NSString *)aString
{
	NSCharacterSet *DTMFCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"];
	
	BOOL isValid = YES;
	
	for (NSUInteger i = 0; i < [aString length]; ++i) {
		unichar digit = [aString characterAtIndex:i];
		if (![DTMFCharacterSet characterIsMember:digit]) {
			isValid = NO;
			break;
		}
	}
	
	if (isValid)
		[[self call] sendDTMFDigits:aString];
}

@end
