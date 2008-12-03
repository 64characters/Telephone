//
//  AKPreferenceController.m
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

#import "AKKeychain.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AppController.h"
#import "NSStringAdditions.h"


@interface AKPreferenceController()

- (BOOL)checkForSTUNServerChanges:(id)sender;

@end

NSString * const AKAccounts = @"Accounts";
NSString * const AKAccountSortOrder = @"AccountSortOrder";
NSString * const AKSTUNServerHost = @"STUNServerHost";
NSString * const AKSTUNServerPort = @"STUNServerPort";
NSString * const AKSTUNDomain = @"STUNDomain";
NSString * const AKLogFileName = @"LogFileName";
NSString * const AKLogLevel = @"LogLevel";
NSString * const AKConsoleLogLevel = @"ConsoleLogLevel";
NSString * const AKVoiceActivityDetection = @"VoiceActivityDetection";
NSString * const AKTransportPort = @"TransportPort";
NSString * const AKSoundInput = @"SoundInput";
NSString * const AKSoundOutput = @"SoundOutput";
NSString * const AKFormatsTelephoneNumbers = @"FormatsTelephoneNumbers";
NSString * const AKTelephoneNumberFormatterSplitsLastFourDigits = @"TelephoneNumberFormatterSplitsLastFourDigits";

NSString * const AKFullName = @"FullName";
NSString * const AKSIPAddress = @"SIPAddress";
NSString * const AKRegistrar = @"Registrar";
NSString * const AKRealm = @"Realm";
NSString * const AKUsername = @"Username";
NSString * const AKPassword = @"Password";
NSString * const AKAccountIndex = @"AccountIndex";
NSString * const AKAccountKey = @"AccountKey";
NSString * const AKAccountEnabled = @"AccountEnabled";

NSString * const AKPreferenceControllerDidAddAccountNotification = @"AKPreferenceControllerDidAddAccount";
NSString * const AKPreferenceControllerDidRemoveAccountNotification = @"AKPreferenceControllerDidRemoveAccount";
NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification = @"AKPreferenceControllerDidChangeAccountEnabled";
NSString * const AKPreferenceControllerDidChangeSTUNServerNotification = @"AKPreferenceControllerDidChangeSTUNServer";

@implementation AKPreferenceController

@dynamic delegate;
@synthesize addAccountWindow;
@synthesize addAccountWindowDefaultButton;
@synthesize addAccountWindowOtherButton;

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
		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidAddAccount:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidAddAccount:)
									   name:AKPreferenceControllerDidAddAccountNotification
									 object:self];

		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidRemoveAccount:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidRemoveAccount:)
									   name:AKPreferenceControllerDidRemoveAccountNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidChangeAccountEnabled:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidChangeAccountEnabled:)
									   name:AKPreferenceControllerDidChangeAccountEnabledNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidChangeSTUNServer:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidChangeSTUNServer:)
									   name:AKPreferenceControllerDidChangeSTUNServerNotification
									 object:self];
	}
	
	delegate = aDelegate;
}

- (id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	
	return self;
}

- (void)dealloc
{
	[self setDelegate:nil];
	
	[super dealloc];
}

- (void)windowDidLoad
{
	[toolbar setSelectedItemIdentifier:[generalToolbarItem itemIdentifier]];
	[self displayView:generalView withTitle:@"General"];
	
	[self updateAudioDevices];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[STUNServerHost setStringValue:[defaults stringForKey:AKSTUNServerHost]];
	if ([[defaults objectForKey:AKSTUNServerPort] integerValue] > 0)
		[STUNServerPort setIntegerValue:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
		
	NSInteger row = [accountsTable selectedRow];
	if (row == -1)
		return;
	
	[self populateFieldsForAccountAtIndex:row];
}

- (void)displayView:(NSView *)aView withTitle:(NSString *)aTitle
{
	NSWindow *preferencesWindow = [self window];
	
	// Compute the new window frame
	NSSize currentSize = [[preferencesWindow contentView] frame].size;
	NSSize newSize = [aView frame].size;
	float deltaWidth = newSize.width - currentSize.width;
	float deltaHeight = newSize.height - currentSize.height;
	
	NSRect windowFrame = [preferencesWindow frame];
	windowFrame.size.height += deltaHeight;
	windowFrame.origin.y -= deltaHeight;
	windowFrame.size.width += deltaWidth;
	
	// Show temporary view for smoother resize animation
	NSView *tempView = [[NSView alloc] initWithFrame:[[preferencesWindow contentView] frame]];
	[preferencesWindow setContentView:tempView];
	[tempView release];
	
	[preferencesWindow setFrame:windowFrame display:YES animate:YES];
	[preferencesWindow setTitle:aTitle];
	[preferencesWindow setContentView:aView];
}

- (IBAction)changeView:(id)sender
{
	// If the user switches from General to some other view, check for STUN server changes.
	if ([[[self window] contentView] isEqual:networkView] && [sender tag] != AKNetworkPreferencesTag) {
		BOOL STUNServerChanged = [self checkForSTUNServerChanges:sender];
		if (STUNServerChanged)
			return;
	}
	
	NSView *view;
	NSString *title;
	
	switch ([sender tag]) {
		case AKGeneralPreferencesTag:
			view = generalView;
			title = @"General";
			break;
		case AKAccountsPreferencesTag:
			view = accountsView;
			title = @"Accounts";
			break;
		case AKSoundPreferencesTag:
			view = soundView;
			title = @"Sound";
			break;
		case AKNetworkPreferencesTag:
			view = networkView;
			title = @"Network";
			break;
		default:
			view = nil;
			title = @"Telephone Preferences";
			break;
	}
	
	[self displayView:view withTitle:title];
}

- (IBAction)showAddAccountSheet:(id)sender
{
	if (addAccountWindow == nil)
		[NSBundle loadNibNamed:@"AddAccount" owner:self];
	
	[setupFullName setStringValue:@""];
	[setupSIPAddress setStringValue:@""];
	[setupRegistrar setStringValue:@""];
	[setupUsername setStringValue:@""];
	[setupPassword setStringValue:@""];
	[addAccountWindow makeFirstResponder:setupFullName];
	
	[NSApp beginSheet:addAccountWindow
	   modalForWindow:[accountsView window]
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)closeSheet:(id)sender
{
	[NSApp endSheet:[sender window]];
	[[sender window] orderOut:sender];
}

- (IBAction)addAccount:(id)sender
{
	if ([[setupFullName stringValue] isEqual:@""] ||
		[[setupSIPAddress stringValue] isEqual:@""] ||
		[[setupRegistrar stringValue] isEqual:@""] ||
		[[setupUsername stringValue] isEqual:@""])
	{
		return;
	}
	
	NSMutableDictionary *accountDict = [NSMutableDictionary dictionary];
	[accountDict setObject:[NSNumber numberWithBool:YES] forKey:AKAccountEnabled];
	[accountDict setObject:[setupFullName stringValue] forKey:AKFullName];
	[accountDict setObject:[setupSIPAddress stringValue] forKey:AKSIPAddress];
	[accountDict setObject:[setupRegistrar stringValue] forKey:AKRegistrar];
	[accountDict setObject:@"*" forKey:AKRealm];
	[accountDict setObject:[setupUsername stringValue] forKey:AKUsername];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *uuid = [NSString uuidString];
	NSMutableDictionary *savedAccounts = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:AKAccounts]];
	NSMutableArray *savedAccountSortOrder = [NSMutableArray arrayWithArray:[defaults arrayForKey:AKAccountSortOrder]];
	[savedAccounts setObject:accountDict forKey:uuid];
	[savedAccountSortOrder addObject:uuid];
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults setObject:savedAccountSortOrder forKey:AKAccountSortOrder];
	[defaults synchronize];
	
	// Inform accounts table about update
	[accountsTable reloadData];
	
	BOOL success;
	success = [AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [setupRegistrar stringValue]]
									 accountName:[setupUsername stringValue]
										password:[setupPassword stringValue]];
	
	if (success) {
		// Complete account dictionary with password info
		[accountDict setObject:[setupPassword stringValue] forKey:AKPassword];
		
		// Post notification with account just added
		[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidAddAccountNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:accountDict forKey:uuid]];
	}
	
	[self closeSheet:sender];
	
	// Set the selection to the new account
	NSUInteger index = [[defaults arrayForKey:AKAccountSortOrder] count] - 1;
	if (index != 0) {
		[accountsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
				   byExtendingSelection:NO];
	}
}

- (IBAction)showRemoveAccountSheet:(id)sender
{
	NSInteger index = [accountsTable selectedRow];
	if (index == -1) {
		NSBeep();
		return;
	}
	
	NSTableColumn *theColumn = [[[NSTableColumn alloc] initWithIdentifier:@"SIPAddress"] autorelease];
	NSString *selectedAccount = [[accountsTable dataSource] tableView:accountsTable
											objectValueForTableColumn:theColumn row:index];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:[NSString stringWithFormat:@"Delete “%@”?", selectedAccount]];
	[alert setInformativeText:[NSString stringWithFormat:@"This will delete your currently set up account “%@”.", selectedAccount]];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[accountsTable window]
					  modalDelegate:self
					 didEndSelector:@selector(removeAccountAlertDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)removeAccountAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
		[self removeAccountAtIndex:[accountsTable selectedRow]];
}

- (void)removeAccountAtIndex:(NSInteger)index
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *savedAccounts = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:AKAccounts]];
	NSMutableArray *savedAccountSortOrder = [NSMutableArray arrayWithArray:[defaults arrayForKey:AKAccountSortOrder]];
	NSString *accountKey = [savedAccountSortOrder objectAtIndex:index];
	[savedAccounts removeObjectForKey:accountKey];
	[savedAccountSortOrder removeObject:accountKey];
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults setObject:savedAccountSortOrder forKey:AKAccountSortOrder];
	[defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidRemoveAccountNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:accountKey
																						   forKey:AKAccountKey]];
	[accountsTable reloadData];
}

- (void)populateFieldsForAccountAtIndex:(NSUInteger)index
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *accountKey = [[defaults arrayForKey:AKAccountSortOrder] objectAtIndex:index];
	NSDictionary *accountDict = [[defaults dictionaryForKey:AKAccounts] objectForKey:accountKey];
	
	[accountEnabledCheckBox setEnabled:YES];
	
	if ([[accountDict objectForKey:AKAccountEnabled] boolValue]) {
		[accountEnabledCheckBox setState:NSOnState];
		[fullName setEnabled:NO];
		[SIPAddress setEnabled:NO];
		[registrar setEnabled:NO];
		[username setEnabled:NO];
		[password setEnabled:NO];
	} else {
		[accountEnabledCheckBox setState:NSOffState];
		[fullName setEnabled:YES];
		[SIPAddress setEnabled:YES];
		[registrar setEnabled:YES];
		[username setEnabled:YES];
		[password setEnabled:YES];
	}
	
	[fullName setStringValue:[accountDict objectForKey:AKFullName]];
	[SIPAddress setStringValue:[accountDict objectForKey:AKSIPAddress]];
	[registrar setStringValue:[accountDict objectForKey:AKRegistrar]];
	[username setStringValue:[accountDict objectForKey:AKUsername]];
	//	[password setStringValue:[self keychainPasswordForAccountAtIndex:index]];
	[password setStringValue:[AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@", [accountDict objectForKey:AKRegistrar]]
													accountName:[accountDict objectForKey:AKUsername]]];
}

- (IBAction)changeAccountEnabled:(id)sender
{
	if ([accountsTable selectedRow] == -1)
		return;	
	
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];

	NSInteger index = [accountsTable selectedRow];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *accountKey = [[defaults arrayForKey:AKAccountSortOrder] objectAtIndex:index];
	
	[userInfo setObject:accountKey forKey:AKAccountKey];
	
	BOOL isChecked = ([accountEnabledCheckBox state] == NSOnState) ? YES : NO;
	[userInfo setObject:[NSNumber numberWithBool:isChecked] forKey:AKAccountEnabled];
	
	NSMutableDictionary *savedAccounts = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:AKAccounts]];
	NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:[savedAccounts objectForKey:accountKey]];
	
	[accountDict setObject:[NSNumber numberWithBool:isChecked] forKey:AKAccountEnabled];
	
	if (isChecked) {
		// User enabled the account.
		// Account fields could be edited, save them.
		[accountDict setObject:[fullName stringValue] forKey:AKFullName];
		[accountDict setObject:[SIPAddress stringValue] forKey:AKSIPAddress];
		[accountDict setObject:[registrar stringValue] forKey:AKRegistrar];
		[accountDict setObject:[username stringValue] forKey:AKUsername];
		[AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [registrar stringValue]]
							   accountName:[username stringValue]
								  password:[password stringValue]];
		
		// Disable account fields.
		[fullName setEnabled:NO];
		[SIPAddress setEnabled:NO];
		[registrar setEnabled:NO];
		[username setEnabled:NO];
		[password setEnabled:NO];
		
		// Mark accounts table as needing redisplay.
		[accountsTable reloadData];
		
	} else {
		// User disabled the account, enable account fields.
		[fullName setEnabled:YES];
		[SIPAddress setEnabled:YES];
		[registrar setEnabled:YES];
		[username setEnabled:YES];
		[password setEnabled:YES];
	}
	
	[savedAccounts setObject:accountDict forKey:accountKey];
	
	// Save to defaults
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidChangeAccountEnabledNotification
														object:self
													  userInfo:userInfo];
}

- (IBAction)changeSoundIO:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[soundInputPopUp titleOfSelectedItem] forKey:AKSoundInput];
	[defaults setObject:[soundOutputPopUp titleOfSelectedItem] forKey:AKSoundOutput];
	
	[[NSApp delegate] selectSoundIO];
}

- (void)updateAudioDevices
{
	// Populate sound IO pop-up buttons
	NSArray *audioDevices = [[NSApp delegate] audioDevices];
	NSMenu *soundInputMenu = [[NSMenu alloc] init];
	NSMenu *soundOutputMenu = [[NSMenu alloc] init];
	NSInteger i;
	for (i = 0; i < [audioDevices count]; ++i) {
		NSDictionary *deviceDict = [audioDevices objectAtIndex:i];
		
		NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
		[aMenuItem setTitle:[deviceDict objectForKey:AKAudioDeviceName]];
		[aMenuItem setTag:i];
		
		if ([[deviceDict objectForKey:AKAudioDeviceInputsCount] integerValue] > 0)
			[soundInputMenu addItem:[[aMenuItem copy] autorelease]];
		
		if ([[deviceDict objectForKey:AKAudioDeviceOutputsCount] integerValue] > 0)
			[soundOutputMenu addItem:[[aMenuItem copy] autorelease]];
		
		[aMenuItem release];
	}
	
	[soundInputPopUp setMenu:soundInputMenu];
	[soundOutputPopUp setMenu:soundOutputMenu];
	
	[soundInputMenu release];
	[soundOutputMenu release];
	
	// Select saved sound devices
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *lastSoundInput = [defaults stringForKey:AKSoundInput];
	if (lastSoundInput != nil && [soundInputPopUp itemWithTitle:lastSoundInput] != nil)
		[soundInputPopUp selectItemWithTitle:lastSoundInput];
	
	NSString *lastSoundOutput = [defaults stringForKey:AKSoundOutput];
	if (lastSoundOutput != nil && [soundOutputPopUp itemWithTitle:lastSoundOutput] != nil)
		[soundOutputPopUp selectItemWithTitle:lastSoundOutput];
}

// Check if STUN server settings were changed, show an alert sheet to save, cancel or don't save.
// Returns YES if changes were made to STUN server hostname or port; returns NO otherwise.
- (BOOL)checkForSTUNServerChanges:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *newSTUNServerHost = [STUNServerHost stringValue];
	NSNumber *newSTUNServerPort = [NSNumber numberWithInteger:[STUNServerPort integerValue]];
	
	if (![[defaults objectForKey:AKSTUNServerHost] isEqualToString:newSTUNServerHost] ||
		![[defaults objectForKey:AKSTUNServerPort] isEqualToNumber:newSTUNServerPort])
	{
		// Explicitly select General toolbar item.
		[toolbar setSelectedItemIdentifier:[generalToolbarItem itemIdentifier]];
		
		// Show alert to the user.
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Save"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Don't Save"];
		[alert setMessageText:@"Save changes to STUN server settings?"];
		[alert setInformativeText:@"New STUN server settings will be applied immediately, all accounts will be reconnected."];
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(STUNServerAlertDidEnd:returnCode:contextInfo:)
							contextInfo:sender];
		return YES;
	}
	
	return NO;
}

- (void)STUNServerAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id sender = (id)contextInfo;
	
	if (returnCode == NSAlertFirstButtonReturn) {
		[defaults setObject:[STUNServerHost stringValue] forKey:AKSTUNServerHost];
		[defaults setObject:[NSNumber numberWithInteger:[STUNServerPort integerValue]] forKey:AKSTUNServerPort];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidChangeSTUNServerNotification
															object:self];
	} else if (returnCode == NSAlertThirdButtonReturn) {
		[STUNServerHost setStringValue:[defaults objectForKey:AKSTUNServerHost]];
		[STUNServerPort setIntegerValue:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	}
	
	if ([sender isMemberOfClass:[NSToolbarItem class]]) {
		[toolbar setSelectedItemIdentifier:[sender itemIdentifier]];
		[self changeView:sender];
	} else if ([sender isMemberOfClass:[NSWindow class]])
		[sender close];
}


#pragma mark NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [[defaults objectForKey:AKAccountSortOrder] count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *accountKey = [[defaults objectForKey:AKAccountSortOrder] objectAtIndex:rowIndex];
	NSDictionary *accountDict = [[defaults objectForKey:AKAccounts] objectForKey:accountKey];
	
	return [accountDict objectForKey:[aTableColumn identifier]];
}


#pragma mark NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger row = [accountsTable selectedRow];
	if (row == -1)
		return;

	[self populateFieldsForAccountAtIndex:row];
}


#pragma mark NSToolbar delegate

// Supply selectable toolbar items
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar
{	
	return [NSArray arrayWithObjects:
			[generalToolbarItem itemIdentifier],
			[accountsToolbarItem itemIdentifier],
			[soundToolbarItem itemIdentifier],
			[networkToolbarItem itemIdentifier],
			nil];
}


#pragma mark NSWindow delegate

- (BOOL)windowShouldClose:(id)window
{
	BOOL STUNServerChanged = [self checkForSTUNServerChanges:window];
	if (STUNServerChanged)
		return NO;
	
	return YES;
}

@end
