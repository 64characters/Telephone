//
//  AppController.m
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

#import "AppController.h"
#import "AKAccountController.h"
#import "AKCallController.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"


@implementation AppController

@synthesize telephone;
@synthesize accountControllers;
@synthesize preferenceController;

+ (void)initialize
{
	// Register defaults
	static BOOL initialized = NO;
	
	if (!initialized) {
		NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
		
		[defaultsDict setObject:@"" forKey:AKSTUNServerHost];
		[defaultsDict setObject:[NSNumber numberWithInteger:3478] forKey:AKSTUNServerPort];
		[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:AKVoiceActivityDetection];
		[defaultsDict setObject:@"~/Library/Logs/Telephone.log" forKey:AKLogFileName];
		[defaultsDict setObject:[NSNumber numberWithInteger:3] forKey:AKLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKConsoleLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKTransportPort];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
		
		initialized = YES;
	}
}

- (id)init
{
	self = [super init];
	if (self == nil)
		return nil;
	
	telephone = [AKTelephone telephoneWithDelegate:self];
	accountControllers = [[NSMutableDictionary alloc] init];
	[self setPreferenceController:nil];
	
	return self;
}

- (void)dealloc
{
	[telephone dealloc];
	[accountControllers release];
	
	if ([[[self preferenceController] delegate] isEqual:self])
		[[self preferenceController] setDelegate:nil];
	
	[preferenceController release];
	
	[super dealloc];
}

// Application control starts here
- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *STUNServerHost = [defaults stringForKey:AKSTUNServerHost];
	if ([STUNServerHost length] > 0)
		[telephone setSTUNServerHost:STUNServerHost];
	
	[telephone setSTUNServerPort:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	
	NSString *logFileName = [defaults stringForKey:AKLogFileName];
	if ([logFileName length] > 0)
		[telephone setLogFileName:logFileName];
	
	[telephone setLogLevel:[[defaults objectForKey:AKLogLevel] integerValue]];
	[telephone setConsoleLogLevel:[[defaults objectForKey:AKConsoleLogLevel] integerValue]];
	[telephone setDetectsVoiceActivity:[[defaults objectForKey:AKVoiceActivityDetection] boolValue]];
	
	NSInteger transportPort = [[defaults objectForKey:AKTransportPort] integerValue];
	if (transportPort > 0 && transportPort <= 65535)
		[telephone setTransportPort:transportPort];
	
	// Install audio devices changes callback
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices, AHPropertyListenerProc, [self telephone]);
	
	// Read accounts from defaults
	NSDictionary *savedAccounts = [defaults dictionaryForKey:AKAccounts];
	
	// Setup an account on first launch.
	if ([savedAccounts count] == 0) {			// There are no saved accounts, prompt user to add one.
		// Disable Preferences during the first account prompt.
		[preferencesMenuItem setAction:NULL];
		
		preferenceController = [[AKPreferenceController alloc] init];
		[[self preferenceController] setDelegate:self];
		[NSBundle loadNibNamed:@"AddAccount" owner:[self preferenceController]];
		
		// Subscribe to addAccountWindow close to terminate application.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(windowWillClose:)
													 name:NSWindowWillCloseNotification
												   object:[[self preferenceController] addAccountWindow]];
		
		// Set different targets and actions of addAccountWindow buttons to add the first account.
		[[[self preferenceController] addAccountWindowDefaultButton] setTarget:self];
		[[[self preferenceController] addAccountWindowDefaultButton] setAction:@selector(addAccountOnFirstLaunch:)];
		[[[self preferenceController] addAccountWindowOtherButton] setTarget:[[self preferenceController] addAccountWindow]];
		[[[self preferenceController] addAccountWindowOtherButton] setAction:@selector(performClose:)];
		
		[[[self preferenceController] addAccountWindow] center];
		[[[self preferenceController] addAccountWindow] makeKeyAndOrderFront:self];
		
		return;
	}
	
	NSArray *accountSortOrder = [defaults arrayForKey:AKAccountSortOrder];
	NSString *accountKey;
	AKAccountController *anAccountController;
	
	// There are saved accounts. Add accounts to Telephone, open account windows.
	for (NSUInteger i = 0; i < [accountSortOrder count]; ++i) {
		accountKey = [accountSortOrder objectAtIndex:i];
		NSDictionary *accountDict = [savedAccounts objectForKey:accountKey];
		
		if (![[accountDict objectForKey:AKAccountEnabled] boolValue])
			continue;
		
		NSString *fullName = [accountDict objectForKey:AKFullName];
		NSString *SIPAddress = [accountDict objectForKey:AKSIPAddress];
		NSString *registrar = [accountDict objectForKey:AKRegistrar];
		NSString *realm = [accountDict objectForKey:AKRealm];
		NSString *username = [accountDict objectForKey:AKUsername];
		
		anAccountController = [[AKAccountController alloc] initWithFullName:fullName
																 SIPAddress:SIPAddress
																  registrar:registrar
																	  realm:realm
																   username:username];
		[[self accountControllers] setObject:anAccountController forKey:accountKey];
		
		[[anAccountController window] setTitle:[[anAccountController account] SIPAddress]];
		
		if (i == 0)
			[[anAccountController window] makeKeyAndOrderFront:self];
		else {
			NSString *previousAccountKey = [accountSortOrder objectAtIndex:(i - 1)];
			NSWindow *previousAccountWindow = [[[self accountControllers] objectForKey:previousAccountKey] window];
			[[anAccountController window] orderWindow:NSWindowBelow relativeTo:[previousAccountWindow windowNumber]];
		}
		
		[anAccountController release];
	}
	
	// Register accounts.
	for (accountKey in [self accountControllers]) {
		anAccountController = [[self accountControllers] objectForKey:accountKey];
		[anAccountController setAccountRegistered:YES];
		
		// Don't register subsequent accounts if Telephone could not start.
		if (![[self telephone] started])
			break;
	}
}

// If user selected sound devices through preferences before, set these
// devices as active. Send NSNotFound as a particular device ID if there is no saved sound
// device in the defaults. This will set a first matched device.
- (void)selectSoundDevices
{
	NSArray *soundDevices = [[self telephone] soundDevices];
	NSInteger newSoundInput, newSoundOutput;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *deviceDict;
	NSInteger i;
	
	newSoundInput = newSoundOutput = NSNotFound;
	
	NSString *lastSoundInputString = [defaults objectForKey:AKSoundInput];
	if (lastSoundInputString != nil) {
		for (i = 0; i < [soundDevices count]; ++i) {
			deviceDict = [soundDevices objectAtIndex:i];
			if ([[deviceDict objectForKey:AKSoundDeviceName] isEqual:lastSoundInputString] &&
				[[deviceDict objectForKey:AKSoundDeviceInputCount] integerValue] > 0)
			{
				newSoundInput = i;
				break;
			}
		}
	}
	
	NSString *lastSoundOutputString = [defaults objectForKey:AKSoundOutput];
	if (lastSoundOutputString != nil) {
		for (i = 0; i < [soundDevices count]; ++i) {
			deviceDict = [soundDevices objectAtIndex:i];
			if ([[deviceDict objectForKey:AKSoundDeviceName] isEqual:lastSoundOutputString] &&
				[[deviceDict objectForKey:AKSoundDeviceOutputCount] integerValue] > 0)
			{
				newSoundOutput = i;
				break;
			}
		}
	}
	
	[[self telephone] setSoundInputDevice:newSoundInput soundOutputDevice:newSoundOutput];
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (preferenceController == nil) {
		preferenceController = [[AKPreferenceController alloc] init];
		[[self preferenceController] setDelegate:self];
	}
	
	if (![[[self preferenceController] window] isVisible])
		[[[self preferenceController] window] center];
	
	[[self preferenceController] showWindow:nil];
}
		 
- (IBAction)addAccountOnFirstLaunch:(id)sender
{
	[[self preferenceController] addAccount:sender];
	
	// Re-enable Preferences.
	[preferencesMenuItem setAction:@selector(showPreferencePanel:)];
	
	// Change back targets and actions of addAccountWindow buttons.
	[[[self preferenceController] addAccountWindowDefaultButton] setTarget:[self preferenceController]];
	[[[self preferenceController] addAccountWindowDefaultButton] setAction:@selector(addAccount:)];
	[[[self preferenceController] addAccountWindowOtherButton] setTarget:[self preferenceController]];
	[[[self preferenceController] addAccountWindowOtherButton] setAction:@selector(closeSheet:)];
}


#pragma mark AKPreferenceController delegate

- (void)preferenceControllerDidAddAccount:(NSNotification *)notification
{
	NSString *accountKey = [[[notification userInfo] allKeys] lastObject];
	NSDictionary *accountDict = [[notification userInfo] objectForKey:accountKey];
	AKAccountController *theAccountController =	[[AKAccountController alloc]
												 initWithFullName:[accountDict objectForKey:AKFullName]
												 SIPAddress:[accountDict objectForKey:AKSIPAddress]
												 registrar:[accountDict objectForKey:AKRegistrar]
												 realm:[accountDict objectForKey:AKRealm]
												 username:[accountDict objectForKey:AKUsername]];
	
	[[self accountControllers] setObject:theAccountController forKey:accountKey];
	
	[[theAccountController window] setTitle:[[theAccountController account] SIPAddress]];
	[[theAccountController window] orderFront:self];
	
	// Register account.
	[theAccountController setAccountRegistered:YES];
	
	[theAccountController release];
}

- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification
{
	NSString *accountKey = [[notification userInfo] objectForKey:AKAccountKey];
	[[self accountControllers] removeObjectForKey:accountKey];
}

- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification
{
	NSString *accountKey = [[notification userInfo] objectForKey:AKAccountKey];
	AKAccountController *theAccountController = [[self accountControllers] objectForKey:accountKey];
	
	if (theAccountController != nil) {
		[[self accountControllers] removeObjectForKey:accountKey];
	} else {
		NSDictionary *savedAccounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:AKAccounts];
		NSDictionary *accountDict = [savedAccounts objectForKey:accountKey];
		
		NSString *fullName = [accountDict objectForKey:AKFullName];
		NSString *SIPAddress = [accountDict objectForKey:AKSIPAddress];
		NSString *registrar = [accountDict objectForKey:AKRegistrar];
		NSString *realm = [accountDict objectForKey:AKRealm];
		NSString *username = [accountDict objectForKey:AKUsername];
		
		theAccountController = [[AKAccountController alloc] initWithFullName:fullName
																  SIPAddress:SIPAddress
																   registrar:registrar
																	   realm:realm
																	username:username];
		[[self accountControllers] setObject:theAccountController forKey:accountKey];
		
		[[theAccountController window] setTitle:[[theAccountController account] SIPAddress]];
		[[theAccountController window] orderFront:self];
		
		// Register account.
		[theAccountController setAccountRegistered:YES];
		
		[theAccountController release];
	}
}

- (void)preferenceControllerDidChangeSTUNServer:(NSNotification *)notification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (NSString *accountKey in [self accountControllers]) {
		AKAccountController *anAccountController = [[self accountControllers] objectForKey:accountKey];
		[[self telephone] removeAccount:[anAccountController account]];
	}

	[[self telephone] destroyUserAgent];
	[[self telephone] setSTUNServerHost:[defaults stringForKey:AKSTUNServerHost]];
	[[self telephone] setSTUNServerPort:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	[[self telephone] startUserAgent];
	
	for (NSString *accountKey in [self accountControllers]) {
		AKAccountController *anAccountController = [[self accountControllers] objectForKey:accountKey];
		[anAccountController setAccountRegistered:YES];
		
		// Don't register subsequent accounts if Telephone could not start.
		if (![[self telephone] started])
			break;
	}
}


#pragma mark -
#pragma mark AKTelephone delegate methods

// This method decides whether Telephone should add an account.
// Telephone is started in this method if needed.
- (BOOL)telephoneShouldAddAccount:(AKTelephoneAccount *)anAccount
{
	BOOL started;
	if ([[self telephone] started])
		return YES;
	else
		started = [[self telephone] startUserAgent];
	
	if (!started) {
		NSLog(@"Could not start Telephone agent. Please, check your network connection and STUN server settings.");
		
		// Display application modal alert.
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not start Telephone agent."];
		[alert setInformativeText:@"Please, check your network connection and STUN server settings."];
		[alert runModal];
		
		return NO;
	}
	
	[self selectSoundDevices];
	[[self preferenceController] updateSoundDevices];
	
	return YES;
}

// Telephone updated sound devices list and left the application silent.
// Must set appropriate sound IO here!
// Send message to preference controller to update list of sound devices.
- (void)telephoneDidUpdateSoundDevices:(NSNotification *)notification
{
	[self selectSoundDevices];
	
	// Update list of sound devices in preferences.
	[[self preferenceController] updateSoundDevices];
}

#pragma mark -
#pragma mark NSWindow notifications

- (void)windowWillClose:(NSNotification *)notification
{
	// User closed addAccountWindow. Terminate application.
	if ([[notification object] isEqual:[[self preferenceController] addAccountWindow]]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowWillCloseNotification
													  object:[[self preferenceController] addAccountWindow]];
		[NSApp terminate:self];
	}
}


#pragma mark -
#pragma mark NSApplication delegate methods

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	for (AKTelephoneAccount *anAccount in [[self telephone] accounts])
		if ([[anAccount calls] count] > 0) {
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"Quit"];
			[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:@"Are you shure you want to quit Telephone?"];
			[alert setInformativeText:@"All active calls will be disconnected."];
			
			NSInteger choice = [alert runModal];
			if (choice == NSAlertFirstButtonReturn)
				return NSTerminateNow;
			else if (choice == NSAlertSecondButtonReturn)
				return NSTerminateCancel;
		}
	
	return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// Close all calls.
	for (NSString *accountKey in [self accountControllers]) {
		AKAccountController *anAccountController = [[self accountControllers] objectForKey:accountKey];
		for (AKCallController *aCallController in [anAccountController callControllers])
			[aCallController close];
	}
	
	// Remove all accounts.
	[[self accountControllers] removeAllObjects];
	
	BOOL destroyed = [[self telephone] destroyUserAgent];
	if (!destroyed)
		NSLog(@"Error destroying user agent");
}

@end


#pragma mark -

// Send updateSoundDevices to Telephone. When Telephone updates sound devices, it should post a notification.
OSStatus AHPropertyListenerProc(AudioHardwarePropertyID inPropertyID, void *inClientData)
{
	AKTelephone *telephone = (AKTelephone *)inClientData;
	
	if (inPropertyID == kAudioHardwarePropertyDevices)
		[telephone performSelectorOnMainThread:@selector(updateSoundDevices)
														withObject:nil
													 waitUntilDone:NO];
	else
		NSLog(@"Not handling this property id");
	
	return noErr;
}
