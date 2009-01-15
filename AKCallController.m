//
//  AKCallController.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
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

#import <Growl/Growl.h>

#import "AKActiveCallView.h"
#import "AKCallController.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephone.h"
#import "AKTelephoneCall.h"
#import "AppController.h"
#import "NSStringAdditions.h"
#import "NSWindowAdditions.h"


NSString * const AKTelephoneCallWindowWillCloseNotification = @"AKTelephoneCallWindowWillClose";

@implementation AKCallController

@synthesize identifier;
@synthesize call;
@dynamic accountController;
@synthesize displayedName;
@synthesize status;
@synthesize nameFromAddressBook;
@synthesize enteredCallDestination;
@synthesize intermediateStatusTimer;
@synthesize callStartTime;
@synthesize callTimer;
@synthesize callOnHold;
@synthesize enteredDTMF;

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
	
	[self setIdentifier:[NSString AK_uuidString]];
	
	[self setCall:aCall];
	[call setDelegate:self];
	
	[self setAccountController:anAccountController];
	[self setDisplayedName:nil];
	[self setStatus:nil];
	[self setNameFromAddressBook:nil];
	[self setEnteredCallDestination:nil];
	[self setIntermediateStatusTimer:nil];
	[self setCallStartTime:0.0];
	[self setCallTimer:nil];
	[self setCallOnHold:NO];
	enteredDTMF = [[NSMutableString alloc] init];
	
	return self;
}

- (id)init
{	
	return [self initWithTelephoneCall:nil accountController:nil];
}

- (void)dealloc
{
	[identifier release];
	
	if ([[[self call] delegate] isEqual:self])
		[[self call] setDelegate:nil];
	
	[call release];
	
	[self setAccountController:nil];
	[displayedName release];
	[status release];
	[nameFromAddressBook release];
	[enteredCallDestination release];
	[enteredDTMF release];
	
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
	
	[[self call] answer];
}

- (IBAction)hangUp:(id)sender
{
	if ([[self call] isIncoming])
		[[NSApp delegate] stopIncomingCallSoundTimer];
	
	[[self call] hangUp];
	[hangUpButton setEnabled:NO];
}

- (void)startCallTimer
{
	if ([self callTimer] != nil && [[self callTimer] isValid])
		return;
	
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

- (void)setIntermediateStatus:(NSString *)newIntermediateStatus
{
	if ([self intermediateStatusTimer] != nil)
		[[self intermediateStatusTimer] invalidate];
	
	[self stopCallTimer];
	[self setStatus:newIntermediateStatus];
	[self setIntermediateStatusTimer:[NSTimer scheduledTimerWithTimeInterval:3.0
																	  target:self
																	selector:@selector(intermediateStatusTimerTick:)
																	userInfo:nil
																	 repeats:NO]];
}

- (void)intermediateStatusTimerTick:(NSTimer *)theTimer
{
	if ([[self call] isOnLocalHold])
		[self setStatus:[NSLocalizedString(@"On hold", @"Call on local hold status text.") lowercaseString]];
	else if ([[self call] isOnRemoteHold])
		[self setStatus:[NSLocalizedString(@"On remote hold", @"Call on remote hold status text.") lowercaseString]];
	else if ([[self call] isActive])
		[self startCallTimer];
	
	[self setIntermediateStatusTimer:nil];
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
	[self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
	
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
			if ([preferredLocalization isEqualToString:@"English"]) {
				[self setStatus:[[[self call] lastStatusText] lowercaseString]];
			} else {
				NSString *statusText = [[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]];
				if (statusText == nil)
					[self setStatus:[[NSString stringWithFormat:NSLocalizedString(@"Error %d", @"Error #."),
									  [[self call] lastStatus]]
									 lowercaseString]];
				else
					[self setStatus:[[[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]] lowercaseString]];
			}
			break;
	}
	
	[[self window] resizeAndSwapToContentView:[self endedCallView] animate:YES];
	
	[callProgressIndicator stopAnimation:self];
	[hangUpButton setEnabled:NO];
	[acceptCallButton setEnabled:NO];
	[declineCallButton setEnabled:NO];
	
	// Show Growl notification.
	NSString *notificationTitle;
	if ([[self nameFromAddressBook] length] > 0) {
		notificationTitle = [self nameFromAddressBook];
	} else if ([[self enteredCallDestination] length] > 0) {
		notificationTitle = [self enteredCallDestination];
	} else {
		AKSIPURIFormatter *SIPURIFormatter = [[[AKSIPURIFormatter alloc] init] autorelease];
		notificationTitle = [SIPURIFormatter stringForObjectValue:[[self call] remoteURI]];
	}
	
	if (![NSApp isActive])
		[GrowlApplicationBridge notifyWithTitle:notificationTitle
									description:[self status]
							   notificationName:AKGrowlNotificationCallEnded
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:[self identifier]];
}

- (void)telephoneCallMediaActive:(NSNotification *)notification
{
	if ([self callOnHold]) {
		[self startCallTimer];
		[self setCallOnHold:NO];
	}
}

- (void)telephoneCallDidLocalHold:(NSNotification *)notification
{
	[self setCallOnHold:YES];
	[self stopCallTimer];
	[self setStatus:[NSLocalizedString(@"On hold", @"Call on local hold status text.") lowercaseString]];
}

- (void)telephoneCallDidRemoteHold:(NSNotification *)notification
{
	[self setCallOnHold:YES];
	[self stopCallTimer];
	[self setStatus:[NSLocalizedString(@"On remote hold", @"Call on remote hold status text.") lowercaseString]];
}


#pragma mark -
#pragma mark AKActiveCallViewDelegate protocol

- (void)activeCallView:(AKActiveCallView *)sender didReceiveText:(NSString *)aString
{
	NSCharacterSet *commandsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"mMhH"];
	NSCharacterSet *microphoneMuteCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"mM"];
	NSCharacterSet *holdCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"hH"];
	NSCharacterSet *DTMFCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"];
	
	unichar firstCharacter = [aString characterAtIndex:0];
	if ([commandsCharacterSet characterIsMember:firstCharacter]) {
		if ([microphoneMuteCharacterSet characterIsMember:firstCharacter]) {
			[[self call] toggleMicrophoneMute];
			if ([[self call] isMicrophoneMuted])
				[self setIntermediateStatus:[NSLocalizedString(@"Mic muted",
															   @"Microphone muted status text.")
											 lowercaseString]];
			else
				[self setIntermediateStatus:[NSLocalizedString(@"Mic unmuted",
															   @"Microphone unmuted status text.")
											 lowercaseString]];
			
		} else if ([holdCharacterSet characterIsMember:firstCharacter]) {
			[[self call] toggleHold];
		}
		
	} else {
		BOOL isDTMFValid = YES;
		
		for (NSUInteger i = 0; i < [aString length]; ++i) {
			unichar digit = [aString characterAtIndex:i];
			if (![DTMFCharacterSet characterIsMember:digit]) {
				isDTMFValid = NO;
				break;
			}
		}
		
		if (isDTMFValid) {
			if ([[self enteredDTMF] length] == 0) {
				[[self enteredDTMF] appendString:aString];
				[[self window] setTitle:[self displayedName]];
				[[displayedNameField cell] setLineBreakMode:NSLineBreakByTruncatingHead];
				[self setDisplayedName:aString];
			} else {
				[[self enteredDTMF] appendString:aString];
				[self setDisplayedName:[self enteredDTMF]];
			}
			
			[[self call] sendDTMFDigits:aString];
		}
	}
}

@end
