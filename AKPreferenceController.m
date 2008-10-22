//
//  AKPreferenceController.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKKeychain.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "NSString+UUID.h"


NSString *AKAccounts = @"Accounts";
NSString *AKAccountSortOrder = @"AccountSortOrder";
NSString *AKSTUNServerHost = @"STUNServerHost";
NSString *AKSTUNServerPort = @"STUNServerPort";
NSString *AKSTUNDomain = @"STUNDomain";
NSString *AKLogFileName = @"LogFileName";
NSString *AKVoiceActivityDetection = @"VoiceActivityDetection";
NSString *AKTransportPort = @"TransportPort";

NSString *AKFullName = @"FullName";
NSString *AKSIPAddress = @"SIPAddress";
NSString *AKRegistrar = @"Registrar";
NSString *AKRealm = @"Realm";
NSString *AKUsername = @"Username";
NSString *AKPassword = @"Password";
NSString *AKAccountIndex = @"AccountIndex";
NSString *AKAccountKey = @"AccountKey";
NSString *AKAccountEnabled = @"AccountEnabled";

NSString *AKPreferenceControllerDidAddAccountNotification = @"AKPreferenceControllerDidAddAccount";
NSString *AKPreferenceControllerDidRemoveAccountNotification = @"AKPreferenceControllerDidRemoveAccount";
NSString *AKPreferenceControllerDidChangeAccountEnabledNotification = @"AKPreferenceControllerDidChangeAccountEnabled";

@implementation AKPreferenceController

@dynamic delegate;

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
	NSView *view;
	NSString *title;
	
	if ([sender isEqual:generalToolbarItem]) {
		view = generalView;
		title = @"General";
	} else if ([sender isEqual:accountsToolbarItem]) {
		view = accountsView;
		title = @"Accounts";
	} else { 
		view = nil;
		title = @"Preferences";
	}
	
	[self displayView:view withTitle:title];
}

- (IBAction)showAddAccountSheet:(id)sender
{
	if (addAccountSheet == nil)
		[NSBundle loadNibNamed:@"AddAccount" owner:self];
	
	[setupFullName setStringValue:@""];
	[setupSIPAddress setStringValue:@""];
	[setupRegistrar setStringValue:@""];
	[setupUsername setStringValue:@""];
	[setupPassword setStringValue:@""];
	[addAccountSheet makeFirstResponder:setupFullName];
	
	[NSApp beginSheet:addAccountSheet
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
	
	if ([[accountDict objectForKey:AKAccountEnabled] boolValue])
		[accountEnabledCheckBox setState:NSOnState];
	else
		[accountEnabledCheckBox setState:NSOffState];
	
	[fullName setStringValue:[accountDict objectForKey:AKFullName]];
	[sipAddress setStringValue:[accountDict objectForKey:AKSIPAddress]];
	[registrar setStringValue:[accountDict objectForKey:AKRegistrar]];
	[username setStringValue:[accountDict objectForKey:AKUsername]];
	//	[password setStringValue:[self keychainPasswordForAccountAtIndex:index]];
	[password setStringValue:[AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@", [accountDict objectForKey:AKRegistrar]]
													accountName:[accountDict objectForKey:AKUsername]]];
}

- (IBAction)changeAccountEnabled:(id)sender
{
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];

	NSInteger index = [accountsTable selectedRow];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *accountKey = [[defaults arrayForKey:AKAccountSortOrder] objectAtIndex:index];
	
	[userInfo setObject:accountKey forKey:AKAccountKey];
	
	BOOL isChecked = ([accountEnabledCheckBox state] == NSOnState) ? YES : NO;
	[userInfo setObject:[NSNumber numberWithBool:isChecked] forKey:AKAccountEnabled];
	
	// Save to defaults
	NSMutableDictionary *savedAccounts = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:AKAccounts]];
	NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:[savedAccounts objectForKey:accountKey]];
	[accountDict setObject:[NSNumber numberWithBool:isChecked] forKey:AKAccountEnabled];
	[savedAccounts setObject:accountDict forKey:accountKey];
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidChangeAccountEnabledNotification
														object:self
													  userInfo:userInfo];
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
			nil];
}

@end

