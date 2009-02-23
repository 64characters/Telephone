//
//  AKPreferenceController.m
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

#import "AKKeychain.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AppController.h"
#import "NSStringAdditions.h"
#import "NSWindowAdditions.h"


NSString * const AKTelephoneAccountPboardType = @"AKTelephoneAccountPboardType";

@interface AKPreferenceController()

- (BOOL)checkForNetworkSettingsChanges:(id)sender;
- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

NSString * const AKAccounts = @"Accounts";
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
NSString * const AKRingtoneOutput = @"RingtoneOutput";
NSString * const AKRingingSound = @"RingingSound";
NSString * const AKFormatTelephoneNumbers = @"FormatTelephoneNumbers";
NSString * const AKTelephoneNumberFormatterSplitsLastFourDigits = @"TelephoneNumberFormatterSplitsLastFourDigits";
NSString * const AKOutboundProxyHost = @"OutboundProxyHost";
NSString * const AKOutboundProxyPort = @"OutboundProxyPort";
NSString * const AKUseICE = @"UseICE";
NSString * const AKUseDNSSRV = @"UseDNSSRV";
NSString * const AKSignificantPhoneNumberLength = @"SignificantPhoneNumberLength";

NSString * const AKFullName = @"FullName";
NSString * const AKSIPAddress = @"SIPAddress";
NSString * const AKRegistrar = @"Registrar";
NSString * const AKRealm = @"Realm";
NSString * const AKUsername = @"Username";
NSString * const AKPassword = @"Password";
NSString * const AKAccountIndex = @"AccountIndex";
NSString * const AKAccountEnabled = @"AccountEnabled";
NSString * const AKReregistrationTime = @"ReregistrationTime";
NSString * const AKSubstitutePlusCharacter = @"SubstitutePlusCharacter";
NSString * const AKPlusCharacterSubstitutionString = @"PlusCharacterSubstitutionString";
NSString * const AKUseProxy = @"UseProxy";
NSString * const AKProxyHost = @"ProxyHost";
NSString * const AKProxyPort = @"ProxyPort";

NSString * const AKSourceIndex = @"AKSourceIndex";
NSString * const AKDestinationIndex = @"AKDestinationIndex";

NSString * const AKPreferenceControllerDidAddAccountNotification = @"AKPreferenceControllerDidAddAccount";
NSString * const AKPreferenceControllerDidRemoveAccountNotification = @"AKPreferenceControllerDidRemoveAccount";
NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification = @"AKPreferenceControllerDidChangeAccountEnabled";
NSString * const AKPreferenceControllerDidSwapAccountsNotification = @"AKPreferenceControllerDidSwapAccounts";
NSString * const AKPreferenceControllerDidChangeNetworkSettingsNotification = @"AKPreferenceControllerDidChangeNetworkSettings";

@implementation AKPreferenceController

@dynamic delegate;

@synthesize toolbar;
@synthesize generalToolbarItem;
@synthesize accountsToolbarItem;
@synthesize soundToolbarItem;
@synthesize networkToolbarItem;
@synthesize generalView;
@synthesize accountsView;
@synthesize soundView;
@synthesize networkView;

@synthesize soundInputPopUp;
@synthesize soundOutputPopUp;
@synthesize ringtoneOutputPopUp;
@synthesize ringtonePopUp;

@synthesize transportPort;
@synthesize transportPortCell;
@synthesize STUNServerHost;
@synthesize STUNServerPort;
@synthesize useICECheckBox;
@synthesize outboundProxyHost;
@synthesize outboundProxyPort;

@synthesize accountsTable;
@synthesize accountEnabledCheckBox;
@synthesize fullName;
@synthesize SIPAddress;
@synthesize registrar;
@synthesize username;
@synthesize password;
@synthesize reregistrationTime;
@synthesize substitutePlusCharacterCheckBox;
@synthesize plusCharacterSubstitution;
@synthesize useProxyCheckBox;
@synthesize proxyHost;
@synthesize proxyPort;

@synthesize addAccountWindow;
@synthesize setupFullName;
@synthesize setupSIPAddress;
@synthesize setupRegistrar;
@synthesize setupUsername;
@synthesize setupPassword;
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
		
		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidSwapAccounts:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidSwapAccounts:)
									   name:AKPreferenceControllerDidSwapAccountsNotification
									 object:self];
		
		if ([aDelegate respondsToSelector:@selector(preferenceControllerDidChangeNetworkSettings:)])
			[notificationCenter addObserver:aDelegate
								   selector:@selector(preferenceControllerDidChangeNetworkSettings:)
									   name:AKPreferenceControllerDidChangeNetworkSettingsNotification
									 object:self];
	}
	
	delegate = aDelegate;
}

- (id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	// Subscribe on mouse-down event of the ringing sound selection.
	[notificationCenter addObserver:self
						   selector:@selector(popUpButtonWillPopUp:)
							   name:NSPopUpButtonWillPopUpNotification
							 object:[self ringtonePopUp]];
	
	// Subscribe to User Agent start events.
	[notificationCenter addObserver:self
						   selector:@selector(telephoneDidStartUserAgent:)
							   name:AKTelephoneDidStartUserAgentNotification
							 object:nil];
	
	return self;
}

- (void)dealloc
{
	[self setDelegate:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[toolbar release];
	[generalToolbarItem release];
	[accountsToolbarItem release];
	[soundToolbarItem release];
	[networkToolbarItem release];
	[generalView release];
	[accountsView release];
	[soundView release];
	[networkView release];
	
	[soundInputPopUp release];
	[soundOutputPopUp release];
	[ringtoneOutputPopUp release];
	[ringtonePopUp release];
	
	[transportPort release];
	[transportPortCell release];
	[STUNServerHost release];
	[STUNServerPort release];
	[useICECheckBox release];
	[outboundProxyHost release];
	[outboundProxyPort release];
	
	[accountsTable release];
	[accountEnabledCheckBox release];
	[fullName release];
	[SIPAddress release];
	[registrar release];
	[username release];
	[password release];
	[reregistrationTime release];
	[substitutePlusCharacterCheckBox release];
	[plusCharacterSubstitution release];
	[useProxyCheckBox release];
	[proxyHost release];
	[proxyPort release];
	
	[addAccountWindow release];
	[setupFullName release];
	[setupSIPAddress release];
	[setupRegistrar release];
	[setupUsername release];
	[setupPassword release];
	[addAccountWindowDefaultButton release];
	[addAccountWindowOtherButton release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	// Register a pasteboard type to rearrange accounts with drag and drop.
	[[self accountsTable] registerForDraggedTypes:[NSArray arrayWithObject:AKTelephoneAccountPboardType]];
}

- (void)windowDidLoad
{
	[self updateAvailableSounds];
	
	[[self toolbar] setSelectedItemIdentifier:[[self generalToolbarItem] itemIdentifier]];
	[[self window] resizeAndSwapToContentView:[self generalView]];
	[[self window] setTitle:NSLocalizedString(@"General", @"General preferences window title.")];
	
	[self updateAudioDevices];
	
	// Show transport port in the network preferences as a placeholder string.
	if ([[[NSApp delegate] telephone] started])
		[[self transportPortCell] setPlaceholderString:
		 [[NSNumber numberWithUnsignedInteger:[[[NSApp delegate] telephone] transportPort]] stringValue]];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([[defaults objectForKey:AKTransportPort] integerValue] > 0)
		[[self transportPort] setIntegerValue:[[defaults objectForKey:AKTransportPort] integerValue]];
	[[self STUNServerHost] setStringValue:[defaults stringForKey:AKSTUNServerHost]];
	if ([[defaults objectForKey:AKSTUNServerPort] integerValue] > 0)
		[[self STUNServerPort] setIntegerValue:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	[[self useICECheckBox] setState:[[defaults objectForKey:AKUseICE] integerValue]];
	[[self outboundProxyHost] setStringValue:[defaults stringForKey:AKOutboundProxyHost]];
	if ([[defaults objectForKey:AKOutboundProxyPort] integerValue] > 0)
		[[self outboundProxyPort] setIntegerValue:[[defaults objectForKey:AKOutboundProxyPort] integerValue]];
		
	NSInteger row = [[self accountsTable] selectedRow];
	if (row == -1)
		return;
	
	[self populateFieldsForAccountAtIndex:row];
}

- (IBAction)changeView:(id)sender
{
	// If the user switches from Network to some other view, check for network settings changes.
	if ([[[self window] contentView] isEqual:[self networkView]] && [sender tag] != AKNetworkPreferencesTag) {
		BOOL networkSettingsChanged = [self checkForNetworkSettingsChanges:sender];
		if (networkSettingsChanged)
			return;
	}
	
	NSView *view;
	NSString *title;
	NSView *firstResponderView;
	
	switch ([sender tag]) {
		case AKGeneralPreferencesTag:
			view = [self generalView];
			title = NSLocalizedString(@"General", @"General preferences window title.");
			firstResponderView = nil;
			break;
		case AKAccountsPreferencesTag:
			view = [self accountsView];
			title = NSLocalizedString(@"Accounts", @"Accounts preferences window title.");
			firstResponderView = [self accountsTable];
			break;
		case AKSoundPreferencesTag:
			view = [self soundView];
			title = NSLocalizedString(@"Sound", @"Sound preferences window title.");
			firstResponderView = nil;
			break;
		case AKNetworkPreferencesTag:
			view = [self networkView];
			title = NSLocalizedString(@"Network", @"Network preferences window title.");
			firstResponderView = nil;
			break;
		default:
			view = nil;
			title = NSLocalizedString(@"Telephone Preferences", @"Preferences default window title.");
			firstResponderView = nil;
			break;
	}
	
	[[self window] resizeAndSwapToContentView:view animate:YES];
	[[self window] setTitle:title];
	if ([firstResponderView acceptsFirstResponder])
		[[self window] makeFirstResponder:firstResponderView];
}

- (IBAction)showAddAccountSheet:(id)sender
{
	if ([self addAccountWindow] == nil)
		[NSBundle loadNibNamed:@"AddAccount" owner:self];
	
	[[self setupFullName] setStringValue:@""];
	[[self setupSIPAddress] setStringValue:@""];
	[[self setupRegistrar] setStringValue:@""];
	[[self setupUsername] setStringValue:@""];
	[[self setupPassword] setStringValue:@""];
	[[self addAccountWindow] makeFirstResponder:[self setupFullName]];
	
	[NSApp beginSheet:[self addAccountWindow]
	   modalForWindow:[[self accountsView] window]
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
	if ([[[self setupFullName] stringValue] isEqual:@""] ||
		[[[self setupSIPAddress] stringValue] isEqual:@""] ||
		[[[self setupRegistrar] stringValue] isEqual:@""] ||
		[[[self setupUsername] stringValue] isEqual:@""])
	{
		return;
	}
	
	NSMutableDictionary *accountDict = [NSMutableDictionary dictionary];
	[accountDict setObject:[NSNumber numberWithBool:YES] forKey:AKAccountEnabled];
	[accountDict setObject:[[self setupFullName] stringValue] forKey:AKFullName];
	[accountDict setObject:[[self setupSIPAddress] stringValue] forKey:AKSIPAddress];
	[accountDict setObject:[[self setupRegistrar] stringValue] forKey:AKRegistrar];
	[accountDict setObject:@"*" forKey:AKRealm];
	[accountDict setObject:[[self setupUsername] stringValue] forKey:AKUsername];
	[accountDict setObject:[NSNumber numberWithInteger:0] forKey:AKReregistrationTime];
	[accountDict setObject:[NSNumber numberWithBool:NO] forKey:AKSubstitutePlusCharacter];
	[accountDict setObject:@"00" forKey:AKPlusCharacterSubstitutionString];
	[accountDict setObject:[NSNumber numberWithBool:NO] forKey:AKUseProxy];
	[accountDict setObject:@"" forKey:AKProxyHost];
	[accountDict setObject:[NSNumber numberWithInteger:0] forKey:AKProxyPort];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:AKAccounts]];
	[savedAccounts addObject:accountDict];
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults synchronize];
	
	// Inform accounts table about update
	[[self accountsTable] reloadData];
	
	BOOL success;
	success = [AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [[self setupRegistrar] stringValue]]
									 accountName:[[self setupUsername] stringValue]
										password:[[self setupPassword] stringValue]];
	
	[self closeSheet:sender];
	
	if (success) {
		// Post notification with account just added
		[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidAddAccountNotification
															object:self
														  userInfo:accountDict];
	}
	
	// Set the selection to the new account
	NSUInteger index = [[defaults arrayForKey:AKAccounts] count] - 1;
	if (index != 0) {
		[[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
						  byExtendingSelection:NO];
	}
}

- (IBAction)showRemoveAccountSheet:(id)sender
{
	NSInteger index = [[self accountsTable] selectedRow];
	if (index == -1) {
		NSBeep();
		return;
	}
	
	NSTableColumn *theColumn = [[[NSTableColumn alloc] initWithIdentifier:@"SIPAddress"] autorelease];
	NSString *selectedAccount = [[[self accountsTable] dataSource] tableView:[self accountsTable]
												   objectValueForTableColumn:theColumn row:index];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete button.")];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
	[[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Delete \\U201C%@\\U201D?",
																	   @"Account removal confirmation."),
						   selectedAccount]];
	[alert setInformativeText:[NSString stringWithFormat:
							   NSLocalizedString(@"This will delete your currently set up account \\U201C%@\\U201D.",
												 @"Account removal confirmation informative text."),
							   selectedAccount]];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[[self accountsTable] window]
					  modalDelegate:self
					 didEndSelector:@selector(removeAccountAlertDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)removeAccountAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
		[self removeAccountAtIndex:[[self accountsTable] selectedRow]];
}

- (void)removeAccountAtIndex:(NSInteger)index
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:AKAccounts]];
	[savedAccounts removeObjectAtIndex:index];
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidRemoveAccountNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:index]
																						   forKey:AKAccountIndex]];
	[[self accountsTable] reloadData];
	
	// Select none, last or previous account.
	if ([savedAccounts count] == 0) {
		return;
	} else if (index >= ([savedAccounts count] - 1)) {
		[[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:([savedAccounts count] - 1)] byExtendingSelection:NO];
		[self populateFieldsForAccountAtIndex:([savedAccounts count] - 1)];
	} else {
		[[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
		[self populateFieldsForAccountAtIndex:index];
	}
}

- (void)populateFieldsForAccountAtIndex:(NSInteger)index
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedAccounts = [defaults arrayForKey:AKAccounts];
	
	if (index >= 0) {
		NSDictionary *accountDict = [savedAccounts objectAtIndex:index];
		
		[[self accountEnabledCheckBox] setEnabled:YES];
		
		// Conditionally enable fields and set checkboxes state.
		if ([[accountDict objectForKey:AKAccountEnabled] boolValue]) {
			[[self accountEnabledCheckBox] setState:NSOnState];
			[[self fullName] setEnabled:NO];
			[[self SIPAddress] setEnabled:NO];
			[[self registrar] setEnabled:NO];
			[[self username] setEnabled:NO];
			[[self password] setEnabled:NO];
			[[self reregistrationTime] setEnabled:NO];
			[[self substitutePlusCharacterCheckBox] setEnabled:NO];
			[[self substitutePlusCharacterCheckBox] setState:[[accountDict objectForKey:AKSubstitutePlusCharacter] integerValue]];
			[[self plusCharacterSubstitution] setEnabled:NO];
			[[self useProxyCheckBox] setState:[[accountDict objectForKey:AKUseProxy] integerValue]];
			[[self useProxyCheckBox] setEnabled:NO];
			[[self proxyHost] setEnabled:NO];
			[[self proxyPort] setEnabled:NO];
		} else {
			[[self accountEnabledCheckBox] setState:NSOffState];
			[[self fullName] setEnabled:YES];
			[[self SIPAddress] setEnabled:YES];
			[[self registrar] setEnabled:YES];
			[[self username] setEnabled:YES];
			[[self password] setEnabled:YES];
			
			[[self reregistrationTime] setEnabled:YES];
			[[self substitutePlusCharacterCheckBox] setEnabled:YES];
			[[self substitutePlusCharacterCheckBox] setState:[[accountDict objectForKey:AKSubstitutePlusCharacter] integerValue]];
			if ([[self substitutePlusCharacterCheckBox] state] == NSOnState)
				[[self plusCharacterSubstitution] setEnabled:YES];
			else
				[[self plusCharacterSubstitution] setEnabled:NO];
			
			[[self useProxyCheckBox] setEnabled:YES];
			[[self useProxyCheckBox] setState:[[accountDict objectForKey:AKUseProxy] integerValue]];
			if ([[self useProxyCheckBox] state] == NSOnState) {
				[[self proxyHost] setEnabled:YES];
				[[self proxyPort] setEnabled:YES];
			} else {
				[[self proxyHost] setEnabled:NO];
				[[self proxyPort] setEnabled:NO];
			}
		}
		
		// Populate fields.
		[[self fullName] setStringValue:[accountDict objectForKey:AKFullName]];
		[[self SIPAddress] setStringValue:[accountDict objectForKey:AKSIPAddress]];
		[[self registrar] setStringValue:[accountDict objectForKey:AKRegistrar]];
		[[self username] setStringValue:[accountDict objectForKey:AKUsername]];

		[[self password] setStringValue:[AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@",
																			[accountDict objectForKey:AKRegistrar]]
															   accountName:[accountDict objectForKey:AKUsername]]];
		
		if ([[accountDict objectForKey:AKReregistrationTime] integerValue] > 0)
			[[self reregistrationTime] setIntegerValue:[[accountDict objectForKey:AKReregistrationTime] integerValue]];
		else
			[[self reregistrationTime] setStringValue:@""];
		
		if ([accountDict objectForKey:AKPlusCharacterSubstitutionString] != nil)
			[[self plusCharacterSubstitution] setStringValue:[accountDict objectForKey:AKPlusCharacterSubstitutionString]];
		else
			[[self plusCharacterSubstitution] setStringValue:@"00"];
		
		if ([accountDict objectForKey:AKProxyHost] != nil)
			[[self proxyHost] setStringValue:[accountDict objectForKey:AKProxyHost]];
		else
			[[self proxyHost] setStringValue:@""];
		
		if ([[accountDict objectForKey:AKProxyPort] integerValue] > 0)
			[[self proxyPort] setIntegerValue:[[accountDict objectForKey:AKProxyPort] integerValue]];
		else
			[[self proxyPort] setStringValue:@""];
		
	} else {
		[[self accountEnabledCheckBox] setState:NSOffState];
		[[self fullName] setStringValue:@""];
		[[self SIPAddress] setStringValue:@""];
		[[self registrar] setStringValue:@""];
		[[self username] setStringValue:@""];
		[[self password] setStringValue:@""];
		[[self reregistrationTime] setStringValue:@""];
		[[self substitutePlusCharacterCheckBox] setState:NSOffState];
		[[self plusCharacterSubstitution] setStringValue:@"00"];
		[[self useProxyCheckBox] setState:NSOffState];
		[[self proxyHost] setStringValue:@""];
		[[self proxyPort] setStringValue:@""];
		
		[[self accountEnabledCheckBox] setEnabled:NO];
		[[self fullName] setEnabled:NO];
		[[self SIPAddress] setEnabled:NO];
		[[self registrar] setEnabled:NO];
		[[self username] setEnabled:NO];
		[[self password] setEnabled:NO];
		[[self reregistrationTime] setEnabled:NO];
		[[self substitutePlusCharacterCheckBox] setEnabled:NO];
		[[self plusCharacterSubstitution] setEnabled:NO];
		[[self useProxyCheckBox] setEnabled:NO];
		[[self proxyHost] setEnabled:NO];
		[[self proxyPort] setEnabled:NO];
	}
}

- (IBAction)changeAccountEnabled:(id)sender
{
	NSInteger index = [[self accountsTable] selectedRow];
	if (index == -1)
		return;	
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

	[userInfo setObject:[NSNumber numberWithInteger:index] forKey:AKAccountIndex];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:AKAccounts]];
	NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:[savedAccounts objectAtIndex:index]];
	
	BOOL isChecked = ([[self accountEnabledCheckBox] state] == NSOnState) ? YES : NO;
	[accountDict setObject:[NSNumber numberWithBool:isChecked] forKey:AKAccountEnabled];
	
	if (isChecked) {
		// User enabled the account.
		// Account fields could be edited, save them.
		[accountDict setObject:[[self fullName] stringValue] forKey:AKFullName];
		[accountDict setObject:[[self SIPAddress] stringValue] forKey:AKSIPAddress];
		[accountDict setObject:[[self registrar] stringValue] forKey:AKRegistrar];
		[accountDict setObject:[[self username] stringValue] forKey:AKUsername];
		[AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", [[self registrar] stringValue]]
							   accountName:[[self username] stringValue]
								  password:[[self password] stringValue]];
		
		[accountDict setObject:[NSNumber numberWithInteger:[[self reregistrationTime] integerValue]] forKey:AKReregistrationTime];
		
		if ([[self substitutePlusCharacterCheckBox] state] == NSOnState)		
			[accountDict setObject:[NSNumber numberWithBool:YES] forKey:AKSubstitutePlusCharacter];
		else
			[accountDict setObject:[NSNumber numberWithBool:NO] forKey:AKSubstitutePlusCharacter];
		[accountDict setObject:[[self plusCharacterSubstitution] stringValue] forKey:AKPlusCharacterSubstitutionString];
		
		if ([[self useProxyCheckBox] state] == NSOnState)
			[accountDict setObject:[NSNumber numberWithBool:YES] forKey:AKUseProxy];
		else
			[accountDict setObject:[NSNumber numberWithBool:NO] forKey:AKUseProxy];
		[accountDict setObject:[[self proxyHost] stringValue] forKey:AKProxyHost];
		[accountDict setObject:[NSNumber numberWithInteger:[[self proxyPort] integerValue]] forKey:AKProxyPort];
		
		// Disable account fields.
		[[self fullName] setEnabled:NO];
		[[self SIPAddress] setEnabled:NO];
		[[self registrar] setEnabled:NO];
		[[self username] setEnabled:NO];
		[[self password] setEnabled:NO];
		
		[[self reregistrationTime] setEnabled:NO];
		[[self substitutePlusCharacterCheckBox] setEnabled:NO];
		[[self plusCharacterSubstitution] setEnabled:NO];
		[[self useProxyCheckBox] setEnabled:NO];
		[[self proxyHost] setEnabled:NO];
		[[self proxyPort] setEnabled:NO];
		
		// Mark accounts table as needing redisplay.
		[[self accountsTable] reloadData];
		
	} else {
		// User disabled the account - enable account fields, set checkboxes state.
		[[self fullName] setEnabled:YES];
		[[self SIPAddress] setEnabled:YES];
		[[self registrar] setEnabled:YES];
		[[self username] setEnabled:YES];
		[[self password] setEnabled:YES];
		
		[[self reregistrationTime] setEnabled:YES];
		[[self substitutePlusCharacterCheckBox] setEnabled:YES];
		[[self substitutePlusCharacterCheckBox] setState:[[accountDict objectForKey:AKSubstitutePlusCharacter] integerValue]];
		if ([[self substitutePlusCharacterCheckBox] state] == NSOnState)
			[[self plusCharacterSubstitution] setEnabled:YES];
		
		[[self useProxyCheckBox] setEnabled:YES];
		[[self useProxyCheckBox] setState:[[accountDict objectForKey:AKUseProxy] integerValue]];
		if ([[self useProxyCheckBox] state] == NSOnState) {
			[[self proxyHost] setEnabled:YES];
			[[self proxyPort] setEnabled:YES];
		}
	}
	
	[savedAccounts replaceObjectAtIndex:index withObject:accountDict];
	
	// Save to defaults
	[defaults setObject:savedAccounts forKey:AKAccounts];
	[defaults synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidChangeAccountEnabledNotification
														object:self
													  userInfo:userInfo];
}

- (IBAction)changeSubstitutePlusCharacter:(id)sender
{
	[[self plusCharacterSubstitution] setEnabled:([[self substitutePlusCharacterCheckBox] state] == NSOnState)];
}

- (IBAction)changeUseProxy:(id)sender
{	
	BOOL isChecked = ([[self useProxyCheckBox] state] == NSOnState) ? YES : NO;
	[[self proxyHost] setEnabled:isChecked];
	[[self proxyPort] setEnabled:isChecked];
}

- (IBAction)changeSoundIO:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[[self soundInputPopUp] titleOfSelectedItem] forKey:AKSoundInput];
	[defaults setObject:[[self soundOutputPopUp] titleOfSelectedItem] forKey:AKSoundOutput];
	[defaults setObject:[[self ringtoneOutputPopUp] titleOfSelectedItem] forKey:AKRingtoneOutput];
	
	[[NSApp delegate] selectSoundIO];
}

- (void)updateAudioDevices
{
	// Populate sound IO pop-up buttons
	NSArray *audioDevices = [[NSApp delegate] audioDevices];
	NSMenu *soundInputMenu = [[NSMenu alloc] init];
	NSMenu *soundOutputMenu = [[NSMenu alloc] init];
	NSMenu *ringtoneOutputMenu = [[NSMenu alloc] init];
	NSInteger i;
	for (i = 0; i < [audioDevices count]; ++i) {
		NSDictionary *deviceDict = [audioDevices objectAtIndex:i];
		
		NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
		[aMenuItem setTitle:[deviceDict objectForKey:AKAudioDeviceName]];
		[aMenuItem setTag:i];
		
		if ([[deviceDict objectForKey:AKAudioDeviceInputsCount] integerValue] > 0)
			[soundInputMenu addItem:[[aMenuItem copy] autorelease]];
		
		if ([[deviceDict objectForKey:AKAudioDeviceOutputsCount] integerValue] > 0) {
			[soundOutputMenu addItem:[[aMenuItem copy] autorelease]];
			[ringtoneOutputMenu addItem:[[aMenuItem copy] autorelease]];
		}
		
		[aMenuItem release];
	}
	
	[[self soundInputPopUp] setMenu:soundInputMenu];
	[[self soundOutputPopUp] setMenu:soundOutputMenu];
	[[self ringtoneOutputPopUp] setMenu:ringtoneOutputMenu];
	
	[soundInputMenu release];
	[soundOutputMenu release];
	[ringtoneOutputMenu release];
	
	// Select saved sound devices
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *lastSoundInput = [defaults stringForKey:AKSoundInput];
	if (lastSoundInput != nil && [[self soundInputPopUp] itemWithTitle:lastSoundInput] != nil)
		[[self soundInputPopUp] selectItemWithTitle:lastSoundInput];
	
	NSString *lastSoundOutput = [defaults stringForKey:AKSoundOutput];
	if (lastSoundOutput != nil && [[self soundOutputPopUp] itemWithTitle:lastSoundOutput] != nil)
		[[self soundOutputPopUp] selectItemWithTitle:lastSoundOutput];
	
	NSString *lastRingtoneOutput = [defaults stringForKey:AKRingtoneOutput];
	if (lastRingtoneOutput != nil && [[self ringtoneOutputPopUp] itemWithTitle:lastRingtoneOutput] != nil)
		[[self ringtoneOutputPopUp] selectItemWithTitle:lastRingtoneOutput];
}

- (void)updateAvailableSounds
{
	NSMenu *soundsMenu = [[NSMenu alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSSet *allowedSoundFileExtensions = [NSSet setWithObjects:@"aiff", @"aif", @"aifc",
										 @"mp3", @"wav", @"sd2", @"au", @"snd", @"m4a", @"m4p", nil];
	
	// Get sounds from ~/Library/Sounds.
	NSArray *userSoundFiles = [fileManager contentsOfDirectoryAtPath:[@"~/Library/Sounds" stringByExpandingTildeInPath] error:NULL];
	for (NSString *aFile in userSoundFiles) {
		if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]])
			continue;
		NSString *aSound = [aFile stringByDeletingPathExtension];
		if ([soundsMenu itemWithTitle:aSound] == nil) {
			NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
			[aMenuItem setTitle:aSound];
			[soundsMenu addItem:aMenuItem];
			[aMenuItem release];
		}
	}
	
	BOOL isFirstItemInSection;
	
	// Get sounds from /Library/Sounds.
	NSArray *sharedLocalSoundFiles = [fileManager contentsOfDirectoryAtPath:@"/Library/Sounds" error:NULL];
	isFirstItemInSection = YES;
	for (NSString *aFile in sharedLocalSoundFiles) {
		if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]])
			continue;
		
		NSString *aSound = [aFile stringByDeletingPathExtension];
		if ([soundsMenu itemWithTitle:aSound] == nil) {
			if (isFirstItemInSection && [soundsMenu numberOfItems] > 0) {
				[soundsMenu addItem:[NSMenuItem separatorItem]];
				isFirstItemInSection = NO;
			}
			
			NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
			[aMenuItem setTitle:aSound];
			[soundsMenu addItem:aMenuItem];
			[aMenuItem release];
		}
	}
	
	// Get sounds from /Network/Library/Sounds.
	NSArray *networkSoundFiles = [fileManager contentsOfDirectoryAtPath:@"/Network/Library/Sounds" error:NULL];
	isFirstItemInSection = YES;
	for (NSString *aFile in networkSoundFiles) {
		if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]])
			continue;
		
		NSString *aSound = [aFile stringByDeletingPathExtension];
		if ([soundsMenu itemWithTitle:aSound] == nil) {
			if (isFirstItemInSection && [soundsMenu numberOfItems] > 0) {
				[soundsMenu addItem:[NSMenuItem separatorItem]];
				isFirstItemInSection = NO;
			}
			
			NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
			[aMenuItem setTitle:aSound];
			[soundsMenu addItem:aMenuItem];
			[aMenuItem release];
		}
	}
	
	// Get sounds from /System/Library/Sounds.
	NSArray *systemSoundFiles = [fileManager contentsOfDirectoryAtPath:@"/System/Library/Sounds" error:NULL];
	isFirstItemInSection = YES;
	for (NSString *aFile in systemSoundFiles) {
		if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]])
			continue;
		
		NSString *aSound = [aFile stringByDeletingPathExtension];
		if ([soundsMenu itemWithTitle:aSound] == nil) {
			if (isFirstItemInSection && [soundsMenu numberOfItems] > 0) {
				[soundsMenu addItem:[NSMenuItem separatorItem]];
				isFirstItemInSection = NO;
			}
			
			NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
			[aMenuItem setTitle:aSound];
			[soundsMenu addItem:aMenuItem];
			[aMenuItem release];
		}
	}
	
	[[self ringtonePopUp] setMenu:soundsMenu];
	NSString *savedSound = [[NSUserDefaults standardUserDefaults] stringForKey:AKRingingSound];
	if ([soundsMenu itemWithTitle:savedSound] != nil)
		[[self ringtonePopUp] selectItemWithTitle:savedSound];
	
	[soundsMenu release];
}

- (IBAction)changeRingtone:(id)sender
{
	// Stop currently playing ringtone.
	[[[NSApp delegate] ringtone] stop];
	
	NSString *soundName = [sender title];
	[[NSUserDefaults standardUserDefaults] setObject:soundName forKey:AKRingingSound];
	[[NSApp delegate] setRingtone:[NSSound soundNamed:soundName]];
	
	// Play selected ringtone once.
	[[[NSApp delegate] ringtone] play];
}

// Check if network settings were changed, show an alert sheet to save, cancel or don't save.
// Returns YES if changes were made to the network settings; returns NO otherwise.
- (BOOL)checkForNetworkSettingsChanges:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber *newTransportPort = [NSNumber numberWithInteger:[[self transportPort] integerValue]];
	NSString *newSTUNServerHost = [[self STUNServerHost] stringValue];
	NSNumber *newSTUNServerPort = [NSNumber numberWithInteger:[[self STUNServerPort] integerValue]];
	BOOL newUseICE = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
	NSString *newOutboundProxyHost = [[self outboundProxyHost] stringValue];
	NSNumber *newOutboundProxyPort = [NSNumber numberWithInteger:[[self outboundProxyPort] integerValue]];
	
	if (![[defaults objectForKey:AKTransportPort] isEqualToNumber:newTransportPort] ||
		![[defaults objectForKey:AKSTUNServerHost] isEqualToString:newSTUNServerHost] ||
		![[defaults objectForKey:AKSTUNServerPort] isEqualToNumber:newSTUNServerPort] ||
		[defaults boolForKey:AKUseICE] != newUseICE ||
		![[defaults objectForKey:AKOutboundProxyHost] isEqualToString:newOutboundProxyHost] ||
		![[defaults objectForKey:AKOutboundProxyPort] isEqualToNumber:newOutboundProxyPort])
	{
		// Explicitly select Network toolbar item.
		[[self toolbar] setSelectedItemIdentifier:[[self networkToolbarItem] itemIdentifier]];
		
		// Show alert to the user.
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:NSLocalizedString(@"Save", @"Save button.")];
		[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
		[alert addButtonWithTitle:NSLocalizedString(@"Don't Save", @"Don't save button.")];
		[[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
		[alert setMessageText:NSLocalizedString(@"Save changes to the network settings?", @"Network settings change confirmation.")];
		[alert setInformativeText:NSLocalizedString(@"New network settings will be applied immediately, all accounts will be reconnected.",
													@"Network settings change confirmation informative text.")];
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(networkSettingsChangeAlertDidEnd:returnCode:contextInfo:)
							contextInfo:sender];
		return YES;
	}
	
	return NO;
}

- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// Close the sheet.
	[[alert window] orderOut:nil];
	
	if (returnCode == NSAlertSecondButtonReturn)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id sender = (id)contextInfo;
	
	if (returnCode == NSAlertFirstButtonReturn) {
		[[self transportPortCell] setPlaceholderString:[[self transportPort] stringValue]];
		[defaults setObject:[NSNumber numberWithInteger:[[self transportPort] integerValue]] forKey:AKTransportPort];
		[defaults setObject:[[self STUNServerHost] stringValue] forKey:AKSTUNServerHost];
		[defaults setObject:[NSNumber numberWithInteger:[[self STUNServerPort] integerValue]] forKey:AKSTUNServerPort];
		BOOL useICEFlag = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
		[defaults setBool:useICEFlag forKey:AKUseICE];
		[defaults setObject:[[self outboundProxyHost] stringValue] forKey:AKOutboundProxyHost];
		[defaults setObject:[NSNumber numberWithInteger:[[self outboundProxyPort] integerValue]] forKey:AKOutboundProxyPort];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidChangeNetworkSettingsNotification
															object:self];
	} else if (returnCode == NSAlertThirdButtonReturn) {
		if ([[defaults objectForKey:AKTransportPort] integerValue] == 0)
			[[self transportPort] setStringValue:@""];
		else
			[[self transportPort] setIntegerValue:[[defaults objectForKey:AKTransportPort] integerValue]];
		
		[[self STUNServerHost] setStringValue:[defaults objectForKey:AKSTUNServerHost]];
		if ([[defaults objectForKey:AKSTUNServerPort] integerValue] == 0)
			[[self STUNServerPort] setStringValue:@""];
		else
			[[self STUNServerPort] setIntegerValue:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
		
		[[self useICECheckBox] setState:[[defaults objectForKey:AKUseICE] integerValue]];
		
		[[self outboundProxyHost] setStringValue:[defaults objectForKey:AKOutboundProxyHost]];
		if ([[defaults objectForKey:AKOutboundProxyPort] integerValue] == 0)
			[[self outboundProxyPort] setStringValue:@""];
		else
			[[self outboundProxyPort] setIntegerValue:[[defaults objectForKey:AKOutboundProxyPort] integerValue]];
	}
	
	if ([sender isMemberOfClass:[NSToolbarItem class]]) {
		[[self toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
		[self changeView:sender];
	} else if ([sender isMemberOfClass:[NSWindow class]])
		[sender close];
}


#pragma mark -
#pragma mark NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [[defaults arrayForKey:AKAccounts] count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *accountDict = [[defaults arrayForKey:AKAccounts] objectAtIndex:rowIndex];
	
	return [accountDict objectForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:AKTelephoneAccountPboardType] owner:self];
	[pboard setData:data forType:AKTelephoneAccountPboardType];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSData *data = [[info draggingPasteboard] dataForType:AKTelephoneAccountPboardType];
	NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSInteger draggingRow = [indexes firstIndex];
	
	if (row == draggingRow || row == draggingRow + 1)
		return NSDragOperationNone;
	
	[[self accountsTable] setDropRow:row dropOperation:NSTableViewDropAbove];
	
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)operation
{
	NSData *data = [[info draggingPasteboard] dataForType:AKTelephoneAccountPboardType];
	NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSInteger draggingRow = [indexes firstIndex];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *accounts = [[defaults arrayForKey:AKAccounts] mutableCopy];
	id selectedAccount = [accounts objectAtIndex:[[self accountsTable] selectedRow]];
	
	// Swap accounts.
	[accounts insertObject:[accounts objectAtIndex:draggingRow] atIndex:row];
	if (draggingRow < row)
		[accounts removeObjectAtIndex:draggingRow];
	else if (draggingRow > row)
		[accounts removeObjectAtIndex:(draggingRow + 1)];
	else	// This should never happen because we don't validate such drop.
		return NO;
	
	[defaults setObject:accounts forKey:AKAccounts];
	[defaults synchronize];
	
	[[self accountsTable] reloadData];
	
	// Preserve account selection.
	[[self accountsTable] selectRow:[accounts indexOfObject:selectedAccount] byExtendingSelection:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:AKPreferenceControllerDidSwapAccountsNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInteger:draggingRow], AKSourceIndex,
																[NSNumber numberWithInteger:row], AKDestinationIndex,
																nil]];
	
	return YES;
}


#pragma mark -
#pragma mark NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger row = [[self accountsTable] selectedRow];

	[self populateFieldsForAccountAtIndex:row];
}


#pragma mark -
#pragma mark NSToolbar delegate

// Supply selectable toolbar items
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar
{	
	return [NSArray arrayWithObjects:
			[[self generalToolbarItem] itemIdentifier],
			[[self accountsToolbarItem] itemIdentifier],
			[[self soundToolbarItem] itemIdentifier],
			[[self networkToolbarItem] itemIdentifier],
			nil];
}


#pragma mark -
#pragma mark NSWindow delegate

- (BOOL)windowShouldClose:(id)window
{
	BOOL networkSettingsChanged = [self checkForNetworkSettingsChanges:window];
	if (networkSettingsChanged)
		return NO;
	
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	// Stop currently playing ringtone that might be selected in Preferences.
	[[[NSApp delegate] ringtone] stop];
}


#pragma mark -
#pragma mark NSPopUpButton notification

- (void)popUpButtonWillPopUp:(NSNotification *)notification
{
	[self updateAvailableSounds];
}


#pragma mark -
#pragma mark AKTelephone notifications

- (void)telephoneDidStartUserAgent:(NSNotification *)notification
{
	// Show transport port in the network preferences as a placeholder string.
	[[self transportPortCell] setPlaceholderString:
	 [[NSNumber numberWithUnsignedInteger:[[[NSApp delegate] telephone] transportPort]] stringValue]];
}

@end
