//
//  AppController.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AppController.h"

#import <CoreAudio/CoreAudio.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Growl/Growl.h>

#import "AKAddressBookPhonePlugIn.h"
#import "AKAddressBookSIPAddressPlugIn.h"
#import "AKKeychain.h"
#import "AKNetworkReachability.h"
#import "AKNSString+Scanning.h"
#import "AKSIPAccount.h"
#import "AKSIPCall.h"
#import "AKSIPURI.h"
#import "AKSIPUserAgent.h"
#import "iTunes.h"

#import "AccountController.h"
#import "AccountPreferencesViewController.h"
#import "AccountSetupController.h"
#import "ActiveAccountViewController.h"
#import "AuthenticationFailureController.h"
#import "CallController.h"
#import "PreferencesController.h"
#import "SoundPreferencesViewController.h"
#import "UserDefaultsKeys.h"


NSString * const kAudioDeviceIdentifier = @"AudioDeviceIdentifier";
NSString * const kAudioDeviceUID = @"AudioDeviceUID";
NSString * const kAudioDeviceName = @"AudioDeviceName";
NSString * const kAudioDeviceInputsCount = @"AudioDeviceInputsCount";
NSString * const kAudioDeviceOutputsCount = @"AudioDeviceOutputsCount";
NSString * const kAudioDeviceBuiltIn = @"AudioDeviceBuiltIn";

NSString * const kUserNotificationCallControllerIdentifierKey = @"UserNotificationCallControllerIdentifier";
NSString * const kGrowlNotificationIncomingCall = @"Incoming Call";
NSString * const kGrowlNotificationCallEnded = @"Call Ended";

// Ringtone time interval.
static const NSTimeInterval kRingtoneInterval = 4.0;

// Bouncing icon in the Dock time interval.
static const NSTimeInterval kUserAttentionRequestInterval = 8.0;

// Delay for restarting user agent when DNS servers change.
static const NSTimeInterval kUserAgentRestartDelayAfterDNSChange = 3.0;

// Dynamic store key to the global DNS settings.
static NSString * const kDynamicStoreDNSSettings = @"State:/Network/Global/DNS";

// AudioHardware callback to track adding/removing audio devices.
static OSStatus AudioDevicesChanged(AudioObjectID objectID,
                                    UInt32 numberAddresses,
                                    const AudioObjectPropertyAddress addresses[],
                                    void *clientData);

// Schedules -updateAudioDevices call on the app controller on the main queue.
static void ScheduleAudioDevicesUpdate(AppController *appController);

// Gets audio devices data.
static OSStatus GetAudioDevices(Ptr *devices, UInt16 *devicesCount);

// Dynamic store callback for DNS changes.
static void NameserversChanged(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info);

@interface AppController () <AKSIPUserAgentDelegate, NSUserNotificationCenterDelegate, GrowlApplicationBridgeDelegate, PreferencesControllerDelegate>

// Sets selected sound IO to the user agent.
- (void)setSelectedSoundIOToUserAgent;

// Installs Address Book plug-ins.
- (void)installAddressBookPlugIns;

// Installs a callback to monitor system DNS servers changes.
- (void)installDNSChangesCallback;

// Creates directory for file at the specified path.  Also creates intermediate
// directories.
- (void)createDirectoryForFileAtPath:(NSString *)path;

// Updates callsShouldDisplayAccountInfo on account controllers.
- (void)updateCallsShouldDisplayAccountInfo;

@end


@implementation AppController

@synthesize preferencesController = _preferencesController;
@synthesize accountSetupController = _accountSetupController;

- (NSArray *)enabledAccountControllers {
    return [[self accountControllers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled == YES"]];
}

- (PreferencesController *)preferencesController {
    if (_preferencesController == nil) {
        _preferencesController = [[PreferencesController alloc] init];
        [_preferencesController setDelegate:self];
    }
    return _preferencesController;
}

- (AccountSetupController *)accountSetupController {
    if (_accountSetupController == nil) {
        _accountSetupController = [[AccountSetupController alloc] init];
    }
    return _accountSetupController;
}

- (void)setRingtone:(NSSound *)aRingtone {
    if (_ringtone != aRingtone) {
        _ringtone = aRingtone;
        
        if ([[self audioDevices] count] > [self ringtoneOutputDeviceIndex]) {
            NSDictionary *ringtoneOutputDeviceDict = [self audioDevices][[self ringtoneOutputDeviceIndex]];
            [_ringtone setPlaybackDeviceIdentifier:ringtoneOutputDeviceDict[kAudioDeviceUID]];
            
        } else {
            [_ringtone setPlaybackDeviceIdentifier:nil];
        }
    }
}

- (BOOL)hasIncomingCallControllers {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        for (CallController *aCallController in [anAccountController callControllers]) {
            if ([[aCallController call] identifier] != kAKSIPUserAgentInvalidIdentifier &&
                [[aCallController call] isIncoming] &&
                [aCallController isCallActive] &&
                ([[aCallController call] state] == kAKSIPCallIncomingState ||
                 [[aCallController call] state] == kAKSIPCallEarlyState)) {
                    return YES;
                }
        }
    }
    
    return NO;
}

- (BOOL)hasActiveCallControllers {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        for (CallController *aCallController in [anAccountController callControllers]) {
            if ([aCallController isCallActive]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSArray *)currentNameservers {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleName = [mainBundle infoDictionary][@"CFBundleName"];
    
    SCDynamicStoreRef dynamicStore = SCDynamicStoreCreate(NULL, (__bridge CFStringRef)bundleName, NULL, NULL);
    
    CFPropertyListRef DNSSettings = SCDynamicStoreCopyValue(dynamicStore,
                                                            (__bridge CFStringRef)kDynamicStoreDNSSettings);
    
    NSArray *nameservers = nil;
    if (DNSSettings != NULL) {
        nameservers = ((__bridge NSDictionary *)DNSSettings)[@"ServerAddresses"];
        
        CFRelease(DNSSettings);
    }
    
    CFRelease(dynamicStore);
    
    return nameservers;
}

- (NSUInteger)unhandledIncomingCallsCount {
    NSUInteger count = 0;
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        for (CallController *aCallController in [anAccountController callControllers]) {
            if ([[aCallController call] isIncoming] && [aCallController isCallUnhandled]) {
                ++count;
            }
        }
    }
    
    return count;
}

+ (void)initialize {
    // Register defaults.
    static BOOL initialized = NO;
    
    if (!initialized) {
        NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
        
        defaultsDict[kUseDNSSRV] = @NO;
        defaultsDict[kOutboundProxyHost] = @"";
        defaultsDict[kOutboundProxyPort] = @0;
        defaultsDict[kSTUNServerHost] = @"";
        defaultsDict[kSTUNServerPort] = @0;
        defaultsDict[kVoiceActivityDetection] = @NO;
        defaultsDict[kUseICE] = @NO;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *applicationSupportURLs = [fileManager URLsForDirectory:NSApplicationSupportDirectory
                                                              inDomains:NSUserDomainMask];
        
        if ([applicationSupportURLs count] > 0) {
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSURL *applicationSupportURL = applicationSupportURLs[0];
            NSURL *logURL = [applicationSupportURL URLByAppendingPathComponent:bundleIdentifier];
            logURL = [logURL URLByAppendingPathComponent:@"Telephone.log"];
            
            defaultsDict[kLogFileName] = [logURL path];
        }
        
        defaultsDict[kLogLevel] = @3;
        defaultsDict[kConsoleLogLevel] = @0;
        defaultsDict[kTransportPort] = @0;
        defaultsDict[kTransportPublicHost] = @"";
        defaultsDict[kRingingSound] = @"Purr";
        defaultsDict[kSignificantPhoneNumberLength] = @10;
        defaultsDict[kPauseITunes] = @YES;
        defaultsDict[kAutoCloseCallWindow] = @NO;
        defaultsDict[kAutoCloseMissedCallWindow] = @NO;
        defaultsDict[kCallWaiting] = @YES;
        defaultsDict[kShowGrowlNotifications] = @NO;
        defaultsDict[kUseG711Only] = @NO;

        NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
        
        // Do not format phone numbers in German localization by default.
        if ([preferredLocalization isEqualToString:@"German"]) {
            defaultsDict[kFormatTelephoneNumbers] = @NO;
        } else {
            defaultsDict[kFormatTelephoneNumbers] = @YES;
        }
        
        // Split last four digits in Russian localization by default.
        if ([preferredLocalization isEqualToString:@"Russian"]) {
            defaultsDict[kTelephoneNumberFormatterSplitsLastFourDigits] = @YES;
        } else {
            defaultsDict[kTelephoneNumberFormatterSplitsLastFourDigits] = @NO;
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
        
        initialized = YES;
    }
}

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _userAgent = [AKSIPUserAgent sharedUserAgent];
    [[self userAgent] setDelegate:self];
    _accountControllers = [[NSMutableArray alloc] init];
    [self setSoundInputDeviceIndex:kAKSIPUserAgentInvalidIdentifier];
    [self setSoundOutputDeviceIndex:kAKSIPUserAgentInvalidIdentifier];
    [self setShouldSetUserAgentSoundIO:NO];
    [self setShouldRegisterAllAccounts:NO];
    [self setShouldRestartUserAgentASAP:NO];
    [self setTerminating:NO];
    [self setDidPauseITunes:NO];
    [self setShouldPresentUserAgentLaunchError:NO];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // Subscribe to the account setup notifications.
    [notificationCenter addObserver:self
                           selector:@selector(accountSetupControllerDidAddAccount:)
                               name:AKAccountSetupControllerDidAddAccountNotification
                             object:nil];
    
    // Subscribe to account notifications.
    [notificationCenter addObserver:self
                           selector:@selector(SIPAccountWillMakeCall:)
                               name:AKSIPAccountWillMakeCallNotification
                             object:nil];
    
    // Subscribe to Early and Confirmed call states to set sound IO to the user
    // agent.
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallCalling:)
                               name:AKSIPCallCallingNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallIncoming:)
                               name:AKSIPCallIncomingNotification
                             object:nil];
    
    // Subscribe to call disconnects.
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallDidDisconnect:)
                               name:AKSIPCallDidDisconnectNotification
                             object:nil];
    
    // Subscribe to username and password changes by the authentication failure
    // controllers.
    [notificationCenter addObserver:self
                           selector:@selector(authenticationFailureControllerDidChangeUsernameAndPassword:)
                               name:AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
                             object:nil];
    
    // Subscribe to NSWorkspace notifications about going computer to sleep,
    // waking up from sleep, switching user sesstion in and out.
    notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notificationCenter addObserver:self
                           selector:@selector(workspaceWillSleep:)
                               name:NSWorkspaceWillSleepNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(workspaceDidWake:)
                               name:NSWorkspaceDidWakeNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(workspaceSessionDidResignActive:)
                               name:NSWorkspaceSessionDidResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(workspaceSessionDidBecomeActive:)
                               name:NSWorkspaceSessionDidBecomeActiveNotification
                             object:nil];
    
    // Subscribe to Address Book plug-in notifications via NSDistributedNotificationCenter.
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    
    [distributedNotificationCenter addObserver:self
                                      selector:@selector(addressBookDidDialCallDestination:)
                                          name:AKAddressBookDidDialPhoneNumberNotification
                                        object:@"AddressBook"
                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    [distributedNotificationCenter addObserver:self
                                      selector:@selector(addressBookDidDialCallDestination:)
                                          name:AKAddressBookDidDialSIPAddressNotification
                                        object:@"AddressBook"
                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    
    // Register Apple event handler for the URLs support.
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    
    return self;
}

- (void)dealloc {
    if ([[_preferencesController delegate] isEqual:self]) {
        [_preferencesController setDelegate:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopUserAgent {
    // Force ended state for all calls and remove accounts from the user agent.
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        for (CallController *aCallController in [anAccountController callControllers]) {
            [aCallController hangUpCall];
        }
        
        [anAccountController removeAccountFromUserAgent];
    }
    
    [[self userAgent] stop];
}

- (void)restartUserAgent {
    if ([[self userAgent] state] > kAKSIPUserAgentStopped) {
        [self setShouldRegisterAllAccounts:YES];
        [self setShouldSetUserAgentSoundIO:YES];
        [self stopUserAgent];
    }
}

- (void)updateAudioDevices {
    OSStatus err = noErr;
    UInt32 size = 0;
    NSUInteger i = 0;
    AudioBufferList *theBufferList = NULL;
    
    NSMutableArray *devicesArray = [NSMutableArray array];
    
    // Fetch a pointer to the list of available devices.
    AudioObjectID *devices = NULL;
    UInt16 devicesCount = 0;
    err = GetAudioDevices((Ptr *)&devices, &devicesCount);
    if (err != noErr) {
        return;
    }
    
    // Iterate over each device gathering information.
    for (NSUInteger loopCount = 0; loopCount < devicesCount; ++loopCount) {
        NSMutableDictionary *deviceDict = [NSMutableDictionary dictionary];
        
        // Get device identifier.
        NSUInteger deviceIdentifier = devices[loopCount];
        deviceDict[kAudioDeviceIdentifier] = @(deviceIdentifier);
        
        AudioObjectPropertyAddress address = { kAudioDevicePropertyDeviceUID,
                                               kAudioObjectPropertyScopeGlobal,
                                               kAudioObjectPropertyElementMaster };

        // Get device UID.
        CFStringRef UIDStringRef = NULL;
        size = sizeof(UIDStringRef);
        err = AudioObjectGetPropertyData(devices[loopCount], &address, 0, NULL, &size, &UIDStringRef);
        if ((err == noErr) && (UIDStringRef != NULL)) {
            deviceDict[kAudioDeviceUID] = (__bridge NSString *)UIDStringRef;
            CFRelease(UIDStringRef);
        }

        // Get device name.
        CFStringRef nameStringRef = NULL;
        address.mSelector = kAudioObjectPropertyName;
        address.mScope = kAudioObjectPropertyScopeGlobal;
        address.mElement = kAudioObjectPropertyElementMaster;
        size = sizeof(CFStringRef);
        err = AudioObjectGetPropertyData(devices[loopCount], &address, 0, NULL, &size, &nameStringRef);
        if ((err == noErr) && (nameStringRef != NULL)) {
            deviceDict[kAudioDeviceName] = (__bridge  NSString *)nameStringRef;
            CFRelease(nameStringRef);
        }
        
        // Get transport type and set built-in flag.
        UInt32 transportType = 0;
        address.mSelector = kAudioDevicePropertyTransportType;
        address.mScope = kAudioObjectPropertyScopeGlobal;
        address.mElement = kAudioObjectPropertyElementMaster;
        size = sizeof(UInt32);
        err = AudioObjectGetPropertyData(devices[loopCount], &address, 0, NULL, &size, &transportType);
        if (err == noErr) {
            deviceDict[kAudioDeviceBuiltIn] = transportType == kAudioDeviceTransportTypeBuiltIn ? @YES : @NO;
        }
        
        // Get number of input channels.
        size = 0;
        NSUInteger inputChannelsCount = 0;
        address.mSelector = kAudioDevicePropertyStreamConfiguration;
        address.mScope = kAudioObjectPropertyScopeInput;
        address.mElement = 0;
        err = AudioObjectGetPropertyDataSize(devices[loopCount], &address, 0, NULL, &size);
        if ((err == noErr) && (size != 0)) {
            theBufferList = (AudioBufferList *)malloc(size);
            if (theBufferList != NULL) {
                // Get the input stream configuration.
                err = AudioObjectGetPropertyData(devices[loopCount], &address, 0, NULL, &size, theBufferList);
                if (err == noErr) {
                    // Count the total number of input channels in the stream.
                    for (i = 0; i < theBufferList->mNumberBuffers; ++i) {
                        inputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
                    }
                }
                free(theBufferList);
                
                deviceDict[kAudioDeviceInputsCount] = @(inputChannelsCount);
            }
        }
        
        // Get number of output channels.
        size = 0;
        NSUInteger outputChannelsCount = 0;
        address.mSelector = kAudioDevicePropertyStreamConfiguration;
        address.mScope = kAudioObjectPropertyScopeOutput;
        address.mElement = 0;
        err = AudioObjectGetPropertyDataSize(devices[loopCount], &address, 0, NULL, &size);
        if((err == noErr) && (size != 0)) {
            theBufferList = (AudioBufferList *)malloc(size);
            if (theBufferList != NULL) {
                // Get the input stream configuration.
                err = AudioObjectGetPropertyData(devices[loopCount], &address, 0, NULL, &size, theBufferList);
                if(err == noErr) {
                    // Count the total number of output channels in the stream.
                    for (i = 0; i < theBufferList->mNumberBuffers; ++i) {
                        outputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
                    }
                }
                free(theBufferList);
                
                deviceDict[kAudioDeviceOutputsCount] = @(outputChannelsCount);
            }
        }
        
        [devicesArray addObject:deviceDict];
    }
    
    free(devices);
    
    [self setAudioDevices:[devicesArray copy]];
    
    // Update audio devices in the user agent.
    [[self userAgent] performSelectorOnMainThread:@selector(updateAudioDevices) withObject:nil waitUntilDone:YES];
    
    // Select sound IO from the updated audio devices list.
    // This method will change sound IO in the user agent if there are active
    // calls.
    [self performSelectorOnMainThread:@selector(selectSoundIO) withObject:nil waitUntilDone:YES];
    
    // Update audio devices in preferences.
    [[[self preferencesController] soundPreferencesViewController]
     performSelectorOnMainThread:@selector(updateAudioDevices)
                      withObject:nil
                   waitUntilDone:NO];
}

// Selects appropriate sound IO from the list of available audio devices.
//
// Searches the defaults database for devices selected earlier. If not found, uses first built-in matched. If that is
// not found, uses the first device.
//
// Selects sound IO in the user agent if there are active calls.
- (void)selectSoundIO {
    NSArray *devices = [self audioDevices];
    NSInteger newSoundInput, newSoundOutput, newRingtoneOutput;
    newSoundInput = newSoundOutput = newRingtoneOutput = NSNotFound;
    NSInteger firstBuiltInInput, firstBuiltInOutput;
    firstBuiltInInput = firstBuiltInOutput = NSNotFound;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastSoundInputString = [defaults stringForKey:kSoundInput];
    NSString *lastSoundOutputString = [defaults stringForKey:kSoundOutput];
    NSString *lastRingtoneOutputString = [defaults stringForKey:kRingtoneOutput];
    NSUInteger deviceCount = [devices count];
    
    for (NSUInteger i = 0; i < deviceCount; i++) {
        if (newSoundInput != NSNotFound && newSoundOutput != NSNotFound && newRingtoneOutput != NSNotFound &&
            firstBuiltInInput != NSNotFound && firstBuiltInOutput != NSNotFound) {
            break;
        }
        NSDictionary *device = devices[i];
        if ([device[kAudioDeviceInputsCount] unsignedIntegerValue] > 0) {
            if (newSoundInput == NSNotFound && [device[kAudioDeviceName] isEqualToString:lastSoundInputString]) {
                newSoundInput = i;
            }
            if (firstBuiltInInput == NSNotFound && [device[kAudioDeviceBuiltIn] boolValue]) {
                firstBuiltInInput = i;
            }
        }
        if ([device[kAudioDeviceOutputsCount] unsignedIntegerValue] > 0) {
            if (newSoundOutput == NSNotFound && [device[kAudioDeviceName] isEqualToString:lastSoundOutputString]) {
                newSoundOutput = i;
            }
            if (newRingtoneOutput == NSNotFound && [device[kAudioDeviceName] isEqualToString:lastRingtoneOutputString]) {
                newRingtoneOutput = i;
            }
            if (firstBuiltInOutput == NSNotFound && [device[kAudioDeviceBuiltIn] boolValue]) {
                firstBuiltInOutput = i;
            }
        }
    }
    
    if (newSoundInput == NSNotFound) {
        newSoundInput = (firstBuiltInInput != NSNotFound) ? firstBuiltInInput : 0;
    }
    if (newSoundOutput == NSNotFound) {
        newSoundOutput = (firstBuiltInOutput != NSNotFound) ? firstBuiltInOutput : 0;
    }
    if (newRingtoneOutput == NSNotFound) {
        newRingtoneOutput = (firstBuiltInOutput != NSNotFound) ? firstBuiltInOutput : 0;
    }
    
    [self setSoundInputDeviceIndex:newSoundInput];
    [self setSoundOutputDeviceIndex:newSoundOutput];
    [self setRingtoneOutputDeviceIndex:newRingtoneOutput];
    
    // Set selected sound IO to the user agent if there are active calls.
    if ([[self userAgent] activeCallsCount] > 0) {
        [self setSelectedSoundIOToUserAgent];
    } else {
        [self setShouldSetUserAgentSoundIO:YES];
    }

    // Set selected ringtone output.
    [[self ringtone] setPlaybackDeviceIdentifier:devices[newRingtoneOutput][kAudioDeviceUID]];
}

- (void)setSelectedSoundIOToUserAgent {
    [[self userAgent] setSoundInputDevice:[self soundInputDeviceIndex] soundOutputDevice:[self soundOutputDeviceIndex]];
}

- (IBAction)showPreferencePanel:(id)sender {
    if (![[[self preferencesController] window] isVisible]) {
        [[[self preferencesController] window] center];
    }
    
    [[self preferencesController] showWindow:nil];
}

- (IBAction)addAccountOnFirstLaunch:(id)sender {
    [[self accountSetupController] addAccount:sender];
    
    if ([[[[self accountSetupController] fullNameField] stringValue] length] > 0 &&
        [[[[self accountSetupController] domainField] stringValue] length] > 0 &&
        [[[[self accountSetupController] usernameField] stringValue] length] > 0 &&
        [[[[self accountSetupController] passwordField] stringValue] length] > 0) {
        // Re-enable Preferences.
        [[self preferencesMenuItem] setAction:@selector(showPreferencePanel:)];
        
        // Change back targets and actions of addAccountWindow buttons.
        [[[self accountSetupController] defaultButton] setTarget:[self accountSetupController]];
        [[[self accountSetupController] defaultButton] setAction:@selector(addAccount:)];
        [[[self accountSetupController] otherButton] setTarget:[self accountSetupController]];
        [[[self accountSetupController] otherButton] setAction:@selector(closeSheet:)];
        
        // Install audio devices changes callback.
        [self subscribeToAudioDeviceChanges];
        
        // Get available audio devices, select devices for sound input and output.
        [self updateAudioDevices];
        
        // If we want to be in Mac App Store, we can't write to |~/Library/ Address Book Plug-Ins| any more.
        //
        // [self installAddressBookPlugIns];
        
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        [GrowlApplicationBridge setGrowlDelegate:self];
        [self installDNSChangesCallback];
    }
}

- (void)startRingtoneTimer {
    if ([self ringtoneTimer] != nil) {
        [[self ringtoneTimer] invalidate];
    }
    
    [self setRingtoneTimer:[NSTimer scheduledTimerWithTimeInterval:kRingtoneInterval
                                                            target:self
                                                          selector:@selector(ringtoneTimerTick:)
                                                          userInfo:nil
                                                           repeats:YES]];
}

- (void)stopRingtoneTimerIfNeeded {
    if (![self hasIncomingCallControllers] && [self ringtoneTimer] != nil) {
        [[self ringtone] stop];
        [[self ringtoneTimer] invalidate];
        [self setRingtoneTimer:nil];
    }
}

- (void)ringtoneTimerTick:(NSTimer *)theTimer {
    [[self ringtone] play];
}

- (void)startUserAttentionTimer {
    if ([self userAttentionTimer] != nil) {
        [[self userAttentionTimer] invalidate];
    }
    
    [self setUserAttentionTimer:[NSTimer scheduledTimerWithTimeInterval:kUserAttentionRequestInterval
                                                                 target:self
                                                               selector:@selector(requestUserAttentionTick:)
                                                               userInfo:nil
                                                                repeats:YES]];
}

- (void)stopUserAttentionTimerIfNeeded {
    if (![self hasIncomingCallControllers] && [self userAttentionTimer] != nil) {
        [[self userAttentionTimer] invalidate];
        [self setUserAttentionTimer:nil];
    }
}

- (void)requestUserAttentionTick:(NSTimer *)theTimer {
    [NSApp requestUserAttention:NSInformationalRequest];
}


- (void)pauseITunes {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPauseITunes]) {
        return;
    }
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if (![iTunes isRunning]) {
        return;
    }
    
    if ([iTunes playerState] == iTunesEPlSPlaying) {
        [iTunes pause];
        [self setDidPauseITunes:YES];
    }
}

- (void)resumeITunesIfNeeded {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPauseITunes]) {
        return;
    }
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if (![iTunes isRunning]) {
        return;
    }
    
    if ([self didPauseITunes] && ![self hasActiveCallControllers]) {
        if ([iTunes playerState] == iTunesEPlSPaused) {
            [[iTunes currentTrack] playOnce:NO];
        }
        
        [self setDidPauseITunes:NO];
    }
}

- (CallController *)callControllerByIdentifier:(NSString *)identifier {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        for (CallController *aCallController in [anAccountController callControllers]) {
            if ([[aCallController identifier] isEqualToString:identifier]) {
                return aCallController;
            }
        }
    }
    
    return nil;
}

- (void)updateAccountsMenuItems {
    // Remove old menu items.
    for (NSMenuItem *menuItem in [self accountsMenuItems]) {
        [[self windowMenu] removeItem:menuItem];
    }
    
    // Create new menu items.
    NSArray *enabledControllers = [self enabledAccountControllers];
    NSMutableArray *itemsArray = [NSMutableArray arrayWithCapacity:[enabledControllers count]];
    NSUInteger accountNumber = 1;
    for (AccountController *accountController in enabledControllers) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        [menuItem setRepresentedObject:accountController];
        [menuItem setAction:@selector(toggleAccountWindow:)];
        [menuItem setTitle:[accountController accountDescription]];
        if (accountNumber < 10) {
            // Only add key equivalents for Command-[1..9].
            [menuItem setKeyEquivalent:[NSString stringWithFormat:@"%lu", accountNumber]];
        }
        [itemsArray addObject:menuItem];
        accountNumber++;
    }
    if ([itemsArray count] > 0) {
        [itemsArray insertObject:[NSMenuItem separatorItem] atIndex:0];
        [self setAccountsMenuItems:itemsArray];
    } else {
        [self setAccountsMenuItems:nil];
    }
    
    // Add menu items to the Window menu.
    NSUInteger itemTag = 4;
    for (NSMenuItem *menuItem in itemsArray) {
        [[self windowMenu] insertItem:menuItem atIndex:itemTag];
        itemTag++;
    }
}

- (IBAction)toggleAccountWindow:(id)sender {
    AccountController *accountController = [sender representedObject];
    if ([[accountController window] isKeyWindow]) {
        [[accountController window] performClose:self];
    } else {
        [[accountController window] makeKeyAndOrderFront:self];
    }
}

- (void)updateDockTileBadgeLabel {
    NSString *badgeString;
    NSUInteger badgeNumber = [self unhandledIncomingCallsCount];
    if (badgeNumber == 0) {
        badgeString = @"";
    } else {
        badgeString = [NSString stringWithFormat:@"%lu", badgeNumber];
    }
    
    [[NSApp dockTile] setBadgeLabel:badgeString];
}

- (void)installAddressBookPlugIns {
    NSError *error = nil;
    BOOL installed = [self installAddressBookPlugInsAndReturnError:&error];
    if (!installed && error != nil) {
        NSLog(@"%@", error);
        
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, NO)[0];
        
        if ([libraryPath length] > 0) {
            NSString *addressBookPlugInsInstallPath
              = [libraryPath stringByAppendingPathComponent:@"Address Book Plug-Ins"];
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Could not install Address Book plug-ins.",
                                                    @"Address Book plug-ins install error, alert "
                                                     "message text.")];
            [alert setInformativeText:[NSString stringWithFormat:
                                       NSLocalizedString(@"Make sure you have write permission to "
                                                          "\\U201C%@\\U201D.",
                                                         @"Address Book plug-ins install error, alert "
                                                          "informative text."),
                                       addressBookPlugInsInstallPath]];
            
            [alert runModal];
        }
    }
}

- (void)installDNSChangesCallback {
    NSString *bundleName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    SCDynamicStoreRef dynamicStore = SCDynamicStoreCreate(kCFAllocatorDefault,
                                                          (__bridge CFStringRef)bundleName,
                                                          &NameserversChanged,
                                                          NULL);
    
    NSArray *keys = @[kDynamicStoreDNSSettings];
    SCDynamicStoreSetNotificationKeys(dynamicStore, (__bridge CFArrayRef)keys, NULL);
    
    CFRunLoopSourceRef runLoopSource = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, dynamicStore, 0);
    
    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoopSource);
    CFRelease(dynamicStore);
}

- (void)createDirectoryForFileAtPath:(NSString *)path {
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:directoryPath
                                    isDirectory:NULL];
    if (!exists) {
        NSError *error = nil;
        BOOL created = [fileManager createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        if (!created) {
            NSLog(@"Error creating directory %@. %@",
                  directoryPath, [error localizedDescription]);
        }
    }
}

- (void)updateCallsShouldDisplayAccountInfo {
    NSUInteger enabledCount = [self.enabledAccountControllers count];
    BOOL shouldDisplay = enabledCount > 1;
    for (AccountController *accountController in self.accountControllers) {
        accountController.callsShouldDisplayAccountInfo = shouldDisplay;
    }
}

- (void)subscribeToAudioDeviceChanges {
    AudioObjectPropertyAddress address = { kAudioHardwarePropertyDevices,
                                           kAudioObjectPropertyScopeGlobal,
                                           kAudioObjectPropertyElementMaster };
    
    AudioObjectAddPropertyListener(kAudioObjectSystemObject, &address, &AudioDevicesChanged, (__bridge void *)self);
}

- (BOOL)installAddressBookPlugInsAndReturnError:(NSError **)error {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *plugInsPath = [mainBundle builtInPlugInsPath];
    
    NSString *phonePlugInPath = [plugInsPath stringByAppendingPathComponent:@"TelephoneAddressBookPhonePlugIn.bundle"];
    NSString *SIPAddressPlugInPath = [plugInsPath stringByAppendingPathComponent:
                                      @"TelephoneAddressBookSIPAddressPlugIn.bundle"];
    
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([libraryPaths count] == 0) {
        return NO;
    }
    
    NSString *installPath = [libraryPaths[0] stringByAppendingPathComponent:@"Address Book Plug-Ins"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create |~/Library/Address Book Plug-Ins| if needed.
    BOOL isDir;
    BOOL pathExists = [fileManager fileExistsAtPath:installPath isDirectory:&isDir];
    if (!pathExists) {
        BOOL created = [fileManager createDirectoryAtPath:installPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:error];
        if (!created) {
            return NO;
        }
        
    } else if (!isDir) {
        NSLog(@"%@ is not a directory", installPath);
        return NO;
    }
    
    
    NSBundle *phonePlugInBundle = [NSBundle bundleWithPath:phonePlugInPath];
    NSInteger phonePlugInVersion = [[phonePlugInBundle infoDictionary][@"CFBundleVersion"] integerValue];
    NSString *phonePlugInInstallPath = [installPath stringByAppendingPathComponent:[phonePlugInPath lastPathComponent]];
    NSBundle *installedPhonePlugInBundle = [NSBundle bundleWithPath:phonePlugInInstallPath];
    
    BOOL shouldInstallPhonePlugIn = YES;
    if (installedPhonePlugInBundle != nil) {
        NSInteger installedPhonePlugInVersion = [[installedPhonePlugInBundle infoDictionary][@"CFBundleVersion"] integerValue];
        
        // Remove the old plug-in version if it needs updating.
        if (installedPhonePlugInVersion < phonePlugInVersion) {
            BOOL removed = [fileManager removeItemAtPath:phonePlugInInstallPath error:error];
            if (!removed) {
                return NO;
            }
        } else {
            // Don't copy the new version if it's not newer.
            shouldInstallPhonePlugIn = NO;
        }
    }
    
    NSBundle *SIPAddressPlugInBundle = [NSBundle bundleWithPath:SIPAddressPlugInPath];
    NSInteger SIPAddressPlugInVersion = [[SIPAddressPlugInBundle infoDictionary][@"CFBundleVersion"] integerValue];
    NSString *SIPAddressPlugInInstallPath = [installPath stringByAppendingPathComponent:
                                             [SIPAddressPlugInPath lastPathComponent]];
    NSBundle *installedSIPAddressPlugInBundle = [NSBundle bundleWithPath:SIPAddressPlugInInstallPath];
    
    BOOL shouldInstallSIPAddressPlugIn = YES;
    if (installedSIPAddressPlugInBundle != nil) {
        NSInteger installedSIPAddressPlugInVersion = [[installedSIPAddressPlugInBundle infoDictionary][@"CFBundleVersion"] integerValue];
        
        // Remove the old plug-in version if it needs updating.
        if (installedSIPAddressPlugInVersion < SIPAddressPlugInVersion) {
            BOOL removed = [fileManager removeItemAtPath:SIPAddressPlugInInstallPath error:error];
            if (!removed) {
                return NO;
            }
        } else {
            // Don't copy the new version if it's not newer.
            shouldInstallSIPAddressPlugIn = NO;
        }
    }
    
    BOOL installed;
    
    if (shouldInstallPhonePlugIn) {
        installed = [fileManager copyItemAtPath:phonePlugInPath toPath:phonePlugInInstallPath error:error];
        if (!installed) {
            return NO;
        }
    }
    
    if (shouldInstallSIPAddressPlugIn) {
        installed = [fileManager copyItemAtPath:SIPAddressPlugInPath toPath:SIPAddressPlugInInstallPath error:error];
        if (!installed) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode {
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
            localizedString = NSLocalizedStringFromTable(@"Call Is Being Forwarded",
                                                         @"SIPResponses",
                                                         @"181 Call Is Being Forwarded.");
            break;
        case PJSIP_SC_QUEUED:
            localizedString = NSLocalizedStringFromTable(@"Queued", @"SIPResponses", @"182 Queued.");
            break;
        case PJSIP_SC_PROGRESS:
            localizedString
                = NSLocalizedStringFromTable(@"Session Progress", @"SIPResponses", @"183 Session Progress.");
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
            localizedString
                = NSLocalizedStringFromTable(@"Multiple Choices", @"SIPResponses", @"300 Multiple Choices.");
            break;
        case PJSIP_SC_MOVED_PERMANENTLY:
            localizedString
                = NSLocalizedStringFromTable(@"Moved Permanently", @"SIPResponses", @"301 Moved Permanently.");
            break;
        case PJSIP_SC_MOVED_TEMPORARILY:
            localizedString
                = NSLocalizedStringFromTable(@"Moved Temporarily", @"SIPResponses", @"302 Moved Temporarily.");
            break;
        case PJSIP_SC_USE_PROXY:
            localizedString = NSLocalizedStringFromTable(@"Use Proxy", @"SIPResponses", @"305 Use Proxy.");
            break;
        case PJSIP_SC_ALTERNATIVE_SERVICE:
            localizedString
                = NSLocalizedStringFromTable(@"Alternative Service", @"SIPResponses", @"380 Alternative Service.");
            break;
            
            // Request Failure 4xx.
        case PJSIP_SC_BAD_REQUEST:
            localizedString = NSLocalizedStringFromTable(@"Bad Request", @"SIPResponses", @"400 Bad Request.");
            break;
        case PJSIP_SC_UNAUTHORIZED:
            localizedString = NSLocalizedStringFromTable(@"Unauthorized", @"SIPResponses", @"401 Unauthorized.");
            break;
        case PJSIP_SC_PAYMENT_REQUIRED:
            localizedString
                = NSLocalizedStringFromTable(@"Payment Required", @"SIPResponses", @"402 Payment Required.");
            break;
        case PJSIP_SC_FORBIDDEN:
            localizedString = NSLocalizedStringFromTable(@"Forbidden", @"SIPResponses", @"403 Forbidden.");
            break;
        case PJSIP_SC_NOT_FOUND:
            localizedString = NSLocalizedStringFromTable(@"Not Found", @"SIPResponses", @"404 Not Found.");
            break;
        case PJSIP_SC_METHOD_NOT_ALLOWED:
            localizedString
                = NSLocalizedStringFromTable(@"Method Not Allowed", @"SIPResponses", @"405 Method Not Allowed.");
            break;
        case PJSIP_SC_NOT_ACCEPTABLE:
            localizedString = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses", @"406 Not Acceptable.");
            break;
        case PJSIP_SC_PROXY_AUTHENTICATION_REQUIRED:
            localizedString = NSLocalizedStringFromTable(@"Proxy Authentication Required",
                                                         @"SIPResponses",
                                                         @"407 Proxy Authentication Required.");
            break;
        case PJSIP_SC_REQUEST_TIMEOUT:
            localizedString = NSLocalizedStringFromTable(@"Request Timeout", @"SIPResponses", @"408 Request Timeout.");
            break;
        case PJSIP_SC_GONE:
            localizedString = NSLocalizedStringFromTable(@"Gone", @"SIPResponses", @"410 Gone.");
            break;
        case PJSIP_SC_REQUEST_ENTITY_TOO_LARGE:
            localizedString = NSLocalizedStringFromTable(@"Request Entity Too Large",
                                                         @"SIPResponses",
                                                         @"413 Request Entity Too Large.");
            break;
        case PJSIP_SC_REQUEST_URI_TOO_LONG:
            localizedString
                = NSLocalizedStringFromTable(@"Request-URI Too Long", @"SIPResponses", @"414 Request-URI Too Long.");
            break;
        case PJSIP_SC_UNSUPPORTED_MEDIA_TYPE:
            localizedString = NSLocalizedStringFromTable(@"Unsupported Media Type",
                                                         @"SIPResponses",
                                                         @"415 Unsupported Media Type.");
            break;
        case PJSIP_SC_UNSUPPORTED_URI_SCHEME:
            localizedString = NSLocalizedStringFromTable(@"Unsupported URI Scheme",
                                                         @"SIPResponses",
                                                         @"416 Unsupported URI Scheme.");
            break;
        case PJSIP_SC_BAD_EXTENSION:
            localizedString = NSLocalizedStringFromTable(@"Bad Extension", @"SIPResponses", @"420 Bad Extension.");
            break;
        case PJSIP_SC_EXTENSION_REQUIRED:
            localizedString
                = NSLocalizedStringFromTable(@"Extension Required", @"SIPResponses", @"421 Extension Required.");
            break;
        case PJSIP_SC_SESSION_TIMER_TOO_SMALL:
            localizedString = NSLocalizedStringFromTable(@"Session Timer Too Small",
                                                         @"SIPResponses",
                                                         @"422 Session Timer Too Small.");
            break;
        case PJSIP_SC_INTERVAL_TOO_BRIEF:
            localizedString
                = NSLocalizedStringFromTable(@"Interval Too Brief", @"SIPResponses", @"423 Interval Too Brief.");
            break;
        case PJSIP_SC_TEMPORARILY_UNAVAILABLE:
            localizedString = NSLocalizedStringFromTable(@"Temporarily Unavailable",
                                                        @"SIPResponses",
                                                         @"480 Temporarily Unavailable.");
            break;
        case PJSIP_SC_CALL_TSX_DOES_NOT_EXIST:
            localizedString = NSLocalizedStringFromTable(@"Call/Transaction Does Not Exist",
                                                         @"SIPResponses",
                                                         @"481 Call/Transaction Does Not Exist.");
            break;
        case PJSIP_SC_LOOP_DETECTED:
            localizedString = NSLocalizedStringFromTable(@"Loop Detected", @"SIPResponses", @"482 Loop Detected.");
            break;
        case PJSIP_SC_TOO_MANY_HOPS:
            localizedString = NSLocalizedStringFromTable(@"Too Many Hops", @"SIPResponses", @"483 Too Many Hops.");
            break;
        case PJSIP_SC_ADDRESS_INCOMPLETE:
            localizedString
                = NSLocalizedStringFromTable(@"Address Incomplete", @"SIPResponses", @"484 Address Incomplete.");
            break;
        case PJSIP_AC_AMBIGUOUS:
            localizedString = NSLocalizedStringFromTable(@"Ambiguous", @"SIPResponses", @"485 Ambiguous.");
            break;
        case PJSIP_SC_BUSY_HERE:
            localizedString = NSLocalizedStringFromTable(@"Busy Here", @"SIPResponses", @"486 Busy Here.");
            break;
        case PJSIP_SC_REQUEST_TERMINATED:
            localizedString
                = NSLocalizedStringFromTable(@"Request Terminated", @"SIPResponses", @"487 Request Terminated.");
            break;
        case PJSIP_SC_NOT_ACCEPTABLE_HERE:
            localizedString
                = NSLocalizedStringFromTable(@"Not Acceptable Here", @"SIPResponses", @"488 Not Acceptable Here.");
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
            localizedString
                = NSLocalizedStringFromTable(@"Server Internal Error", @"SIPResponses", @"500 Server Internal Error.");
            break;
        case PJSIP_SC_NOT_IMPLEMENTED:
            localizedString = NSLocalizedStringFromTable(@"Not Implemented", @"SIPResponses", @"501 Not Implemented.");
            break;
        case PJSIP_SC_BAD_GATEWAY:
            localizedString = NSLocalizedStringFromTable(@"Bad Gateway", @"SIPResponses", @"502 Bad Gateway.");
            break;
        case PJSIP_SC_SERVICE_UNAVAILABLE:
            localizedString
                = NSLocalizedStringFromTable(@"Service Unavailable", @"SIPResponses", @"503 Service Unavailable.");
            break;
        case PJSIP_SC_SERVER_TIMEOUT:
            localizedString = NSLocalizedStringFromTable(@"Server Time-out", @"SIPResponses", @"504 Server Time-out.");
            break;
        case PJSIP_SC_VERSION_NOT_SUPPORTED:
            localizedString
                = NSLocalizedStringFromTable(@"Version Not Supported", @"SIPResponses", @"505 Version Not Supported.");
            break;
        case PJSIP_SC_MESSAGE_TOO_LARGE:
            localizedString
                = NSLocalizedStringFromTable(@"Message Too Large", @"SIPResponses", @"513 Message Too Large.");
            break;
        case PJSIP_SC_PRECONDITION_FAILURE:
            localizedString
                = NSLocalizedStringFromTable(@"Precondition Failure", @"SIPResponses", @"580 Precondition Failure.");
            break;
            
            // Global Failures 6xx.
        case PJSIP_SC_BUSY_EVERYWHERE:
            localizedString = NSLocalizedStringFromTable(@"Busy Everywhere", @"SIPResponses", @"600 Busy Everywhere.");
            break;
        case PJSIP_SC_DECLINE:
            localizedString = NSLocalizedStringFromTable(@"Decline", @"SIPResponses", @"603 Decline.");
            break;
        case PJSIP_SC_DOES_NOT_EXIST_ANYWHERE:
            localizedString = NSLocalizedStringFromTable(@"Does Not Exist Anywhere",
                                                         @"SIPResponses",
                                                         @"604 Does Not Exist Anywhere.");
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
#pragma mark AccountSetupController delegate

- (void)accountSetupControllerDidAddAccount:(NSNotification *)notification {
    NSDictionary *accountDict = [notification userInfo];
    
    NSString *SIPAddress = [NSString stringWithFormat:@"%@@%@", accountDict[kUsername], accountDict[kDomain]];
    
    AKSIPAccount *account = [AKSIPAccount SIPAccountWithFullName:accountDict[kFullName]
                                                      SIPAddress:SIPAddress
                                                       registrar:accountDict[kDomain]
                                                           realm:accountDict[kRealm]
                                                        username:accountDict[kUsername]];
    
    AccountController *theAccountController = [[AccountController alloc] initWithSIPAccount:account];
    
    [theAccountController setAccountDescription:[[theAccountController account] SIPAddress]];
    [[theAccountController window] setExcludedFromWindowsMenu:YES];
    [theAccountController setEnabled:YES];
    
    [[self accountControllers] addObject:theAccountController];
    [self updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
    
    [[theAccountController window] orderFront:self];
    
    // We need to register accounts with IP address as registrar manually.
    if ([[[theAccountController account] registrar] ak_isIPAddress] &&
        [[theAccountController registrarReachability] isReachable]) {
        
        [theAccountController setAttemptingToRegisterAccount:YES];
        [theAccountController setAccountRegistered:YES];
    }
}


#pragma mark -
#pragma mark PreferencesController delegate

- (void)preferencesControllerDidRemoveAccount:(NSNotification *)notification {
    NSInteger index = [[notification userInfo][kAccountIndex] integerValue];
    AccountController *anAccountController = [self accountControllers][index];
    
    if ([anAccountController isEnabled]) {
        [anAccountController removeAccountFromUserAgent];
    }
    
    [[self accountControllers] removeObjectAtIndex:index];
    [self updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
}

- (void)preferencesControllerDidChangeAccountEnabled:(NSNotification *)notification {
    NSUInteger index = [[notification userInfo][kAccountIndex] integerValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
    NSDictionary *accountDict = savedAccounts[index];
    
    BOOL isEnabled = [accountDict[kAccountEnabled] boolValue];
    if (isEnabled) {
        NSString *SIPAddress;
        if ([accountDict[kSIPAddress] length] > 0) {
            SIPAddress = accountDict[kSIPAddress];
        } else {
            SIPAddress = [NSString stringWithFormat:@"%@@%@", accountDict[kUsername], accountDict[kDomain]];
        }
        
        NSString *registrar;
        if ([accountDict[kRegistrar] length] > 0) {
            registrar = accountDict[kRegistrar];
        } else {
            registrar = accountDict[kDomain];
        }
        
        AKSIPAccount *account = [AKSIPAccount SIPAccountWithFullName:accountDict[kFullName]
                                                          SIPAddress:SIPAddress
                                                           registrar:registrar
                                                               realm:accountDict[kRealm]
                                                            username:accountDict[kUsername]];
        
        account.reregistrationTime = [accountDict[kReregistrationTime] integerValue];
        if ([accountDict[kUseProxy] boolValue]) {
            account.proxyHost = accountDict[kProxyHost];
            account.proxyPort = [accountDict[kProxyPort] integerValue];
        }
        account.updatesContactHeader = [accountDict[kUpdateContactHeader] boolValue];
        account.updatesViaHeader = [accountDict[kUpdateViaHeader] boolValue];
        
        AccountController *theAccountController = [[AccountController alloc] initWithSIPAccount:account];
        
        [[theAccountController window] setExcludedFromWindowsMenu:YES];
        
        NSString *description = accountDict[kDescription];
        if ([description length] == 0) {
            description = SIPAddress;
        }
        [theAccountController setAccountDescription:description];
        
        [theAccountController setAccountUnavailable:NO];
        [theAccountController setEnabled:YES];
        [theAccountController setSubstitutesPlusCharacter:[accountDict[kSubstitutePlusCharacter] boolValue]];
        [theAccountController setPlusCharacterSubstitution:accountDict[kPlusCharacterSubstitutionString]];
        
        [self accountControllers][index] = theAccountController;
        
        [[theAccountController window] orderFront:nil];
        
        // We need to register accounts with IP address as registrar manually.
        if ([[[theAccountController account] registrar] ak_isIPAddress] &&
            [[theAccountController registrarReachability] isReachable]) {
            
            [theAccountController setAttemptingToRegisterAccount:YES];
            [theAccountController setAccountRegistered:YES];
        }
        
    } else {
        AccountController *theAccountController = [self accountControllers][index];
        
        // Close all call windows hanging up all calls.
        [[theAccountController callControllers] makeObjectsPerformSelector:@selector(close)];
        
        // Remove account from the user agent.
        [theAccountController removeAccountFromUserAgent];
        [theAccountController setEnabled:NO];
        [theAccountController setAttemptingToRegisterAccount:NO];
        [theAccountController setAttemptingToUnregisterAccount:NO];
        [theAccountController setShouldPresentRegistrationError:NO];
        [[theAccountController window] orderOut:nil];
        
        // Prevent conflict with setFrameAutosaveName: when re-enabling the account.
        [theAccountController setWindow:nil];
    }
    
    [self updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
}

- (void)preferencesControllerDidSwapAccounts:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSInteger sourceIndex = [userInfo[kSourceIndex] integerValue];
    NSInteger destinationIndex = [userInfo[kDestinationIndex] integerValue];
    
    if (sourceIndex == destinationIndex) {
        return;
    }
    
    [[self accountControllers] insertObject:[self accountControllers][sourceIndex] atIndex:destinationIndex];
    if (sourceIndex < destinationIndex) {
        [[self accountControllers] removeObjectAtIndex:sourceIndex];
    } else if (sourceIndex > destinationIndex) {
        [[self accountControllers] removeObjectAtIndex:(sourceIndex + 1)];
    }
    
    [self updateAccountsMenuItems];
}

- (void)preferencesControllerDidChangeNetworkSettings:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[self userAgent] setTransportPort:[defaults integerForKey:kTransportPort]];
    [[self userAgent] setSTUNServerHost:[defaults stringForKey:kSTUNServerHost]];
    [[self userAgent] setSTUNServerPort:[defaults integerForKey:kSTUNServerPort]];
    [[self userAgent] setUsesICE:[defaults boolForKey:kUseICE]];
    [[self userAgent] setOutboundProxyHost:[defaults stringForKey:kOutboundProxyHost]];
    [[self userAgent] setOutboundProxyPort:[defaults integerForKey:kOutboundProxyPort]];
    
    if ([defaults boolForKey:kUseDNSSRV]) {
        [[self userAgent] setNameservers:[self currentNameservers]];
    } else {
        [[self userAgent] setNameservers:nil];
    }
    
    // Restart SIP user agent.
    if ([[self userAgent] isStarted]) {
        [self setShouldPresentUserAgentLaunchError:YES];
        [self restartUserAgent];
    }
}


#pragma mark -
#pragma mark AKSIPUserAgentDelegate

// Decides whether AKSIPUserAgent should add an account. User agent is started in this method if needed.
- (BOOL)SIPUserAgentShouldAddAccount:(AKSIPAccount *)anAccount {
    if ([[self userAgent] state] < kAKSIPUserAgentStarting) {
        [[self userAgent] start];
        
        // Don't add the account right now, let user agent start first.
        // The account should be added later, from the callback.
        return NO;
        
    } else if ([[self userAgent] state] < kAKSIPUserAgentStarted) {
        // User agent is starting, don't add account right now.
        // The account should be added later, from the callback.
        return NO;
    }
    
    return YES;
}

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    if ([[self userAgent] isStarted]) {
        if ([self shouldRegisterAllAccounts]) {
            for (AccountController *anAccountController in [self enabledAccountControllers]) {
                [anAccountController setAccountRegistered:YES];
            }
        }
        
        [self setShouldRegisterAllAccounts:NO];
        [self setShouldRestartUserAgentASAP:NO];
        
    } else {
        NSLog(@"Could not start SIP user agent. "
              "Please check your network connection and STUN server settings.");
        
        [self setShouldRegisterAllAccounts:NO];
        
        // Set |shouldPresentUserAgentLaunchError| if needed and if it wasn't set
        // somewhere else.
        if (![self shouldPresentUserAgentLaunchError]) {
            // Check whether any AccountController is trying to register or unregister
            // an acount. If so, we should present SIP user agent launch error.
            for (AccountController *accountController in [self enabledAccountControllers]) {
                if ([accountController shouldPresentRegistrationError]) {
                    [self setShouldPresentUserAgentLaunchError:YES];
                    [accountController setAttemptingToRegisterAccount:NO];
                    [accountController setAttemptingToUnregisterAccount:NO];
                    [accountController setShouldPresentRegistrationError:NO];
                }
            }
        }
        
        if ([self shouldPresentUserAgentLaunchError] && [NSApp modalWindow] == nil) {
            // Display application modal alert.
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Could not start SIP user agent.",
                                                    @"SIP user agent start error.")];
            [alert setInformativeText:
             NSLocalizedString(@"Please check your network connection and STUN server settings.",
                               @"SIP user agent start error informative text.")];
            [alert runModal]; 
        }
    }
    
    [self setShouldPresentUserAgentLaunchError:NO];
}

- (void)SIPUserAgentDidFinishStopping:(NSNotification *)notification {
    if ([self isTerminating]) {
        [NSApp replyToApplicationShouldTerminate:YES];
        
    } else if ([self shouldRegisterAllAccounts]) {
        if ([[self enabledAccountControllers] count] > 0) {
            [[self userAgent] start];
        } else {
            [self setShouldRegisterAllAccounts:NO];
        }
    }
}

- (void)SIPUserAgentDidDetectNAT:(NSNotification *)notification {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    
    switch ([[self userAgent] detectedNATType]) {
        case kAKNATTypeBlocked:
            [alert setMessageText:
             NSLocalizedString(@"Failed to communicate with STUN server.",
                               @"Failed to communicate with STUN server.")];
            [alert setInformativeText:
             NSLocalizedString(@"UDP packets are probably blocked. It is "
                               "impossible to make or receive calls without that. "
                               "Make sure that your local firewall and the "
                               "firewall at your router allow UDP protocol.",
                               @"Failed to communicate with STUN server "
                               "informative text.")];
            [alert runModal];
            break;
            
        case kAKNATTypeSymmetric:
            [alert setMessageText:
             NSLocalizedString(@"Symmetric NAT detected.",
                               @"Detected Symmetric NAT.")];
            [alert setInformativeText:
             NSLocalizedString(@"It is very unlikely that two-way conversations "
                               "will be possible with symmetric NAT. Please "
                               "contact your SIP provider to find out other NAT "
                               "traversal options. If you are connected to the "
                               "internet via personal router, try to replace it "
                               "with the one that supports \\U201Cfull "
                               "cone\\U201D, \\U201Crestricted cone\\U201D or "
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

- (void)windowWillClose:(NSNotification *)notification {
    // User closed Account Setup window. Terminate application.
    if ([[notification object] isEqual:[[self accountSetupController] window]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSWindowWillCloseNotification
                                                      object:[[self accountSetupController] window]];
        
        [NSApp terminate:self];
    }
}


#pragma mark -
#pragma mark NSApplication delegate methods

// Application control starts here.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Read main settings from defaults.
    if ([defaults boolForKey:kUseDNSSRV]) {
        [[self userAgent] setNameservers:[self currentNameservers]];
    }
    
    [[self userAgent] setOutboundProxyHost:[defaults stringForKey:kOutboundProxyHost]];
    
    [[self userAgent] setOutboundProxyPort:[defaults integerForKey:kOutboundProxyPort]];
    
    [[self userAgent] setSTUNServerHost:[defaults stringForKey:kSTUNServerHost]];
    
    [[self userAgent] setSTUNServerPort:[defaults integerForKey:kSTUNServerPort]];
    
    NSString *bundleName = [mainBundle infoDictionary][@"CFBundleName"];
    NSString *bundleShortVersion = [mainBundle infoDictionary][@"CFBundleShortVersionString"];
    
    [[self userAgent] setUserAgentString:[NSString stringWithFormat:@"%@ %@", bundleName, bundleShortVersion]];
    
    NSString *logFileName = [defaults stringForKey:kLogFileName];
    if ([logFileName length] > 0) {
        [self createDirectoryForFileAtPath:logFileName];
        [[self userAgent] setLogFileName:logFileName];
    }
    
    [[self userAgent] setLogLevel:[defaults integerForKey:kLogLevel]];
    [[self userAgent] setConsoleLogLevel:[defaults integerForKey:kConsoleLogLevel]];
    [[self userAgent] setDetectsVoiceActivity:[defaults boolForKey:kVoiceActivityDetection]];
    [[self userAgent] setUsesICE:[defaults boolForKey:kUseICE]];
    [[self userAgent] setTransportPort:[defaults integerForKey:kTransportPort]];
    [[self userAgent] setTransportPublicHost:[defaults stringForKey:kTransportPublicHost]];
    [[self userAgent] setUsesG711Only:[defaults boolForKey:kUseG711Only]];
    [self setRingtone:[NSSound soundNamed:[defaults stringForKey:kRingingSound]]];
    
    
    NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
    
    // Setup an account on first launch.
    if ([savedAccounts count] == 0) {
        // There are no saved accounts, prompt user to add one.
        
        // Disable Preferences during the first account prompt.
        [[self preferencesMenuItem] setAction:NULL];
        
        // Subscribe to addAccountWindow close to terminate application.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowWillClose:)
                                                     name:NSWindowWillCloseNotification
                                                   object:[[self accountSetupController] window]];
        
        // Set different targets and actions of addAccountWindow buttons to add the first account.
        [[[self accountSetupController] defaultButton] setTarget:self];
        [[[self accountSetupController] defaultButton] setAction:@selector(addAccountOnFirstLaunch:)];
        [[[self accountSetupController] otherButton] setTarget:[[self accountSetupController] window]];
        [[[self accountSetupController] otherButton] setAction:@selector(performClose:)];
        
        [[[self accountSetupController] window] center];
        [[[self accountSetupController] window] makeKeyAndOrderFront:self];
        
        // Early return.
        return;
    }
    
    // There are saved accounts, open account windows.
    for (NSUInteger i = 0; i < [savedAccounts count]; ++i) {
        NSDictionary *accountDict = savedAccounts[i];
        
        NSString *fullName = accountDict[kFullName];
        
        NSString *SIPAddress;
        if ([accountDict[kSIPAddress] length] > 0) {
            SIPAddress = accountDict[kSIPAddress];
        } else {
            SIPAddress = [NSString stringWithFormat:@"%@@%@",
                          accountDict[kUsername], accountDict[kDomain]];
        }
        
        NSString *registrar;
        if ([accountDict[kRegistrar] length] > 0) {
            registrar = accountDict[kRegistrar];
        } else {
            registrar = accountDict[kDomain];
        }
        
        NSString *realm = accountDict[kRealm];
        NSString *username = accountDict[kUsername];
        
        AKSIPAccount *account = [AKSIPAccount SIPAccountWithFullName:fullName
                                                          SIPAddress:SIPAddress
                                                           registrar:registrar
                                                               realm:realm
                                                            username:username];
        
        account.reregistrationTime = [accountDict[kReregistrationTime] integerValue];
        if ([accountDict[kUseProxy] boolValue]) {
            account.proxyHost = accountDict[kProxyHost];
            account.proxyPort = [accountDict[kProxyPort] integerValue];
        }
        account.updatesContactHeader = [accountDict[kUpdateContactHeader] boolValue];
        account.updatesViaHeader = [accountDict[kUpdateViaHeader] boolValue];
        
        AccountController *anAccountController = [[AccountController alloc] initWithSIPAccount:account];
        
        [[anAccountController window] setExcludedFromWindowsMenu:YES];
        
        NSString *description = accountDict[kDescription];
        if ([description length] == 0) {
            description = SIPAddress;
        }
        [anAccountController setAccountDescription:description];
        
        [anAccountController setEnabled:[accountDict[kAccountEnabled] boolValue]];
        [anAccountController setSubstitutesPlusCharacter:[accountDict[kSubstitutePlusCharacter] boolValue]];
        [anAccountController setPlusCharacterSubstitution:accountDict[kPlusCharacterSubstitutionString]];
        
        [[self accountControllers] addObject:anAccountController];
        
        if (![anAccountController isEnabled]) {
            // Prevent conflict with |setFrameAutosaveName:| when enabling the account.
            [anAccountController setWindow:nil];
            
            continue;
        }
        
        if (i == 0) {
            [[anAccountController window] makeKeyAndOrderFront:self];
            
        } else {
            NSWindow *previousAccountWindow = [[self accountControllers][(i - 1)] window];
            
            [[anAccountController window] orderWindow:NSWindowBelow relativeTo:[previousAccountWindow windowNumber]];
        }
    }
    
    // Update callsShouldDisplayAccountInfo on account controllers.
    [self updateCallsShouldDisplayAccountInfo];
    
    // Update account menu items.
    [self updateAccountsMenuItems];
    
    // Install audio devices changes callback.
    [self subscribeToAudioDeviceChanges];
    
    // Get available audio devices, select devices for sound input and output.
    [self updateAudioDevices];
    
    // If we want to be in Mac App Store, we can't write to |~/Library/ Address Book Plug-Ins| any more.
    //
    // [self installAddressBookPlugIns];
    
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    [GrowlApplicationBridge setGrowlDelegate:self];
    [self installDNSChangesCallback];
    
    [self setShouldPresentUserAgentLaunchError:YES];
    
    // Register as service provider to allow making calls from the Services
    // menu and context menus.
    [NSApp setServicesProvider:self];
    
    // Accounts with host name as the registrar will be registered with the
    // reachability callbacks. But if registrar is IP address, there won't be such
    // callbacks. Register such accounts here.
    for (AccountController *accountController in [self enabledAccountControllers]) {
        if ([[[accountController account] registrar] ak_isIPAddress] &&
            [[accountController registrarReachability] isReachable]) {
            
            [accountController setAttemptingToRegisterAccount:YES];
            [accountController setAccountRegistered:YES];
        }
    }
}

// Reopen all account windows when the user clicks the dock icon.
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    
    // Show incoming call window, if any.
    if ([self hasIncomingCallControllers]) {
        for (AccountController *anAccountController in [self enabledAccountControllers]) {
            for (CallController *aCallController in [anAccountController callControllers]) {
                if ([[aCallController call] identifier] != kAKSIPUserAgentInvalidIdentifier &&
                    [[aCallController call] state] == kAKSIPCallIncomingState) {
                    
                    [aCallController showWindow:nil];
                    
                    // Return early, beause we can't break from two for loops.
                    return YES;
                }
            }
        }
    } else {
        // Show window of first enalbed account.
        if ([NSApp keyWindow] == nil && [[self enabledAccountControllers] count] > 0) {
            [[self enabledAccountControllers][0] showWindow:self];
        }
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    // Invalidate application's Dock icon bouncing timer.
    if ([self userAttentionTimer] != nil) {
        [[self userAttentionTimer] invalidate];
        [self setUserAttentionTimer:nil];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if ([self hasActiveCallControllers]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"Quit", @"Quit button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
        [[alert buttons][1] setKeyEquivalent:@"\033"];
        [alert setMessageText:NSLocalizedString(@"Are you sure you want to quit Telephone?",
                                                @"Telephone quit confirmation.")];
        [alert setInformativeText:NSLocalizedString(@"All active calls will be disconnected.",
                                                    @"Telephone quit confirmation informative text.")];
        NSInteger choice = [alert runModal];
        
        if (choice == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    if ([[self userAgent] isStarted]) {
        [self setTerminating:YES];
        [self stopUserAgent];
        
        // Terminate after SIP user agent is stopped in the secondary thread.
        // We should send replyToApplicationShouldTerminate: to NSApp from
        // AKSIPUserAgentDidFinishStoppingNotification.
        return NSTerminateLater;
    }
    
    return NSTerminateNow;
}


#pragma mark -
#pragma mark AKSIPAccount notifications

- (void)SIPAccountWillMakeCall:(NSNotification *)notification {
    if ([self shouldSetUserAgentSoundIO]) {
        [self setSelectedSoundIOToUserAgent];
        [self setShouldSetUserAgentSoundIO:NO];
    }
}


#pragma mark -
#pragma mark AKSIPCall notifications

- (void)SIPCallCalling:(NSNotification *)notification {
    if ([self shouldSetUserAgentSoundIO] &&
        [[self userAgent] activeCallsCount] > 0) {
        [self setSelectedSoundIOToUserAgent];
        [self setShouldSetUserAgentSoundIO:NO];
    }
}

- (void)SIPCallIncoming:(NSNotification *)notification {
    if ([self shouldSetUserAgentSoundIO] &&
        [[self userAgent] activeCallsCount] > 0) {
        [self setSelectedSoundIOToUserAgent];
        [self setShouldSetUserAgentSoundIO:NO];
    }
    
    [self updateDockTileBadgeLabel];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    if ([self shouldRestartUserAgentASAP] && ![self hasActiveCallControllers]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartUserAgent) object:nil];
        [self setShouldRestartUserAgentASAP:NO];
        [self restartUserAgent];
    }
}


#pragma mark -
#pragma mark AuthenticationFailureController notifications

- (void)authenticationFailureControllerDidChangeUsernameAndPassword:(NSNotification *)notification {
    AccountController *accountController = [[notification object] accountController];
    NSUInteger index = [[self accountControllers] indexOfObject:accountController];
    
    if (index != NSNotFound) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
        
        NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:accounts[index]];
        
        accountDict[kUsername] = [[accountController account] username];
        
        accounts[index] = accountDict;
        [defaults setObject:accounts forKey:kAccounts];
        [defaults synchronize];
        
        AccountPreferencesViewController *accountPreferencesViewController
            = [[self preferencesController] accountPreferencesViewController];
        if ([[accountPreferencesViewController accountsTable] selectedRow] == index) {
            [accountPreferencesViewController populateFieldsForAccountAtIndex:index];
        }
    }
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    
    NSString *identifier = notification.userInfo[kUserNotificationCallControllerIdentifierKey];
    [self showWindowOfCallControllerWithIdentifier:identifier];
}

- (void)showWindowOfCallControllerWithIdentifier:(NSString *)identifier {
    CallController *callController = [self callControllerByIdentifier:identifier];
    if (![NSApp isActive]) {
        [NSApp activateIgnoringOtherApps:YES];
    }
    [callController showWindow:nil];
}



#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate protocol

- (void)growlNotificationWasClicked:(id)clickContext {
    NSString *identifier = (NSString *)clickContext;
    [self showWindowOfCallControllerWithIdentifier:identifier];
}

- (BOOL)hasNetworkClientEntitlement {
    return YES;
}

#pragma mark -
#pragma mark NSWorkspace notifications

// Disconnects all calls, removes all accounts from the user agent and destroys it before computer goes to sleep.
- (void)workspaceWillSleep:(NSNotification *)notification {
    if ([[self userAgent] isStarted]) {
        [self stopUserAgent];
    }
}

- (void)workspaceDidWake:(NSNotification *)notification {
    [self setShouldSetUserAgentSoundIO:YES];
}

// Unregisters all accounts when a user session is switched out.
- (void)workspaceSessionDidResignActive:(NSNotification *)notification {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        [anAccountController setAccountRegistered:NO];
    }
}

// Re-registers all accounts when a user session in switched in.
- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
        [anAccountController setAccountRegistered:YES];
    }
}


#pragma mark -
#pragma mark Address Book plug-in notifications

// TODO(eofster): Here we receive contact's name and call destination (phone or
// SIP address). Then we set text field string value as when the user typed in
// the name directly and Telephone autocompleted the input. The result is that
// Address Book is searched for the person record. As an alternative we could
// send person and selected call destination identifiers and get another
// destinations here (no new AB search).
// If we change it to work with identifiers, we'll probably want to somehow
// change ActiveAccountViewController's
// tokenField:representedObjectForEditingString:.
- (void)addressBookDidDialCallDestination:(NSNotification *)notification {
    if ([NSApp modalWindow] != nil) {
        return;
    }
    
    if ([[self enabledAccountControllers] count] == 0) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *callDestination = nil;
    if ([[notification name] isEqualToString:AKAddressBookDidDialPhoneNumberNotification]) {
        callDestination = userInfo[@"AKPhoneNumber"];
    } else if ([[notification name] isEqualToString:AKAddressBookDidDialSIPAddressNotification]) {
        callDestination = userInfo[@"AKSIPAddress"];
    }
    
    NSString *fullName = userInfo[@"AKFullName"];
    
    AccountController *firstEnabledAccountController = [self enabledAccountControllers][0];
    
    [[[firstEnabledAccountController activeAccountViewController] callDestinationField]
     setTokenStyle:NSRoundedTokenStyle];
    
    [NSApp activateIgnoringOtherApps:YES];
    
    NSString *theString;
    if ([fullName length] > 0) {
        theString = [NSString stringWithFormat:@"%@ <%@>", fullName, callDestination];
    } else {
        theString = callDestination;
    }
    
    [[[firstEnabledAccountController activeAccountViewController] callDestinationField] setStringValue:theString];
    
    if ([[firstEnabledAccountController account] identifier] == kAKSIPUserAgentInvalidIdentifier) {
        // Go Available if it's Offline. Make call from the callback.
        [firstEnabledAccountController setShouldMakeCall:YES];
        [firstEnabledAccountController setAccountRegistered:YES];
        
    } else {
        [[firstEnabledAccountController activeAccountViewController] makeCall:nil];
    }
}


#pragma mark -
#pragma mark Apple event handler for URLs support

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    if ([[self enabledAccountControllers] count] == 0) {
        return;
    }
    
    AccountController *firstEnabledAccountController = [self enabledAccountControllers][0];
    NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [firstEnabledAccountController setCatchedURLString:URLString];
    
    if ([[firstEnabledAccountController account] identifier] == kAKSIPUserAgentInvalidIdentifier) {
        // Go Available if it's Offline. Make call from the callback.
        [firstEnabledAccountController setAccountRegistered:YES];
    } else {
        [firstEnabledAccountController handleCatchedURL];
    }
}


#pragma mark -
#pragma mark Service Provider

- (void)makeCallFromTextService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    
    NSArray *classes = @[[NSString class]];
    NSDictionary *options = @{};
    if ([NSPasteboard instancesRespondToSelector:
         @selector(canReadObjectForClasses:options:)] &&
        ![pboard canReadObjectForClasses:classes options:options]) {
        NSLog(@"Could not make call, pboard couldn't give string.");
    }
    
    NSString *pboardString = [pboard stringForType:NSPasteboardTypeString];
    
    AccountController *firstEnabledAccountController = [self accountControllers][0];
    [[[firstEnabledAccountController activeAccountViewController]
      callDestinationField] setTokenStyle:NSPlainTextTokenStyle];
    [[[firstEnabledAccountController activeAccountViewController] callDestinationField] setStringValue:pboardString];
    
    if ([[firstEnabledAccountController account] identifier] == kAKSIPUserAgentInvalidIdentifier) {
        // Go Available if it's Offline. Make call from the callback.
        [firstEnabledAccountController setShouldMakeCall:YES];
        [firstEnabledAccountController setAccountRegistered:YES];
        
    } else {
        [[firstEnabledAccountController activeAccountViewController] makeCall:nil];
    }
}

@end


#pragma mark -

static OSStatus AudioDevicesChanged(AudioObjectID objectID,
                                    UInt32 numberAddresses,
                                    const AudioObjectPropertyAddress addresses[],
                                    void *clientData) {
    
    AppController *appController = (__bridge AppController *)clientData;
    BOOL shouldUpdateDevices = NO;
    for (UInt32 i = 0; i < numberAddresses; i++) {
        if (addresses[i].mSelector == kAudioHardwarePropertyDevices) {
            shouldUpdateDevices = YES;
            break;
        }
    }
    if (shouldUpdateDevices) {
        ScheduleAudioDevicesUpdate(appController);
    }
    
    return noErr;
}

static void ScheduleAudioDevicesUpdate(AppController *appController) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [appController updateAudioDevices];
    });
}

static OSStatus GetAudioDevices(Ptr *devices, UInt16 *deviceCount) {
    OSStatus error = noErr;
    UInt32 dataSize;
    
    AudioObjectPropertyAddress address = { kAudioHardwarePropertyDevices,
                                           kAudioObjectPropertyScopeGlobal,
                                           kAudioObjectPropertyElementMaster };
    error = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &address, 0, NULL, &dataSize);
    if (error != noErr) {
        return error;
    }
    
    *deviceCount = dataSize / (UInt16)sizeof(AudioObjectID);
    if (*deviceCount < 1) {
        NSLog(@"No audio devices found");
        return error;
    }
    
    *devices = (Ptr)malloc(dataSize);
    memset(*devices, 0, dataSize);
    
    error = AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &dataSize, (void *)*devices);
    
    return error;
}

static void NameserversChanged(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info) {
    id appDelegate = [NSApp delegate];
    NSArray *nameservers = [appDelegate currentNameservers];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:kUseDNSSRV] &&
        [nameservers count] > 0 &&
        ![[[appDelegate userAgent] nameservers] isEqualToArray:nameservers]) {
        
        [[appDelegate userAgent] setNameservers:nameservers];
        
        if (![appDelegate hasActiveCallControllers]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:appDelegate
                                                     selector:@selector(restartUserAgent)
                                                       object:nil];
            
            // Schedule user agent restart in several seconds to coalesce several
            // nameserver changes during a short time period.
            [appDelegate performSelector:@selector(restartUserAgent)
                              withObject:nil
                              afterDelay:kUserAgentRestartDelayAfterDNSChange];
        } else {
            [appDelegate setShouldRestartUserAgentASAP:YES];
        }
    }
}
