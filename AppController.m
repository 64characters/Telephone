//
//  AppController.m
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

#import <CoreAudio/CoreAudio.h>
#import <Growl/Growl.h>

#import "AppController.h"
#import "AKAccountController.h"
#import "AKCallController.h"
#import "AKPreferenceController.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"


// AudioHardware callback to track adding/removing audio devices
static OSStatus AKAudioDevicesChanged(AudioHardwarePropertyID propertyID, void *clientData);
// Get audio devices data.
static OSStatus AKGetAudioDevices(Ptr *devices, UInt16 *devicesCount);

// Audio device dictionary keys.
NSString * const AKAudioDeviceIdentifier = @"AKAudioDeviceIdentifier";
NSString * const AKAudioDeviceName = @"AKAudioDeviceName";
NSString * const AKAudioDeviceInputsCount = @"AKAudioDeviceInputsCount";
NSString * const AKAudioDeviceOutputsCount = @"AKAudioDeviceOutputsCount";

@interface AppController()

- (void)setSelectedSoundIOToTelephone;
- (void)stopTelephoneSoundTick:(NSTimer *)theTimer;

@end

@implementation AppController

@synthesize telephone;
@synthesize accountControllers;
@synthesize preferenceController;
@synthesize audioDevices;
@synthesize soundInputDeviceIndex;
@synthesize soundOutputDeviceIndex;
@synthesize incomingCallSound;
@synthesize incomingCallSoundTimer;
@dynamic hasIncomingCallControllers;

- (BOOL)hasIncomingCallControllers
{
	for (AKAccountController *anAccountController in [[[self accountControllers] copy] autorelease]) {
		if (![anAccountController isEnabled])
			continue;
		
		for (AKCallController *aCallController in [[[anAccountController callControllers] copy] autorelease])
			if ([[aCallController call] identifier] != AKTelephoneInvalidIdentifier &&
				[[aCallController call] state] == AKTelephoneCallIncomingState)
				return YES;
	}
	
	return NO;
}

+ (void)initialize
{
	// Register defaults
	static BOOL initialized = NO;
	
	if (!initialized) {
		NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
		
		[defaultsDict setObject:@"" forKey:AKOutboundProxyHost];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKOutboundProxyPort];
		[defaultsDict setObject:@"" forKey:AKSTUNServerHost];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKSTUNServerPort];
		[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:AKVoiceActivityDetection];
		[defaultsDict setObject:@"~/Library/Logs/Telephone.log" forKey:AKLogFileName];
		[defaultsDict setObject:[NSNumber numberWithInteger:3] forKey:AKLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKConsoleLogLevel];
		[defaultsDict setObject:[NSNumber numberWithInteger:0] forKey:AKTransportPort];
		[defaultsDict setObject:@"Purr" forKey:AKRingingSound];
		
		NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
		
		// Do not format phone numbers in German localization by default.
		if ([preferredLocalization isEqualToString:@"German"])
			[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:AKFormatTelephoneNumbers];
		else
			[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:AKFormatTelephoneNumbers];
		
		// Split last four digits in Russian localization by default.
		if ([preferredLocalization isEqualToString:@"Russian"])
			[defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:AKTelephoneNumberFormatterSplitsLastFourDigits];
		else
			[defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:AKTelephoneNumberFormatterSplitsLastFourDigits];
		
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
	accountControllers = [[NSMutableArray alloc] init];
	[self setPreferenceController:nil];
	audioDevices = [[NSMutableArray alloc] init];
	[self setSoundInputDeviceIndex:AKTelephoneInvalidIdentifier];
	[self setSoundOutputDeviceIndex:AKTelephoneInvalidIdentifier];
	[self setIncomingCallSoundTimer:nil];
	
	// Subscribe to Early and Confirmed call states to set sound IO to Telephone.
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(telephoneCallCalling:)
							   name:AKTelephoneCallCallingNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(telephoneCallIncoming:)
							   name:AKTelephoneCallIncomingNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(telephoneCallDidDisconnect:)
							   name:AKTelephoneCallDidDisconnectNotification
							 object:nil];
	
	// Subscribe to NSWorkspace notifications about sleep, poweroff, etc.
	notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[notificationCenter addObserver:self
						   selector:@selector(workspaceWillSleepNotification:)
							   name:NSWorkspaceWillSleepNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(workspaceDidWakeNotification:)
							   name:NSWorkspaceDidWakeNotification
							 object:nil];
	
	return self;
}

- (void)dealloc
{
	[telephone dealloc];
	[accountControllers release];
	
	if ([[[self preferenceController] delegate] isEqual:self])
		[[self preferenceController] setDelegate:nil];
	[preferenceController release];
	
	[audioDevices release];
	[incomingCallSound release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[super dealloc];
}

// Application control starts here
- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[telephone setOutboundProxyHost:[defaults stringForKey:AKOutboundProxyHost]];
	[telephone setOutboundProxyPort:[[defaults objectForKey:AKOutboundProxyPort] integerValue]];
	[telephone setSTUNServerHost:[defaults stringForKey:AKSTUNServerHost]];
	[telephone setSTUNServerPort:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	[telephone setUserAgentString:@"Telephone 0.9.1"];
	[telephone setLogFileName:[defaults stringForKey:AKLogFileName]];
	[telephone setLogLevel:[[defaults objectForKey:AKLogLevel] integerValue]];
	[telephone setConsoleLogLevel:[[defaults objectForKey:AKConsoleLogLevel] integerValue]];
	[telephone setDetectsVoiceActivity:[[defaults objectForKey:AKVoiceActivityDetection] boolValue]];
	[telephone setTransportPort:[[defaults objectForKey:AKTransportPort] integerValue]];
	
	[self setIncomingCallSound:[NSSound soundNamed:[defaults stringForKey:AKRingingSound]]];
	
	// Install audio devices changes callback
	AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices, AKAudioDevicesChanged, self);
	
	// Get available audio devices, select devices for sound input and output.
	[self updateAudioDevices];
	
	// Load Growl.
	NSString *growlPath = [[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	if (growlBundle != nil && [growlBundle load])
		[GrowlApplicationBridge setGrowlDelegate:self];
	else
		NSLog(@"Could not load Growl.framework");
	
	// Read accounts from defaults
	NSArray *savedAccounts = [defaults arrayForKey:AKAccounts];
	
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
	
	NSDictionary *accountDict;
	AKAccountController *anAccountController;
	
	// There are saved accounts, open account windows.
	for (NSUInteger i = 0; i < [savedAccounts count]; ++i) {
		accountDict = [savedAccounts objectAtIndex:i];
		
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
		
		[anAccountController setEnabled:[[accountDict objectForKey:AKAccountEnabled] boolValue]];
		
		[[self accountControllers] addObject:anAccountController];
		
		if (![anAccountController isEnabled]) {
			// Prevent conflict with setFrameAutosaveName: when enabling the account.
			[anAccountController setWindow:nil];
			
			continue;
		}
		
		if (i == 0)
			[[anAccountController window] makeKeyAndOrderFront:self];
		else {
			NSWindow *previousAccountWindow = [[[self accountControllers] objectAtIndex:(i - 1)] window];
			[[anAccountController window] orderWindow:NSWindowBelow relativeTo:[previousAccountWindow windowNumber]];
		}
		
		[anAccountController release];
	}
	
	// Add accounts to Telephone.
	for (anAccountController in [self accountControllers]) {
		if (![anAccountController isEnabled])
			continue;

		[anAccountController setAccountRegistered:YES];
		
		// Don't add subsequent accounts if Telephone could not start.
		if (![[self telephone] started])
			break;
	}
}

- (void)updateAudioDevices
{
	OSStatus err = noErr;
    UInt32 size = 0;
	NSUInteger i = 0;
	AudioBufferList *theBufferList = NULL;
	
	// Flush current devices array.
	[[self audioDevices] removeAllObjects];
	
	// Fetch a pointer to the list of available devices.
	AudioDeviceID *devices = NULL;
	UInt16 devicesCount = 0;
	err = AKGetAudioDevices((Ptr *)&devices, &devicesCount);
	if (err != noErr)
		return;
	
	// Iterate over each device gathering information.
	for (NSUInteger loopCount = 0; loopCount < devicesCount; ++loopCount) {
		NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc] init];
		
		// Get device identifier.
		NSUInteger deviceIdentifier = devices[loopCount];
		[deviceDict setObject:[NSNumber numberWithUnsignedInteger:deviceIdentifier]
					   forKey: AKAudioDeviceIdentifier];
		
		// Get device name.
		CFStringRef tempStringRef = NULL;
		size = sizeof(CFStringRef);
		err = AudioDeviceGetProperty(devices[loopCount], 0, 0, kAudioDevicePropertyDeviceNameCFString, &size, &tempStringRef);
		[deviceDict setObject:(NSString *)tempStringRef forKey:AKAudioDeviceName];
		CFRelease(tempStringRef);
		
		// Get number of input channels.
		size = 0;
		NSUInteger inputChannelsCount = 0;
		err = AudioDeviceGetPropertyInfo(devices[loopCount], 0, 1, kAudioDevicePropertyStreamConfiguration, &size, NULL);
		if ((err == noErr) && (size != 0)) {
			theBufferList = (AudioBufferList *)malloc(size);
			if (theBufferList != NULL) {
				// Get the input stream configuration.
				err = AudioDeviceGetProperty(devices[loopCount], 0, 1, kAudioDevicePropertyStreamConfiguration, &size, theBufferList);
				if (err == noErr) {
					// Count the total number of input channels in the stream.
					for(i = 0; i < theBufferList->mNumberBuffers; ++i)
						inputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
				}
				free(theBufferList);
				
				[deviceDict setObject:[NSNumber numberWithUnsignedInteger:inputChannelsCount]
							   forKey:AKAudioDeviceInputsCount];
			}
		}
		
		// Get number of output channels.
		size = 0;
		NSUInteger outputChannelsCount = 0;
		err = AudioDeviceGetPropertyInfo(devices[loopCount], 0, 0, kAudioDevicePropertyStreamConfiguration, &size, NULL);
		if((err == noErr) && (size != 0)) {
			theBufferList = (AudioBufferList *)malloc(size);
			if(theBufferList != NULL) {
				// Get the input stream configuration.
				err = AudioDeviceGetProperty(devices[loopCount], 0, 0, kAudioDevicePropertyStreamConfiguration, &size, theBufferList);
				if(err == noErr) {
					// Count the total number of output channels in the stream.
					for (i = 0; i < theBufferList->mNumberBuffers; ++i)
						outputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
				}
				free(theBufferList);
				
				[deviceDict setObject:[NSNumber numberWithUnsignedInteger:outputChannelsCount]
							   forKey:AKAudioDeviceOutputsCount];
			}
		}
		
		[[self audioDevices] addObject:deviceDict];
		[deviceDict release];
	}
	
	// Update audio devices in Telephone.
	[[self telephone] performSelectorOnMainThread:@selector(updateAudioDevices)
									   withObject:nil
									waitUntilDone:YES];
	
	// Select sound IO from the updated audio devices list.
	// This method will change sound IO in Telephone if there are active calls.
	[self selectSoundIO];
	
	// Update audio devices in preferences.
	[[self preferenceController] updateAudioDevices];
}

// Select appropriate sound IO from the list of available audio devices.
// Lookup in the defaults database for devices selected earlier. If not found, use first matched.
// Select sound IO at Telephone if there are active calls.
- (void)selectSoundIO
{
	NSArray *devices = [self audioDevices];
	NSInteger newSoundInput, newSoundOutput;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *deviceDict;
	NSInteger i;
	
	// Lookup devices records in the defaults.
	
	newSoundInput = newSoundOutput = NSNotFound;
	
	NSString *lastSoundInputString = [defaults objectForKey:AKSoundInput];
	if (lastSoundInputString != nil) {
		for (i = 0; i < [devices count]; ++i) {
			deviceDict = [devices objectAtIndex:i];
			if ([[deviceDict objectForKey:AKAudioDeviceName] isEqual:lastSoundInputString] &&
				[[deviceDict objectForKey:AKAudioDeviceInputsCount] integerValue] > 0)
			{
				newSoundInput = i;
				break;
			}
		}
	}
	
	NSString *lastSoundOutputString = [defaults objectForKey:AKSoundOutput];
	if (lastSoundOutputString != nil) {
		for (i = 0; i < [devices count]; ++i) {
			deviceDict = [devices objectAtIndex:i];
			if ([[deviceDict objectForKey:AKAudioDeviceName] isEqual:lastSoundOutputString] &&
				[[deviceDict objectForKey:AKAudioDeviceOutputsCount] integerValue] > 0)
			{
				newSoundOutput = i;
				break;
			}
		}
	}
	
	// If still not found, select first matched.
	
	if (newSoundInput == NSNotFound) {
		for (i = 0; i < [devices count]; ++i)
			if ([[[devices objectAtIndex:i] objectForKey:AKAudioDeviceInputsCount] integerValue] > 0) {
				newSoundInput = i;
				break;
			}
	}
	
	if (newSoundOutput == NSNotFound) {
		for (i = 0; i < [devices count]; ++i)
			if ([[[devices objectAtIndex:i] objectForKey:AKAudioDeviceOutputsCount] integerValue] > 0) {
				newSoundOutput = i;
				break;
			}
	}
	
	[self setSoundInputDeviceIndex:newSoundInput];
	[self setSoundOutputDeviceIndex:newSoundOutput];
	
	// Set selected sound IO to Telephone if there are active calls.
	if ([[self telephone] activeCallsCount] > 0)
		[self performSelectorOnMainThread:@selector(setSelectedSoundIOToTelephone)
							   withObject:nil
							waitUntilDone:NO];
}

- (void)setSelectedSoundIOToTelephone
{
	[[self telephone] setSoundInputDevice:[self soundInputDeviceIndex]
						soundOutputDevice:[self soundOutputDeviceIndex]];
}

- (void)stopTelephoneSoundTick:(NSTimer *)theTimer
{
	if ([[self telephone] activeCallsCount] == 0 && ![[self telephone] soundStopped])
		[[self telephone] stopSound];
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

- (void)startIncomingCallSoundTimer
{
	if ([self incomingCallSoundTimer] != nil)
		[[self incomingCallSoundTimer] invalidate];
	
	[self setIncomingCallSoundTimer:[NSTimer scheduledTimerWithTimeInterval:4
																	 target:self
																   selector:@selector(incomingCallSoundTimerTick:)
																   userInfo:nil
																	repeats:YES]];
}

- (void)stopIncomingCallSoundTimer
{
	if (![self hasIncomingCallControllers] && [self incomingCallSoundTimer] != nil) {
		[[self incomingCallSound] stop];
		[[self incomingCallSoundTimer] invalidate];
		[self setIncomingCallSoundTimer:nil];
	}
}

- (void)incomingCallSoundTimerTick:(NSTimer *)theTimer
{
	[[self incomingCallSound] play];
}

- (AKCallController *)callControllerByIdentifier:(NSString *)identifier
{
	for (AKAccountController *anAccountController in [[[self accountControllers] copy] autorelease]) {
		if (![anAccountController isEnabled])
			continue;
	
		for (AKCallController *aCallController in [[[anAccountController callControllers] copy] autorelease])
			if ([[aCallController identifier] isEqualToString:identifier])
				return aCallController;
	}
	
	return nil;
}

- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode
{
	NSString *localizedString = nil;
	
	switch (responseCode) {
			// Provisional 1xx.
		case PJSIP_SC_TRYING:
			localizedString = NSLocalizedStringFromTable(@"Trying", @"SIPResponses", @"100 Trying.");
			break;
		case PJSIP_SC_RINGING:
			localizedString = NSLocalizedStringFromTable(@"Ringing", @"SIPResponses", @"180 Ringing.");
			break;
		case PJSIP_SC_CALL_BEING_FORWARDED:
			localizedString = NSLocalizedStringFromTable(@"Call Is Being Forwarded", @"SIPResponses", @"181 Call Is Being Forwarded.");
			break;
		case PJSIP_SC_QUEUED:
			localizedString = NSLocalizedStringFromTable(@"Queued", @"SIPResponses", @"182 Queued.");
			break;
		case PJSIP_SC_PROGRESS:
			localizedString = NSLocalizedStringFromTable(@"Session Progress", @"SIPResponses", @"183 Session Progress.");
			break;
			
			// Successful 2xx.
		case PJSIP_SC_OK:
			localizedString = NSLocalizedStringFromTable(@"OK", @"SIPResponses", @"200 OK.");
			break;
		case PJSIP_SC_ACCEPTED:
			localizedString = NSLocalizedStringFromTable(@"Accepted", @"SIPResponses", @"202 Accepted.");
			break;
			
			// Redirection 3xx.
		case PJSIP_SC_MULTIPLE_CHOICES:
			localizedString = NSLocalizedStringFromTable(@"Multiple Choices", @"SIPResponses", @"300 Multiple Choices.");
			break;
		case PJSIP_SC_MOVED_PERMANENTLY:
			localizedString = NSLocalizedStringFromTable(@"Moved Permanently", @"SIPResponses", @"301 Moved Permanently.");
			break;
		case PJSIP_SC_MOVED_TEMPORARILY:
			localizedString = NSLocalizedStringFromTable(@"Moved Temporarily", @"SIPResponses", @"302 Moved Temporarily.");
			break;
		case PJSIP_SC_USE_PROXY:
			localizedString = NSLocalizedStringFromTable(@"Use Proxy", @"SIPResponses", @"305 Use Proxy.");
			break;
		case PJSIP_SC_ALTERNATIVE_SERVICE:
			localizedString = NSLocalizedStringFromTable(@"Alternative Service", @"SIPResponses", @"380 Alternative Service.");
			break;
			
			// Request Failure 4xx.
		case PJSIP_SC_BAD_REQUEST:
			localizedString = NSLocalizedStringFromTable(@"Bad Request", @"SIPResponses", @"400 Bad Request.");
			break;
		case PJSIP_SC_UNAUTHORIZED:
			localizedString = NSLocalizedStringFromTable(@"Unauthorized", @"SIPResponses", @"401 Unauthorized.");
			break;
		case PJSIP_SC_PAYMENT_REQUIRED:
			localizedString = NSLocalizedStringFromTable(@"Payment Required", @"SIPResponses", @"402 Payment Required.");
			break;
		case PJSIP_SC_FORBIDDEN:
			localizedString = NSLocalizedStringFromTable(@"Forbidden", @"SIPResponses", @"403 Forbidden.");
			break;
		case PJSIP_SC_NOT_FOUND:
			localizedString = NSLocalizedStringFromTable(@"Not Found", @"SIPResponses", @"404 Not Found.");
			break;
		case PJSIP_SC_METHOD_NOT_ALLOWED:
			localizedString = NSLocalizedStringFromTable(@"Method Not Allowed", @"SIPResponses", @"405 Method Not Allowed.");
			break;
		case PJSIP_SC_NOT_ACCEPTABLE:
			localizedString = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses", @"406 Not Acceptable.");
			break;
		case PJSIP_SC_PROXY_AUTHENTICATION_REQUIRED:
			localizedString = NSLocalizedStringFromTable(@"Proxy Authentication Required", @"SIPResponses", @"407 Proxy Authentication Required.");
			break;
		case PJSIP_SC_REQUEST_TIMEOUT:
			localizedString = NSLocalizedStringFromTable(@"Request Timeout", @"SIPResponses", @"408 Request Timeout.");
			break;
		case PJSIP_SC_GONE:
			localizedString = NSLocalizedStringFromTable(@"Gone", @"SIPResponses", @"410 Gone.");
			break;
		case PJSIP_SC_REQUEST_ENTITY_TOO_LARGE:
			localizedString = NSLocalizedStringFromTable(@"Request Entity Too Large", @"SIPResponses", @"413 Request Entity Too Large.");
			break;
		case PJSIP_SC_REQUEST_URI_TOO_LONG:
			localizedString = NSLocalizedStringFromTable(@"Request-URI Too Long", @"SIPResponses", @"414 Request-URI Too Long.");
			break;
		case PJSIP_SC_UNSUPPORTED_MEDIA_TYPE:
			localizedString = NSLocalizedStringFromTable(@"Unsupported Media Type", @"SIPResponses", @"415 Unsupported Media Type.");
			break;
		case PJSIP_SC_UNSUPPORTED_URI_SCHEME:
			localizedString = NSLocalizedStringFromTable(@"Unsupported URI Scheme", @"SIPResponses", @"416 Unsupported URI Scheme.");
			break;
		case PJSIP_SC_BAD_EXTENSION:
			localizedString = NSLocalizedStringFromTable(@"Bad Extension", @"SIPResponses", @"420 Bad Extension.");
			break;
		case PJSIP_SC_EXTENSION_REQUIRED:
			localizedString = NSLocalizedStringFromTable(@"Extension Required", @"SIPResponses", @"421 Extension Required.");
			break;
		case PJSIP_SC_SESSION_TIMER_TOO_SMALL:
			localizedString = NSLocalizedStringFromTable(@"Session Timer Too Small", @"SIPResponses", @"422 Session Timer Too Small.");
			break;
		case PJSIP_SC_INTERVAL_TOO_BRIEF:
			localizedString = NSLocalizedStringFromTable(@"Interval Too Brief", @"SIPResponses", @"423 Interval Too Brief.");
			break;
		case PJSIP_SC_TEMPORARILY_UNAVAILABLE:
			localizedString = NSLocalizedStringFromTable(@"Temporarily Unavailable", @"SIPResponses", @"480 Temporarily Unavailable.");
			break;
		case PJSIP_SC_CALL_TSX_DOES_NOT_EXIST:
			localizedString = NSLocalizedStringFromTable(@"Call/Transaction Does Not Exist", @"SIPResponses", @"481 Call/Transaction Does Not Exist.");
			break;
		case PJSIP_SC_LOOP_DETECTED:
			localizedString = NSLocalizedStringFromTable(@"Loop Detected", @"SIPResponses", @"482 Loop Detected.");
			break;
		case PJSIP_SC_TOO_MANY_HOPS:
			localizedString = NSLocalizedStringFromTable(@"Too Many Hops", @"SIPResponses", @"483 Too Many Hops.");
			break;
		case PJSIP_SC_ADDRESS_INCOMPLETE:
			localizedString = NSLocalizedStringFromTable(@"Address Incomplete", @"SIPResponses", @"484 Address Incomplete.");
			break;
		case PJSIP_AC_AMBIGUOUS:
			localizedString = NSLocalizedStringFromTable(@"Ambiguous", @"SIPResponses", @"485 Ambiguous.");
			break;
		case PJSIP_SC_BUSY_HERE:
			localizedString = NSLocalizedStringFromTable(@"Busy Here", @"SIPResponses", @"486 Busy Here.");
			break;
		case PJSIP_SC_REQUEST_TERMINATED:
			localizedString = NSLocalizedStringFromTable(@"Request Terminated", @"SIPResponses", @"487 Request Terminated.");
			break;
		case PJSIP_SC_NOT_ACCEPTABLE_HERE:
			localizedString = NSLocalizedStringFromTable(@"Not Acceptable Here", @"SIPResponses", @"488 Not Acceptable Here.");
			break;
		case PJSIP_SC_BAD_EVENT:
			localizedString = NSLocalizedStringFromTable(@"Bad Event", @"SIPResponses", @"489 Bad Event.");
			break;
		case PJSIP_SC_REQUEST_UPDATED:
			localizedString = NSLocalizedStringFromTable(@"Request Updated", @"SIPResponses", @"490 Request Updated.");
			break;
		case PJSIP_SC_REQUEST_PENDING:
			localizedString = NSLocalizedStringFromTable(@"Request Pending", @"SIPResponses", @"491 Request Pending.");
			break;
		case PJSIP_SC_UNDECIPHERABLE:
			localizedString = NSLocalizedStringFromTable(@"Undecipherable", @"SIPResponses", @"493 Undecipherable.");
			break;
			
			// Server Failure 5xx.
		case PJSIP_SC_INTERNAL_SERVER_ERROR:
			localizedString = NSLocalizedStringFromTable(@"Server Internal Error", @"SIPResponses", @"500 Server Internal Error.");
			break;
		case PJSIP_SC_NOT_IMPLEMENTED:
			localizedString = NSLocalizedStringFromTable(@"Not Implemented", @"SIPResponses", @"501 Not Implemented.");
			break;
		case PJSIP_SC_BAD_GATEWAY:
			localizedString = NSLocalizedStringFromTable(@"Bad Gateway", @"SIPResponses", @"502 Bad Gateway.");
			break;
		case PJSIP_SC_SERVICE_UNAVAILABLE:
			localizedString = NSLocalizedStringFromTable(@"Service Unavailable", @"SIPResponses", @"503 Service Unavailable.");
			break;
		case PJSIP_SC_SERVER_TIMEOUT:
			localizedString = NSLocalizedStringFromTable(@"Server Time-out", @"SIPResponses", @"504 Server Time-out.");
			break;
		case PJSIP_SC_VERSION_NOT_SUPPORTED:
			localizedString = NSLocalizedStringFromTable(@"Version Not Supported", @"SIPResponses", @"505 Version Not Supported.");
			break;
		case PJSIP_SC_MESSAGE_TOO_LARGE:
			localizedString = NSLocalizedStringFromTable(@"Message Too Large", @"SIPResponses", @"513 Message Too Large.");
			break;
		case PJSIP_SC_PRECONDITION_FAILURE:
			localizedString = NSLocalizedStringFromTable(@"Precondition Failure", @"SIPResponses", @"580 Precondition Failure.");
			break;
			
			// Global Failures 6xx.
		case PJSIP_SC_BUSY_EVERYWHERE:
			localizedString = NSLocalizedStringFromTable(@"Busy Everywhere", @"SIPResponses", @"600 Busy Everywhere.");
			break;
		case PJSIP_SC_DECLINE:
			localizedString = NSLocalizedStringFromTable(@"Decline", @"SIPResponses", @"603 Decline.");
			break;
		case PJSIP_SC_DOES_NOT_EXIST_ANYWHERE:
			localizedString = NSLocalizedStringFromTable(@"Does Not Exist Anywhere", @"SIPResponses", @"604 Does Not Exist Anywhere.");
			break;
		case PJSIP_SC_NOT_ACCEPTABLE_ANYWHERE:
			localizedString = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses", @"606 Not Acceptable.");
			break;
		default:
			localizedString = nil;
			break;
	}
	
	return localizedString;
}


#pragma mark -
#pragma mark AKPreferenceController delegate

- (void)preferenceControllerDidAddAccount:(NSNotification *)notification
{
	NSDictionary *accountDict = [notification userInfo];
	AKAccountController *theAccountController =	[[[AKAccountController alloc]
												  initWithFullName:[accountDict objectForKey:AKFullName]
												  SIPAddress:[accountDict objectForKey:AKSIPAddress]
												  registrar:[accountDict objectForKey:AKRegistrar]
												  realm:[accountDict objectForKey:AKRealm]
												  username:[accountDict objectForKey:AKUsername]]
												 autorelease];
	[theAccountController setEnabled:YES];
	
	[[self accountControllers] addObject:theAccountController];
	
	[[theAccountController window] orderFront:self];
	
	// Register account.
	[theAccountController setAccountRegistered:YES];
}

- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification
{
	NSInteger index = [[[notification userInfo] objectForKey:AKAccountIndex] integerValue];
	AKAccountController *anAccountController = [[self accountControllers] objectAtIndex:index];
	
	if ([anAccountController isEnabled])
		[anAccountController removeAccountFromTelephone];
	
	[[self accountControllers] removeObjectAtIndex:index];
}

- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification
{
	NSUInteger index = [[[notification userInfo] objectForKey:AKAccountIndex] integerValue];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedAccounts = [defaults arrayForKey:AKAccounts];
	NSDictionary *accountDict = [savedAccounts objectAtIndex:index];
	
	BOOL isEnabled = [[accountDict objectForKey:AKAccountEnabled] boolValue];
	if (isEnabled) {
		AKAccountController *theAccountController = [[AKAccountController alloc]
													  initWithFullName:[accountDict objectForKey:AKFullName]
													  SIPAddress:[accountDict objectForKey:AKSIPAddress]
													  registrar:[accountDict objectForKey:AKRegistrar]
													  realm:[accountDict objectForKey:AKRealm]
													  username:[accountDict objectForKey:AKUsername]];
		[theAccountController setEnabled:isEnabled];
		
		[[self accountControllers] replaceObjectAtIndex:index withObject:theAccountController];

		[[theAccountController window] orderFront:nil];
		
		// Register account (as a result, it will be added to Telephone).
		[theAccountController setAccountRegistered:YES];
		
		[theAccountController release];
		
	} else {
		AKAccountController *theAccountController = [[self accountControllers] objectAtIndex:index];
		[theAccountController setEnabled:isEnabled];
		
		// Remove account from Telephone.
		[theAccountController removeAccountFromTelephone];
		[[theAccountController window] orderOut:nil];

		// Prevent conflict with setFrameAutosaveName: when re-enabling the account.
		[theAccountController setWindow:nil];
	}
}

- (void)preferenceControllerDidChangeNetworkSettings:(NSNotification *)notification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (![[self telephone] started]) {
		[[self telephone] setSTUNServerHost:[defaults stringForKey:AKSTUNServerHost]];
		[[self telephone] setSTUNServerPort:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
		[[self telephone] setOutboundProxyHost:[defaults stringForKey:AKOutboundProxyHost]];
		[[self telephone] setOutboundProxyPort:[[defaults objectForKey:AKOutboundProxyPort] integerValue]];
		
		return;
	}
	
	AKAccountController *anAccountController;
	
	// Unregister accounts.
	for (anAccountController in [self accountControllers])
		if ([anAccountController isEnabled])
			[[anAccountController account] setRegistered:NO];
	
	// Wait one second to receive unregistrations confirmations.
	sleep(1);
	
	// Remove accounts from Telephone.
	for (anAccountController in [self accountControllers]) {
		if (![anAccountController isEnabled])
			continue;
		
		[anAccountController removeAccountFromTelephone];
	}

	[[self telephone] destroyUserAgent];
	[[self telephone] setSTUNServerHost:[defaults stringForKey:AKSTUNServerHost]];
	[[self telephone] setSTUNServerPort:[[defaults objectForKey:AKSTUNServerPort] integerValue]];
	[[self telephone] setOutboundProxyHost:[defaults stringForKey:AKOutboundProxyHost]];
	[[self telephone] setOutboundProxyPort:[[defaults objectForKey:AKOutboundProxyPort] integerValue]];
	
	
	// Add accounts to Telephone.
	for (anAccountController in [self accountControllers]) {
		if (![anAccountController isEnabled])
			continue;
		
		[anAccountController setAccountRegistered:YES];
		
		// Don't add subsequent accounts if Telephone could not start.
		if (![[self telephone] started])
			break;
	}
}


#pragma mark -
#pragma mark AKTelephoneDelegate protocol

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
		NSLog(@"Could not start SIP user agent. Please check your network connection and STUN server settings.");
		
		// Display application modal alert.
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:NSLocalizedString(@"Could not start SIP user agent.", @"SIP user agent start error.")];
		[alert setInformativeText:NSLocalizedString(@"Please check your network connection and STUN server settings.",
													@"SIP user agent start error informative text.")];
		[alert runModal];
		
		return NO;
	}
	
	return YES;
}


#pragma mark -
#pragma mark AKTelephone notifications

- (void)telephoneDidDetectNAT:(NSNotification *)notification
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	
	switch ([[self telephone] detectedNATType]) {
		case AKNATTypeBlocked:
			[alert setMessageText:NSLocalizedString(@"Failed to communicate with STUN server.", @"Failed to communicate with STUN server.")];
			[alert setInformativeText:NSLocalizedString(@"UDP packets are probably blocked. It is impossible to make or receive calls without that. " \
														@"Make shure that your local firewall and the firewall at your router allow UDP protocol.",
														@"Failed to communicate with STUN server informative text.")];
			[alert runModal];
			break;
			
		case AKNATTypeSymmetric:
			[alert setMessageText:NSLocalizedString(@"Symmetric NAT detected.", @"Detected Symmetric NAT.")];
			[alert setInformativeText:NSLocalizedString(@"It very unlikely that two-way conversations will be possible " \
														"with the symmetric NAT. Contact you SIP provider to find out other NAT traversal options. " \
														"If you are connected to the internet through the personal router, try to replace it with the one " \
														"that supports \\U201Cfull cone\\U201D, \\U201Crestricted cone\\U201D or " \
														"\\U201Cport restricted cone\\U201D NAT types.",
														@"Detected Symmetric NAT informative text.")];
			[alert runModal];
			break;
			
		default:
			break;
	}
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

// Reopen all account windows when the user clicks the dock icon.
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	NSArray *immutableAccountControllers = [[[self accountControllers] copy] autorelease];
	
	// Show incoming call window, if any.
	if ([self hasIncomingCallControllers]) {
		for (AKAccountController *anAccountController in immutableAccountControllers) {
			if (![anAccountController isEnabled])
				continue;
			
			for (AKCallController *aCallController in [[[anAccountController callControllers] copy] autorelease])
				if ([[aCallController call] identifier] != AKTelephoneInvalidIdentifier &&
					[[aCallController call] state] == AKTelephoneCallIncomingState)
				{
					[aCallController showWindow:nil];
					return YES;
				}
		}
	}
	
	// No incoming calls, show window of the enabled accounts.
	for (AKAccountController *anAccountController in immutableAccountControllers) {
		if ([anAccountController isEnabled] && ![[anAccountController window] isVisible])
			[[anAccountController window] orderFront:nil];
	}
	
	// Is there a key window already?
	BOOL keyWindowExists = NO;
	for (AKAccountController *anAccountController in immutableAccountControllers) {
		if (keyWindowExists)	// Break this cicle from the included cicle below.
			break;
		
		if (![anAccountController isEnabled])
			continue;
		
		// Check the account window itsef.
		if ([[anAccountController window] isKeyWindow]) {
			keyWindowExists = YES;
			break;
		}
		// Check call windows.
		for (AKCallController *aCallController in [[[anAccountController callControllers] copy] autorelease])
			if ([[aCallController window] isKeyWindow]) {
				keyWindowExists = YES;
				break;
			}
	}
	
	// Make first account window key if there are no other key windows.
	if (!keyWindowExists)
		[[[[self accountControllers] objectAtIndex:0] window] makeKeyWindow];
	
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	for (AKTelephoneAccount *anAccount in [[self telephone] accounts])
		if ([[anAccount calls] count] > 0) {
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"Quit button.")];
			[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
			[[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
			[alert setMessageText:NSLocalizedString(@"Are you shure you want to quit Telephone?", @"Telephone quit confirmation.")];
			[alert setInformativeText:NSLocalizedString(@"All active calls will be disconnected.", @"Telephone quit confirmation informative text.")];
			
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
	// Remove all accounts.
	[[self accountControllers] removeAllObjects];
	
	BOOL destroyed = [[self telephone] destroyUserAgent];
	if (!destroyed)
		NSLog(@"Error destroying user agent");
}


#pragma mark -
#pragma mark AKTelephoneCall notifications

- (void)telephoneCallCalling:(NSNotification *)notification
{
	if ([[self telephone] activeCallsCount] > 0 && [[self telephone] soundStopped])
		[self setSelectedSoundIOToTelephone];
}

- (void)telephoneCallIncoming:(NSNotification *)notification
{
	if ([[self telephone] activeCallsCount] > 0 && [[self telephone] soundStopped])
		[self setSelectedSoundIOToTelephone];
}

- (void)telephoneCallDidDisconnect:(NSNotification *)notification
{
	[NSTimer scheduledTimerWithTimeInterval:1
									 target:self
								   selector:@selector(stopTelephoneSoundTick:)
								   userInfo:nil
									repeats:NO];
}


#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate protocol

- (void)growlNotificationWasClicked:(id)clickContext
{
	NSString *identifier = (NSString *)clickContext;
	AKCallController *aCallController = [self callControllerByIdentifier:identifier];
	
	// Make application active.
	if (![NSApp isActive])
		[NSApp activateIgnoringOtherApps:YES];
	
	// Make corresponding call window key.
	[aCallController showWindow:nil];
}


#pragma mark -
#pragma mark NSWorkspace notifications

- (void)workspaceWillSleepNotification:(NSNotification *)notification
{
	// Force hang up all calls and remove accounts from Telephone.
	for (AKAccountController *anAccountController in [self accountControllers]) {
		for (AKCallController *aCallController in [[[anAccountController callControllers] copy] autorelease])
			[aCallController forceCallHangUp];
		
		if (![anAccountController isEnabled])
			continue;
		
		[anAccountController removeAccountFromTelephone];
	}
	
	[[self telephone] destroyUserAgent];
}

- (void)workspaceDidWakeNotification:(NSNotification *)notification
{
	sleep(1);
	
	// Add accounts to Telephone starting SIP user agent lazily.
	for (AKAccountController *anAccountController in [self accountControllers]) {
		if (![anAccountController isEnabled])
			continue;
		
		[anAccountController setAccountRegistered:YES];
		
		// Don't add subsequent accounts if Telephone could not start.
		if (![[self telephone] started])
			break;
	}
}

@end


#pragma mark -

// Send updateAudioDevices to AppController.
static OSStatus AKAudioDevicesChanged(AudioHardwarePropertyID propertyID, void *clientData)
{
	AppController *appController = (AppController *)clientData;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (propertyID == kAudioHardwarePropertyDevices) {
		[NSObject cancelPreviousPerformRequestsWithTarget:appController
												 selector:@selector(updateAudioDevices)
												   object:nil];
		[appController performSelector:@selector(updateAudioDevices)
							withObject:nil
							afterDelay:0.2];
	} else
		NSLog(@"Not handling this property id");
	
	[pool drain];
	
	return noErr;
}

static OSStatus AKGetAudioDevices(Ptr *devices, UInt16 *devicesCount)
{
    OSStatus err = noErr;
    UInt32 size;
    Boolean isWritable;
    
	// Get sound devices count.
    err = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &size, &isWritable);
    if (err != noErr)
		return err;
	
	*devicesCount = size / sizeof(AudioDeviceID);
    if (*devicesCount < 1)
		return err;
    
    // Allocate space for devcies.
    *devices = (Ptr)malloc(size);
    memset(*devices, 0, size);
	
	// Get the data.
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &size, (void *)*devices);	
    if (err != noErr)
		return err;
	
    return err;
}


// Growl notification names.
NSString * const AKGrowlNotificationIncomingCall = @"Incoming Call";
NSString * const AKGrowlNotificationCallEnded = @"Call Ended";
