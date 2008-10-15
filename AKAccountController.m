//
//  AKAccountController.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 30.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKAccountController.h"
#import "AKCallController.h"
#import "AKKeychain.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"


@implementation AKAccountController

@synthesize account;
@synthesize callControllers;

- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount
{
	self = [super initWithWindowNibName:@"Account"];
	if (self == nil)
		return nil;
	
	[self setAccount:anAccount];
	callControllers = [[NSMutableArray alloc] init];
	
	[account setDelegate:self];
	
	return self;
}

- (id)initWithFullName:(NSString *)aFullName
			sipAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername
{
	AKTelephoneAccount *anAccount = [AKTelephoneAccount telephoneAccountWithFullName:aFullName
																		  sipAddress:aSIPAddress
																		   registrar:aRegistrar
																			   realm:aRealm
																			username:aUsername];
	return [self initWithTelephoneAccount:anAccount];
}

- (void)dealloc
{
	if ([[[self account] delegate] isEqual:self])
		[[self account] setDelegate:nil];
	
	[[AKTelephone sharedTelephone] removeAccount:[self account]];
	[account release];
	[callControllers release];
	
	[activeAccountView release];
	[unregisteredAccountView release];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ controller", [self account]];
}

- (void)awakeFromNib
{
	[self setShouldCascadeWindows:NO];
	[[self window] setFrameAutosaveName:[[self account] sipAddress]];
	[activeAccountView retain];
	[unregisteredAccountView retain];
}

// Ask model to make call, create call controller, attach the call to the call contoller
- (IBAction)makeCall:(id)sender
{
	if ([[callDestination stringValue] isEqualToString:@""])
		return;
	
	if ([[[self account] calls] count] == AKTelephoneCallsMax) {
		NSLog(@"Won't call, maximum number of calls is reached!");
		return;
	}
	
	NSString *uri = [NSString stringWithFormat:@"sip:%@", [callDestination stringValue]];
	// Make actual call
	AKTelephoneCall *aCall = [[self account] makeCallTo:uri];
	if (aCall != nil) {
		AKCallController *aCallController = [[AKCallController alloc] initWithTelephoneCall:aCall
																		  accountController:self];
		[[self callControllers] addObject:aCallController];
		[[aCallController window] setContentView:[aCallController activeCallView]];
		[[aCallController window] setTitle:[[aCallController call] remoteInfo]];
		[aCallController setStatus:@"Calling..."];
		[aCallController showWindow:nil];
		
		[aCallController release];
	}
}

// When the call is received, create call controller, add to array, show call window
- (BOOL)telephoneAccount:(AKTelephoneAccount *)sender shouldReceiveCall:(AKTelephoneCall *)aCall
{
	AKCallController *aCallController = [[AKCallController alloc] initWithTelephoneCall:aCall
																	  accountController:self];
	[[self callControllers] addObject:aCallController];
	[[aCallController window] setTitle:[[aCallController call] remoteInfo]];
	[aCallController setStatus:@"Incoming"];
	[[aCallController window] setContentView:[aCallController incomingCallView]];
	[aCallController showWindow:nil];
	
	[aCallController release];
	
	return YES;
}

- (void)windowDidLoad
{
	if ([[AKTelephone sharedTelephone] readyState] == AKTelephoneStarted) {
		NSString *password = [AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@", [[self account] registrar]]
													accountName:[[self account] username]];
		
		// Add account to Telephone
		[[AKTelephone sharedTelephone] addAccount:[self account] withPassword:password];
	}
}

// When account registration changes, make appropriate modifications in UI
- (void)telephoneAccountRegistrationDidChange:(NSNotification *)notification
{
	if ([[self account] isRegistered]) {
		[[self window] setContentView:activeAccountView];
		if ([callDestination acceptsFirstResponder])
			[[self window] makeFirstResponder:callDestination];
	} else {
		[[self window] setContentView:unregisteredAccountView];
	}
}

// Remove call controller from array of controllers before the window is closed
- (void)telephoneCallWindowWillClose:(NSNotification *)notification
{
	AKCallController *aCallController = [notification object];
	NSString *description = [aCallController description];
	[[self callControllers] removeObject:aCallController];
	NSLog(@"%@ window removed", description);
}

@end
