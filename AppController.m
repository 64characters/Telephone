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
		
		[defaultsDict setObject:[NSNumber numberWithInt:3478] forKey:AKSTUNServerPort];
		[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:AKVoiceActivityDetection];
		[defaultsDict setObject:@"~/Library/Logs/Telephone.log" forKey:AKLogFileName];
		[defaultsDict setObject:[NSNumber numberWithInt:3] forKey:AKLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInt:0] forKey:AKConsoleLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInt:5060] forKey:AKTransportPort];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
		
		initialized = YES;
	}
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
	telephone = [AKTelephone telephoneWithDelegate:self];

	if (telephone == nil) {
		NSLog(@"Can't create Telephone");
		return;
	}
	
	BOOL started = [telephone start];
	if (!started)
		NSLog(@"Error starting Telephone");
	
	accountControllers = [[NSMutableDictionary alloc] init];
	
	[self selectSoundDevices];
	
	// Install audio devices changes callback
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices, AHPropertyListenerProc, [self telephone]);
	
	// Read accounts from defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
	
	// There are saved accounts. Add them to Telephone.
	NSArray *accountSortOrder = [defaults arrayForKey:AKAccountSortOrder];
	for (NSString *accountKey in accountSortOrder) {
		NSDictionary *accountDict = [savedAccounts objectForKey:accountKey];
		
		if (![[accountDict objectForKey:AKAccountEnabled] boolValue])
			continue;
		
		NSString *fullName = [accountDict objectForKey:AKFullName];
		NSString *SIPAddress = [accountDict objectForKey:AKSIPAddress];
		NSString *registrar = [accountDict objectForKey:AKRegistrar];
		NSString *realm = [accountDict objectForKey:AKRealm];
		NSString *username = [accountDict objectForKey:AKUsername];
		
		AKAccountController *anAccountController = [[AKAccountController alloc] initWithFullName:fullName
																					  SIPAddress:SIPAddress
																					   registrar:registrar
																						   realm:realm
																						username:username];
		[[self accountControllers] setObject:anAccountController forKey:accountKey];
		
		[[anAccountController window] setTitle:[[anAccountController account] SIPAddress]];
		[[anAccountController window] orderBack:self];
		
		[anAccountController release];
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
		
		[theAccountController release];
	}
}


#pragma mark -
#pragma mark AKTelephone delegate methods

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

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	BOOL destroyed = [[self telephone] destroyUserAgent];
	if (!destroyed)
		NSLog(@"Error destroying user agent");
}

@end


#pragma mark -

// Send updateSoundDevices to Telephone. When Telephone updates sound devices, it should post a notification.
OSStatus AHPropertyListenerProc(AudioHardwarePropertyID inPropertyID, void *inClientData)
{
	NSLog(@"Inside AHPropertyListenerProc()");
	AKTelephone *telephone = (AKTelephone *)inClientData;
	
	if (inPropertyID == kAudioHardwarePropertyDevices)
		[telephone performSelectorOnMainThread:@selector(updateSoundDevices)
														withObject:nil
													 waitUntilDone:NO];
	else
		NSLog(@"Not handling this property id");
	
	return noErr;
}
