//
//  AKCallController.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKCallController.h"
#import "AKTelephoneCall.h"
#import "NSNumber+PJSUA.h"


NSString *AKTelephoneCallWindowWillCloseNotification = @"AKTelephoneCallWindowWillClose";

@implementation AKCallController

@synthesize call;
@dynamic accountController;
@dynamic status;

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

- (NSString *)status
{
	return [statusField stringValue];
}

- (void)setStatus:(NSString *)status
{
	[statusField setStringValue:status];
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

- (IBAction)hangUp:(id)sender
{
	[[self call] hangUp];
	[hangUpButton setEnabled:NO];
}


#pragma mark -

- (void)windowDidLoad
{
//	[remoteContact setStringValue:[call remoteContact]];
}

// If call window is to be closed, hang up the call and send notification
- (void)windowWillClose:(NSNotification *)notification
{
	if (![[[self call] identifier] isEqualToNumber:[NSNumber numberWithPJSUACallIdentifier:PJSUA_INVALID_ID]] && [[self call] isActive])
		[[self call] hangUp];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKTelephoneCallWindowWillCloseNotification
														object:self];
}

- (void)telephoneCallCalling:(NSNotification *)notification
{
	[statusField setStringValue:@"Calling..."];
	[[self window] setDocumentEdited:YES];
}

- (void)telephoneCallEarly:(NSNotification *)notification
{
	[statusField setStringValue:@"Calling..."];
	[[self window] setDocumentEdited:YES];
}

- (void)telephoneCallDidConfirm:(NSNotification *)notification
{
	[statusField setStringValue:@"Connected"];
}

- (void)telephoneCallDidDisconnect:(NSNotification *)notification
{
	if ([[[self call] lastStatus] isEqualToNumber:[NSNumber numberWithInt:600]])
		[statusField setStringValue:@"Busy"];
	else
		[statusField setStringValue:@"Disconnected"];
	
	[[self window] setDocumentEdited:NO];
	[hangUpButton setEnabled:NO];
}

@end
