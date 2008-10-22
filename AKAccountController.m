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


const CGFloat AKAccountRegistrationButtonOfflineWidth = 58.0;
const CGFloat AKAccountRegistrationButtonAvailableWidth = 69.0;
const CGFloat AKAccountRegistrationButtonConnectingWidth = 90.0;

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
- (void)telephoneAccount:(AKTelephoneAccount *)sender didReceiveCall:(AKTelephoneCall *)aCall
{
	AKCallController *aCallController = [[AKCallController alloc] initWithTelephoneCall:aCall
																	  accountController:self];
	[[self callControllers] addObject:aCallController];
	[[aCallController window] setTitle:[[aCallController call] remoteInfo]];
	[aCallController setStatus:@"Incoming"];
	[[aCallController window] setContentView:[aCallController incomingCallView]];
	[aCallController showWindow:nil];
	
	[aCallController release];
}

- (IBAction)changeAccountRegistration:(id)sender
{	
	if (![[self account] isRegistered] && [[sender selectedItem] tag] == AKTelephoneAccountUnregisterTag)
		return;
	
	if ([[sender selectedItem] tag] == AKTelephoneAccountRegisterTag) {
		NSSize buttonSize = [accountRegistrationPopUp frame].size;
		buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:@"Connecting..."];
	}
	
	[[self account] setRegistered:[[sender selectedItem] tag]];
}

// Remove old account from Telephone, change username for the account, add to Telephone with new password and update Keychain.
- (IBAction)changeUsernameAndPassword:(id)sender
{
	if (![[newUsername stringValue] isEqualToString:@""]) {
		[[AKTelephone sharedTelephone] removeAccount:[self account]];
		[[self account] setUsername:[newUsername stringValue]];
		[[AKTelephone sharedTelephone] addAccount:[self account] withPassword:[newPassword stringValue]];
		
		// Set registration button to Connecting... after adding account to Telephone
		NSSize buttonSize = [accountRegistrationPopUp frame].size;
		buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:@"Connecting..."];
		
		if ([mustSave state] == NSOnState)
			[AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [[self account] registrar]]
								   accountName:[newUsername stringValue]
									  password:[newPassword stringValue]];
	}
	
	[newPassword setStringValue:@""];
	[self closeSheet:sender];
}

- (IBAction)closeSheet:(id)sender
{
	[NSApp endSheet:[sender window]];
	[[sender window] orderOut:self];
}

- (void)windowDidLoad
{
	if ([[AKTelephone sharedTelephone] readyState] == AKTelephoneStarted) {
		NSString *password = [AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@", [[self account] registrar]]
													accountName:[[self account] username]];
		
		// Add account to Telephone
		[[AKTelephone sharedTelephone] addAccount:[self account] withPassword:password];
	}
	
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	buttonSize.width = AKAccountRegistrationButtonConnectingWidth;
	[accountRegistrationPopUp setFrameSize:buttonSize];
	[accountRegistrationPopUp setTitle:@"Connecting..."];
}

// When account registration changes, make appropriate modifications in UI
- (void)telephoneAccountRegistrationDidChange:(NSNotification *)notification
{
	NSSize buttonSize = [accountRegistrationPopUp frame].size;
	
	if ([[self account] isRegistered]) {
		buttonSize.width = AKAccountRegistrationButtonAvailableWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:@"Available"];
		[registerAccountMenuItem setState:NSOnState];
		[unregisterAccountMenuItem setState:NSOffState];
		[[self window] setContentView:registeredAccountView];
		
		// Making callDestination a first responder should also be here.
		// But if it is, the window is not released and moved away from screen.
		// I'm skipping it until figuring out why it is so.
		
	} else {
		buttonSize.width = AKAccountRegistrationButtonOfflineWidth;
		[accountRegistrationPopUp setFrameSize:buttonSize];
		[accountRegistrationPopUp setTitle:@"Offline"];
		[registerAccountMenuItem setState:NSOffState];
		[unregisterAccountMenuItem setState:NSOnState];
		[[self window] setContentView:unregisteredAccountView];
		
		// Handle authentication failure
		if ([[[self account] registrationStatus] intValue] == PJSIP_EFAILEDCREDENTIAL) {
			if (authenticationFailureSheet == nil)
				[NSBundle loadNibNamed:@"AuthFailed" owner:self];
			
			[updateCredentialsInformativeText setStringValue:
			 [NSString stringWithFormat:@"Telehone was unable to login to %@.\nChange user name or password and try again.",
			  [[self account] registrar]]];
			[newUsername setStringValue:[[self account] username]];
			[newPassword setStringValue:@""];
			
			[NSApp beginSheet:authenticationFailureSheet
			   modalForWindow:[self window]
				modalDelegate:nil
			   didEndSelector:NULL
				  contextInfo:NULL];
		}
		
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
