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

#import "AppController.h"

#import <CoreAudio/CoreAudio.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Growl/Growl.h>

#import "AKAddressBookPhonePlugIn.h"
#import "AKAddressBookSIPAddressPlugIn.h"
#import "AKSIPURI.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"
#import "AKTelephoneCall.h"
#import "iTunes.h"

#import "AccountController.h"
#import "CallController.h"
#import "PreferenceController.h"


// AudioHardware callback to track adding/removing audio devices
static OSStatus AKAudioDevicesChanged(AudioHardwarePropertyID propertyID,
                                      void *clientData);
// Get audio devices data.
static OSStatus AKGetAudioDevices(Ptr *devices, UInt16 *devicesCount);

// Audio device dictionary keys.
NSString * const kAudioDeviceIdentifier = @"AudioDeviceIdentifier";
NSString * const kAudioDeviceUID = @"AudioDeviceUID";
NSString * const kAudioDeviceName = @"AudioDeviceName";
NSString * const kAudioDeviceInputsCount = @"AudioDeviceInputsCount";
NSString * const kAudioDeviceOutputsCount = @"AudioDeviceOutputsCount";

@interface AppController()

- (void)setSelectedSoundIOToTelephone;

@end

@implementation AppController

@synthesize telephone = telephone_;
@synthesize accountControllers = accountControllers_;
@dynamic enabledAccountControllers;
@synthesize preferenceController = preferenceController_;
@synthesize audioDevices = audioDevices_;
@synthesize soundInputDeviceIndex = soundInputDeviceIndex_;
@synthesize soundOutputDeviceIndex = soundOutputDeviceIndex_;
@synthesize ringtoneOutputDeviceIndex = ringtoneOutputDeviceIndex_;
@dynamic ringtone;
@synthesize ringtoneTimer = ringtoneTimer_;
@synthesize shouldRegisterAllAccounts = shouldRegisterAllAccounts_;
@synthesize terminating = terminating_;
@dynamic hasIncomingCallControllers;
@dynamic hasActiveCallControllers;
@dynamic currentNameservers;
@synthesize didPauseITunes = didPauseITunes_;
@synthesize didWakeFromSleep = didWakeFromSleep_;

@synthesize preferencesMenuItem = preferencesMenuItem_;

- (NSArray *)enabledAccountControllers
{
  return [[self accountControllers] filteredArrayUsingPredicate:
          [NSPredicate predicateWithFormat:@"enabled == YES"]];
}

- (NSSound *)ringtone
{
  return [[ringtone_ retain] autorelease];
}

- (void)setRingtone:(NSSound *)aRingtone
{
  if (ringtone_ != aRingtone) {
    [ringtone_ release];
    ringtone_ = [aRingtone retain];
    
    if ([[self audioDevices] count] > [self ringtoneOutputDeviceIndex]) {
      NSDictionary *ringtoneOutputDeviceDict
        = [[self audioDevices] objectAtIndex:[self ringtoneOutputDeviceIndex]];
      [ringtone_ setPlaybackDeviceIdentifier:
       [ringtoneOutputDeviceDict objectForKey:kAudioDeviceUID]];
      
    } else {
      [ringtone_ setPlaybackDeviceIdentifier:nil];
    }
  }
}

- (BOOL)hasIncomingCallControllers
{
  for (AccountController *anAccountController in [self enabledAccountControllers]) {
    for (CallController *aCallController in [anAccountController callControllers]) {
      if ([[aCallController call] identifier] != kAKTelephoneInvalidIdentifier &&
          [[aCallController call] isIncoming] &&
          [aCallController callActive] &&
          ([[aCallController call] state] == kAKTelephoneCallIncomingState ||
           [[aCallController call] state] == kAKTelephoneCallEarlyState))
        return YES;
    }
  }
  
  return NO;
}

- (BOOL)hasActiveCallControllers
{
  for (AccountController *anAccountController in [self enabledAccountControllers]) {
    for (CallController *aCallController in [anAccountController callControllers]) {
      if ([aCallController callActive])
        return YES;
    }
  }
  
  return NO;
}

- (NSArray *)currentNameservers
{
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSString *bundleName
    = [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];
  
  SCDynamicStoreRef dynamicStore
    = SCDynamicStoreCreate(NULL, (CFStringRef)bundleName, NULL, NULL);
  
  CFPropertyListRef DNSSettings
    = SCDynamicStoreCopyValue(dynamicStore, CFSTR("State:/Network/Global/DNS"));
  
  NSArray *nameservers = nil;
  if (DNSSettings != NULL) {
    nameservers = [[(NSDictionary *)DNSSettings objectForKey:@"ServerAddresses"]
                   retain];
    
    CFRelease(DNSSettings);
  }
  
  CFRelease(dynamicStore);
  
  return [nameservers autorelease];
}

+ (void)initialize
{
  // Register defaults
  static BOOL initialized = NO;
  
  if (!initialized) {
    NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];
    
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:kUseDNSSRV];
    [defaultsDict setObject:@"" forKey:kOutboundProxyHost];
    [defaultsDict setObject:[NSNumber numberWithInteger:0]
                     forKey:kOutboundProxyPort];
    [defaultsDict setObject:@"" forKey:kSTUNServerHost];
    [defaultsDict setObject:[NSNumber numberWithInteger:0]
                     forKey:kSTUNServerPort];
    [defaultsDict setObject:[NSNumber numberWithBool:YES]
                     forKey:kVoiceActivityDetection];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:kUseICE];
    // TODO(eofster): hard-coded path must be replaced with a function call.
    [defaultsDict setObject:@"~/Library/Logs/Telephone.log"
                     forKey:kLogFileName];
    [defaultsDict setObject:[NSNumber numberWithInteger:3] forKey:kLogLevel];
    [defaultsDict setObject:[NSNumber numberWithInteger:0]
                     forKey:kConsoleLogLevel];
    [defaultsDict setObject:[NSNumber numberWithInteger:0]
                     forKey:kTransportPort];
    [defaultsDict setObject:@"Purr" forKey:kRingingSound];
    [defaultsDict setObject:[NSNumber numberWithInteger:10]
                     forKey:kSignificantPhoneNumberLength];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:kPauseITunes];
    
    NSString *preferredLocalization
      = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    // Do not format phone numbers in German localization by default.
    if ([preferredLocalization isEqualToString:@"German"])
      [defaultsDict setObject:[NSNumber numberWithBool:NO]
                       forKey:kFormatTelephoneNumbers];
    else
      [defaultsDict setObject:[NSNumber numberWithBool:YES]
                       forKey:kFormatTelephoneNumbers];
    
    // Split last four digits in Russian localization by default.
    if ([preferredLocalization isEqualToString:@"Russian"])
      [defaultsDict setObject:[NSNumber numberWithBool:YES]
                       forKey:kTelephoneNumberFormatterSplitsLastFourDigits];
    else
      [defaultsDict setObject:[NSNumber numberWithBool:NO]
                       forKey:kTelephoneNumberFormatterSplitsLastFourDigits];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
    
    initialized = YES;
  }
}

- (id)init
{
  self = [super init];
  if (self == nil)
    return nil;
  
  telephone_ = [AKTelephone sharedTelephone];
  [[self telephone] setDelegate:self];
  accountControllers_ = [[NSMutableArray alloc] init];
  [self setSoundInputDeviceIndex:kAKTelephoneInvalidIdentifier];
  [self setSoundOutputDeviceIndex:kAKTelephoneInvalidIdentifier];
  [self setShouldRegisterAllAccounts:NO];
  [self setTerminating:NO];
  [self setDidPauseITunes:NO];
  [self setDidWakeFromSleep:NO];
  
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
  
  // Subscribe to Address Book plug-in notifications via
  // NSDistributedNotificationCenter.
  NSDistributedNotificationCenter *distributedNotificationCenter
    = [NSDistributedNotificationCenter defaultCenter];
  
  [distributedNotificationCenter
   addObserver:self
      selector:@selector(addressBookDidDialCallDestination:)
          name:AKAddressBookDidDialPhoneNumberNotification
        object:@"AddressBook"
   suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
  
  [distributedNotificationCenter
   addObserver:self
      selector:@selector(addressBookDidDialCallDestination:)
          name:AKAddressBookDidDialSIPAddressNotification
        object:@"AddressBook"
   suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
  
  // Register Apple event handler for the URLs support.
  [[NSAppleEventManager sharedAppleEventManager]
   setEventHandler:self
       andSelector:@selector(handleGetURLEvent:withReplyEvent:)
     forEventClass:kInternetEventClass
        andEventID:kAEGetURL];
  
  return self;
}

- (void)dealloc
{
  [telephone_ dealloc];
  [accountControllers_ release];
  
  if ([[[self preferenceController] delegate] isEqual:self])
    [[self preferenceController] setDelegate:nil];
  [preferenceController_ release];
  
  [audioDevices_ release];
  [ringtone_ release];
  
  [preferencesMenuItem_ release];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
  
  [super dealloc];
}

// Application control starts here
- (void)awakeFromNib
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSString *bundleName
    = [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];
  NSString *bundleShortVersion
    = [[mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  
  if ([defaults boolForKey:kUseDNSSRV]) {
    [[self telephone] setNameservers:[self currentNameservers]];
  }
  
  [[self telephone] setOutboundProxyHost:[defaults stringForKey:kOutboundProxyHost]];
  [[self telephone] setOutboundProxyPort:[[defaults objectForKey:kOutboundProxyPort]
                                          integerValue]];
  [[self telephone] setSTUNServerHost:[defaults stringForKey:kSTUNServerHost]];
  [[self telephone] setSTUNServerPort:[[defaults objectForKey:kSTUNServerPort]
                                       integerValue]];
  [[self telephone] setUserAgentString:[NSString stringWithFormat:@"%@ %@",
                                        bundleName, bundleShortVersion]];
  [[self telephone] setLogFileName:[defaults stringForKey:kLogFileName]];
  [[self telephone] setLogLevel:[[defaults objectForKey:kLogLevel] integerValue]];
  [[self telephone] setConsoleLogLevel:[[defaults objectForKey:kConsoleLogLevel]
                                        integerValue]];
  [[self telephone] setDetectsVoiceActivity:[[defaults objectForKey:kVoiceActivityDetection]
                                             boolValue]];
  [[self telephone] setUsesICE:[[defaults objectForKey:kUseICE] boolValue]];
  [[self telephone] setTransportPort:[[defaults objectForKey:kTransportPort]
                                      integerValue]];
  
  [self setRingtone:[NSSound soundNamed:[defaults stringForKey:kRingingSound]]];
  
  // Install audio devices changes callback
  AudioHardwareAddPropertyListener(kAudioHardwarePropertyDevices,
                                   AKAudioDevicesChanged, self);
  
  // Get available audio devices, select devices for sound input and output.
  [self updateAudioDevices];
  
  // Install Address Book plug-ins.
  NSError *error = nil;
  BOOL installed = [self installAddressBookPlugInsAndReturnError:&error];
  if (!installed && error != nil) {
    NSLog(@"%@", error);
    
    NSString *libraryPath
      = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                             NSUserDomainMask,
                                             NO)
         objectAtIndex:0];
    
    if ([libraryPath length] > 0) {
      NSString *addressBookPlugInsInstallPath
        = [libraryPath stringByAppendingPathComponent:@"Address Book Plug-Ins"];
      
      NSAlert *alert = [[[NSAlert alloc] init] autorelease];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:
       NSLocalizedString(@"Could not install Address Book plug-ins.",
                         @"Address Book plug-ins install error, alert message text.")];
      [alert setInformativeText:
       [NSString stringWithFormat:
        NSLocalizedString(@"Make sure you have write permission to \\U201C%@\\U201D.",
                          @"Address Book plug-ins install error, alert informative text."),
        addressBookPlugInsInstallPath]];
      
      [alert runModal];
    }
  }
  
  // Load Growl.
  NSString *growlPath = [[mainBundle privateFrameworksPath]
                         stringByAppendingPathComponent:@"Growl.framework"];
  NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
  if (growlBundle != nil && [growlBundle load])
    [GrowlApplicationBridge setGrowlDelegate:self];
  else
    NSLog(@"Could not load Growl.framework");
  
  // Read accounts from defaults
  NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
  
  // Setup an account on first launch.
  if ([savedAccounts count] == 0) {
    // There are no saved accounts, prompt user to add one.
    
    // Disable Preferences during the first account prompt.
    [[self preferencesMenuItem] setAction:NULL];
    
    preferenceController_ = [[PreferenceController alloc] init];
    [[self preferenceController] setDelegate:self];
    [NSBundle loadNibNamed:@"AddAccount" owner:[self preferenceController]];
    
    // Subscribe to addAccountWindow close to terminate application.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(windowWillClose:)
            name:NSWindowWillCloseNotification
          object:[[self preferenceController] addAccountWindow]];
    
    // Set different targets and actions of addAccountWindow buttons to add the first account.
    [[[self preferenceController] addAccountWindowDefaultButton] setTarget:self];
    [[[self preferenceController] addAccountWindowDefaultButton]
     setAction:@selector(addAccountOnFirstLaunch:)];
    [[[self preferenceController] addAccountWindowOtherButton]
     setTarget:[[self preferenceController] addAccountWindow]];
    [[[self preferenceController] addAccountWindowOtherButton]
     setAction:@selector(performClose:)];
    
    [[[self preferenceController] addAccountWindow] center];
    [[[self preferenceController] addAccountWindow] makeKeyAndOrderFront:self];
    
    return;
  }
  
  // There are saved accounts, open account windows.
  for (NSUInteger i = 0; i < [savedAccounts count]; ++i) {
    NSDictionary *accountDict = [savedAccounts objectAtIndex:i];
    
    NSString *fullName = [accountDict objectForKey:kFullName];
    NSString *SIPAddress = [accountDict objectForKey:kSIPAddress];
    NSString *registrar = [accountDict objectForKey:kRegistrar];
    NSString *realm = [accountDict objectForKey:kRealm];
    NSString *username = [accountDict objectForKey:kUsername];
    
    AccountController *anAccountController
      = [[[AccountController alloc] initWithFullName:fullName
                                          SIPAddress:SIPAddress
                                           registrar:registrar
                                               realm:realm
                                            username:username]
         autorelease];
    
    [[anAccountController account] setReregistrationTime:
     [[accountDict objectForKey:kReregistrationTime] integerValue]];
    
    if ([[accountDict objectForKey:kUseProxy] boolValue]) {
      [[anAccountController account] setProxyHost:
       [accountDict objectForKey:kProxyHost]];
      [[anAccountController account] setProxyPort:
       [[accountDict objectForKey:kProxyPort] integerValue]];
    }
    
    [anAccountController setEnabled:
     [[accountDict objectForKey:kAccountEnabled] boolValue]];
    [anAccountController setSubstitutesPlusCharacter:
     [[accountDict objectForKey:kSubstitutePlusCharacter] boolValue]];
    [anAccountController setPlusCharacterSubstitution:
     [accountDict objectForKey:kPlusCharacterSubstitutionString]];
    
    [[self accountControllers] addObject:anAccountController];
    
    if (![anAccountController isEnabled]) {
      // Prevent conflict with setFrameAutosaveName: when enabling the account.
      [anAccountController setWindow:nil];
      
      continue;
    }
    
    if (i == 0)
      [[anAccountController window] makeKeyAndOrderFront:self];
    else {
      NSWindow *previousAccountWindow
        = [[[self accountControllers] objectAtIndex:(i - 1)] window];
      [[anAccountController window] orderWindow:NSWindowBelow
                                     relativeTo:[previousAccountWindow windowNumber]];
    }
  }
  
  if ([[self enabledAccountControllers] count] > 0) {
    // Register all acounts from the callback.
    [self setShouldRegisterAllAccounts:YES];
    
    // Start user agent.
    [[self telephone] startUserAgent];
  }
}

- (void)stopTelephone
{
  // Force ended state for all calls and remove accounts from Telephone.
  for (AccountController *anAccountController in [self enabledAccountControllers]) {
    for (CallController *aCallController in [anAccountController callControllers])
      [aCallController hangUpCall:nil];
    
    [anAccountController removeAccountFromTelephone];
  }
  
  [[self telephone] stopUserAgent];
}

- (void)updateAudioDevices
{
  OSStatus err = noErr;
  UInt32 size = 0;
  NSUInteger i = 0;
  AudioBufferList *theBufferList = NULL;
  
  NSMutableArray *devicesArray = [NSMutableArray array];
  
  // Fetch a pointer to the list of available devices.
  AudioDeviceID *devices = NULL;
  UInt16 devicesCount = 0;
  err = AKGetAudioDevices((Ptr *)&devices, &devicesCount);
  if (err != noErr)
    return;
  
  // Iterate over each device gathering information.
  for (NSUInteger loopCount = 0; loopCount < devicesCount; ++loopCount) {
    NSMutableDictionary *deviceDict = [NSMutableDictionary dictionary];
    
    // Get device identifier.
    NSUInteger deviceIdentifier = devices[loopCount];
    [deviceDict setObject:[NSNumber numberWithUnsignedInteger:deviceIdentifier]
                   forKey:kAudioDeviceIdentifier];
    
    // Get device UID.
    CFStringRef UIDStringRef = NULL;
    size = sizeof(CFStringRef);
    err = AudioDeviceGetProperty(devices[loopCount], 0, 0,
                                 kAudioDevicePropertyDeviceUID,
                                 &size, &UIDStringRef);
    [deviceDict setObject:(NSString *)UIDStringRef forKey:kAudioDeviceUID];
    CFRelease(UIDStringRef);
    
    // Get device name.
    CFStringRef nameStringRef = NULL;
    size = sizeof(CFStringRef);
    err = AudioDeviceGetProperty(devices[loopCount], 0, 0,
                                 kAudioDevicePropertyDeviceNameCFString,
                                 &size, &nameStringRef);
    [deviceDict setObject:(NSString *)nameStringRef forKey:kAudioDeviceName];
    CFRelease(nameStringRef);
    
    // Get number of input channels.
    size = 0;
    NSUInteger inputChannelsCount = 0;
    err = AudioDeviceGetPropertyInfo(devices[loopCount], 0, 1,
                                     kAudioDevicePropertyStreamConfiguration,
                                     &size, NULL);
    if ((err == noErr) && (size != 0)) {
      theBufferList = (AudioBufferList *)malloc(size);
      if (theBufferList != NULL) {
        // Get the input stream configuration.
        err = AudioDeviceGetProperty(devices[loopCount], 0, 1,
                                     kAudioDevicePropertyStreamConfiguration,
                                     &size, theBufferList);
        if (err == noErr) {
          // Count the total number of input channels in the stream.
          for(i = 0; i < theBufferList->mNumberBuffers; ++i)
            inputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
        }
        free(theBufferList);
        
        [deviceDict setObject:[NSNumber numberWithUnsignedInteger:inputChannelsCount]
                       forKey:kAudioDeviceInputsCount];
      }
    }
    
    // Get number of output channels.
    size = 0;
    NSUInteger outputChannelsCount = 0;
    err = AudioDeviceGetPropertyInfo(devices[loopCount], 0, 0,
                                     kAudioDevicePropertyStreamConfiguration,
                                     &size, NULL);
    if((err == noErr) && (size != 0)) {
      theBufferList = (AudioBufferList *)malloc(size);
      if(theBufferList != NULL) {
        // Get the input stream configuration.
        err = AudioDeviceGetProperty(devices[loopCount], 0, 0,
                                     kAudioDevicePropertyStreamConfiguration,
                                     &size, theBufferList);
        if(err == noErr) {
          // Count the total number of output channels in the stream.
          for (i = 0; i < theBufferList->mNumberBuffers; ++i)
            outputChannelsCount += theBufferList->mBuffers[i].mNumberChannels;
        }
        free(theBufferList);
        
        [deviceDict setObject:[NSNumber numberWithUnsignedInteger:outputChannelsCount]
                       forKey:kAudioDeviceOutputsCount];
      }
    }
    
    [devicesArray addObject:deviceDict];
  }
  
  free(devices);
  
  [self setAudioDevices:[[devicesArray copy] autorelease]];
  
  // Update audio devices in Telephone.
  [[self telephone] performSelectorOnMainThread:@selector(updateAudioDevices)
                                     withObject:nil
                                  waitUntilDone:YES];
  
  // Select sound IO from the updated audio devices list.
  // This method will change sound IO in Telephone if there are active calls.
  [self performSelectorOnMainThread:@selector(selectSoundIO)
                         withObject:nil
                      waitUntilDone:YES];
  
  // Update audio devices in preferences.
  [[self preferenceController]
   performSelectorOnMainThread:@selector(updateAudioDevices)
                    withObject:nil
                 waitUntilDone:NO];
}

// Select appropriate sound IO from the list of available audio devices.
// Lookup in the defaults database for devices selected earlier. If not found,
// use first matched. Select sound IO at Telephone if there are active calls.
- (void)selectSoundIO
{
  NSArray *devices = [self audioDevices];
  NSInteger newSoundInput, newSoundOutput, newRingtoneOutput;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *deviceDict;
  NSInteger i;
  
  // Lookup devices records in the defaults.
  
  newSoundInput = newSoundOutput = newRingtoneOutput = NSNotFound;
  
  NSString *lastSoundInputString = [defaults objectForKey:kSoundInput];
  if (lastSoundInputString != nil) {
    for (i = 0; i < [devices count]; ++i) {
      deviceDict = [devices objectAtIndex:i];
      if ([[deviceDict objectForKey:kAudioDeviceName] isEqual:lastSoundInputString] &&
          [[deviceDict objectForKey:kAudioDeviceInputsCount] integerValue] > 0)
      {
        newSoundInput = i;
        break;
      }
    }
  }
  
  NSString *lastSoundOutputString = [defaults objectForKey:kSoundOutput];
  if (lastSoundOutputString != nil) {
    for (i = 0; i < [devices count]; ++i) {
      deviceDict = [devices objectAtIndex:i];
      if ([[deviceDict objectForKey:kAudioDeviceName] isEqual:lastSoundOutputString] &&
          [[deviceDict objectForKey:kAudioDeviceOutputsCount] integerValue] > 0)
      {
        newSoundOutput = i;
        break;
      }
    }
  }
  
  NSString *lastRingtoneOutputString = [defaults objectForKey:kRingtoneOutput];
  if (lastRingtoneOutputString != nil) {
    for (i = 0; i < [devices count]; ++i) {
      deviceDict = [devices objectAtIndex:i];
      if ([[deviceDict objectForKey:kAudioDeviceName] isEqual:lastRingtoneOutputString] &&
          [[deviceDict objectForKey:kAudioDeviceOutputsCount] integerValue] > 0)
      {
        newRingtoneOutput = i;
        break;
      }
    }
  }
  
  // If still not found, select first matched.
  
  if (newSoundInput == NSNotFound) {
    for (i = 0; i < [devices count]; ++i)
      if ([[[devices objectAtIndex:i] objectForKey:kAudioDeviceInputsCount]
           integerValue] > 0) {
        newSoundInput = i;
        break;
      }
  }
  
  if (newSoundOutput == NSNotFound) {
    for (i = 0; i < [devices count]; ++i)
      if ([[[devices objectAtIndex:i] objectForKey:kAudioDeviceOutputsCount]
           integerValue] > 0) {
        newSoundOutput = i;
        break;
      }
  }
  
  if (newRingtoneOutput == NSNotFound) {
    for (i = 0; i < [devices count]; ++i)
      if ([[[devices objectAtIndex:i] objectForKey:kAudioDeviceOutputsCount]
           integerValue] > 0) {
        newRingtoneOutput = i;
        break;
      }
  }
  
  [self setSoundInputDeviceIndex:newSoundInput];
  [self setSoundOutputDeviceIndex:newSoundOutput];
  [self setRingtoneOutputDeviceIndex:newRingtoneOutput];
  
  // Set selected sound IO to Telephone if there are active calls.
  if ([[self telephone] activeCallsCount] > 0)
    [[self telephone] setSoundInputDevice:newSoundInput
                        soundOutputDevice:newSoundOutput];
  
  // Set selected ringtone output.
  [[self ringtone] setPlaybackDeviceIdentifier:
   [[devices objectAtIndex:newRingtoneOutput] objectForKey:kAudioDeviceUID]];
}

- (void)setSelectedSoundIOToTelephone
{
  [[self telephone] setSoundInputDevice:[self soundInputDeviceIndex]
                      soundOutputDevice:[self soundOutputDeviceIndex]];
}

- (IBAction)showPreferencePanel:(id)sender
{
  if (preferenceController_ == nil) {
    preferenceController_ = [[PreferenceController alloc] init];
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
  [[self preferencesMenuItem] setAction:@selector(showPreferencePanel:)];
  
  // Change back targets and actions of addAccountWindow buttons.
  [[[self preferenceController] addAccountWindowDefaultButton]
   setTarget:[self preferenceController]];
  [[[self preferenceController] addAccountWindowDefaultButton]
   setAction:@selector(addAccount:)];
  [[[self preferenceController] addAccountWindowOtherButton]
   setTarget:[self preferenceController]];
  [[[self preferenceController] addAccountWindowOtherButton]
   setAction:@selector(closeSheet:)];
}

- (void)startRingtoneTimer
{
  if ([self ringtoneTimer] != nil)
    [[self ringtoneTimer] invalidate];
  
  [self setRingtoneTimer:
   [NSTimer scheduledTimerWithTimeInterval:4
                                    target:self
                                  selector:@selector(ringtoneTimerTick:)
                                  userInfo:nil
                                   repeats:YES]];
}

- (void)stopRingtoneTimer
{
  if (![self hasIncomingCallControllers] && [self ringtoneTimer] != nil) {
    [[self ringtone] stop];
    [[self ringtoneTimer] invalidate];
    [self setRingtoneTimer:nil];
  }
}

- (void)ringtoneTimerTick:(NSTimer *)theTimer
{
  [[self ringtone] play];
}

- (void)pauseITunes
{
  if (![[NSUserDefaults standardUserDefaults] boolForKey:kPauseITunes])
    return;
  
  iTunesApplication *iTunes
    = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  
  if (![iTunes isRunning])
    return;
  
  if ([iTunes playerState] == iTunesEPlSPlaying) {
    [iTunes pause];
    [self setDidPauseITunes:YES];
  }
}

- (void)resumeITunesIfNeeded
{
  if (![[NSUserDefaults standardUserDefaults] boolForKey:kPauseITunes])
    return;
  
  iTunesApplication *iTunes
    = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  
  if (![iTunes isRunning])
    return;
  
  if ([self didPauseITunes] && ![self hasActiveCallControllers]) {
    if ([iTunes playerState] == iTunesEPlSPaused)
      [iTunes playOnce:NO];
    
    [self setDidPauseITunes:NO];
  }
}

- (CallController *)callControllerByIdentifier:(NSString *)identifier
{
  for (AccountController *anAccountController in [self enabledAccountControllers]) {
    for (CallController *aCallController in [anAccountController callControllers])
      if ([[aCallController identifier] isEqualToString:identifier])
        return aCallController;
  }
  
  return nil;
}

- (void)startUserAgentAfterDidWakeTick:(NSTimer *)theTimer
{
  if (![[self telephone] userAgentStarted]) {
    // Set |didWakeFromSleep| here because the user can manually initiate user
    // agent start-up by setting an account's status to Online. And that can
    // happen before we get here.
    [self setDidWakeFromSleep:YES];
    
    [self setShouldRegisterAllAccounts:YES];
    [[self telephone] startUserAgent];
  }
}

- (IBAction)openFAQURL:(id)sender
{
  if ([[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]
       isEqualToString:@"Russian"]) {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL URLWithString:@"http://code.google.com/p/telephone/wiki/RussianFAQ"]];
  } else {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL URLWithString:@"http://code.google.com/p/telephone/wiki/FAQ"]];
  }
}

- (BOOL)installAddressBookPlugInsAndReturnError:(NSError **)error
{
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSString *plugInsPath = [mainBundle builtInPlugInsPath];
  
  NSString *phonePlugInPath
    = [plugInsPath
       stringByAppendingPathComponent:@"TelephoneAddressBookPhonePlugIn.bundle"];
  NSString *SIPAddressPlugInPath
    = [plugInsPath
       stringByAppendingPathComponent:@"TelephoneAddressBookSIPAddressPlugIn.bundle"];
  
  NSArray *libraryPaths
    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                          NSUserDomainMask, YES);
  if ([libraryPaths count] < 0)
    return NO;
  
  NSString *installPath
    = [[libraryPaths objectAtIndex:0]
       stringByAppendingPathComponent:@"Address Book Plug-Ins"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Create |~/Library/Address Book Plug-Ins| if needed.
  BOOL isDir;
  BOOL pathExists = [fileManager fileExistsAtPath:installPath
                                      isDirectory:&isDir];
  if (!pathExists) {
    BOOL created = [fileManager createDirectoryAtPath:installPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:error];
    if (!created)
      return NO;
    
  } else if (!isDir) {
    NSLog(@"%@ is not a directory", installPath);
    return NO;
  }
  
  
  NSBundle *phonePlugInBundle = [NSBundle bundleWithPath:phonePlugInPath];
  NSInteger phonePlugInVersion
    = [[[phonePlugInBundle infoDictionary]
        objectForKey:@"CFBundleVersion"] integerValue];
  NSString *phonePlugInInstallPath
    = [installPath stringByAppendingPathComponent:
       [phonePlugInPath lastPathComponent]];
  NSBundle *installedPhonePlugInBundle
    = [NSBundle bundleWithPath:phonePlugInInstallPath];
  
  BOOL shouldInstallPhonePlugIn = YES;
  if (installedPhonePlugInBundle != nil) {
    NSInteger installedPhonePlugInVersion
      = [[[installedPhonePlugInBundle infoDictionary]
          objectForKey:@"CFBundleVersion"] integerValue];
    
    // Remove the old plug-in version if it needs updating.
    if (installedPhonePlugInVersion < phonePlugInVersion) {
      BOOL removed = [fileManager removeItemAtPath:phonePlugInInstallPath
                                             error:error];
      if (!removed)
        return NO;
      
    } else {
      // Don't copy the new version if it's not newer.
      shouldInstallPhonePlugIn = NO;
    }
  }
  
  NSBundle *SIPAddressPlugInBundle
    = [NSBundle bundleWithPath:SIPAddressPlugInPath];
  NSInteger SIPAddressPlugInVersion
    = [[[SIPAddressPlugInBundle infoDictionary]
        objectForKey:@"CFBundleVersion"] integerValue];
  NSString *SIPAddressPlugInInstallPath
    = [installPath stringByAppendingPathComponent:
       [SIPAddressPlugInPath lastPathComponent]];
  NSBundle *installedSIPAddressPlugInBundle
    = [NSBundle bundleWithPath:SIPAddressPlugInInstallPath];
  
  BOOL shouldInstallSIPAddressPlugIn = YES;
  if (installedSIPAddressPlugInBundle != nil) {
    NSInteger installedSIPAddressPlugInVersion
      = [[[installedSIPAddressPlugInBundle infoDictionary]
          objectForKey:@"CFBundleVersion"] integerValue];
    
    // Remove the old plug-in version if it needs updating.
    if (installedSIPAddressPlugInVersion < SIPAddressPlugInVersion) {
      BOOL removed = [fileManager removeItemAtPath:SIPAddressPlugInInstallPath
                                             error:error];
      if (!removed)
        return NO;
      
    } else {
      // Don't copy the new version if it's not newer.
      shouldInstallSIPAddressPlugIn = NO;
    }
  }
  
  BOOL installed;
  
  if (shouldInstallPhonePlugIn) {
    installed = [fileManager copyItemAtPath:phonePlugInPath
                                     toPath:phonePlugInInstallPath
                                      error:error];
    if (!installed)
      return NO;
  }
  
  if (shouldInstallSIPAddressPlugIn) {
    installed = [fileManager copyItemAtPath:SIPAddressPlugInPath
                                     toPath:SIPAddressPlugInInstallPath
                                      error:error];
    
    if (!installed)
      return NO;
  }
  
  return YES;
}

- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode
{
  NSString *localizedString = nil;
  
  switch (responseCode) {
        // Provisional 1xx.
      case PJSIP_SC_TRYING:
        localizedString
          = NSLocalizedStringFromTable(@"Trying", @"SIPResponses",
                                       @"100 Trying.");
        break;
      case PJSIP_SC_RINGING:
        localizedString
          = NSLocalizedStringFromTable(@"Ringing", @"SIPResponses",
                                       @"180 Ringing.");
        break;
      case PJSIP_SC_CALL_BEING_FORWARDED:
        localizedString
          = NSLocalizedStringFromTable(@"Call Is Being Forwarded",
                                       @"SIPResponses",
                                       @"181 Call Is Being Forwarded.");
        break;
      case PJSIP_SC_QUEUED:
        localizedString
          = NSLocalizedStringFromTable(@"Queued", @"SIPResponses",
                                       @"182 Queued.");
        break;
      case PJSIP_SC_PROGRESS:
        localizedString
          = NSLocalizedStringFromTable(@"Session Progress", @"SIPResponses",
                                       @"183 Session Progress.");
        break;
        
        // Successful 2xx.
      case PJSIP_SC_OK:
        localizedString
          = NSLocalizedStringFromTable(@"OK", @"SIPResponses", @"200 OK.");
        break;
      case PJSIP_SC_ACCEPTED:
        localizedString
          = NSLocalizedStringFromTable(@"Accepted", @"SIPResponses",
                                       @"202 Accepted.");
        break;
        
        // Redirection 3xx.
      case PJSIP_SC_MULTIPLE_CHOICES:
        localizedString
          = NSLocalizedStringFromTable(@"Multiple Choices", @"SIPResponses",
                                       @"300 Multiple Choices.");
        break;
      case PJSIP_SC_MOVED_PERMANENTLY:
        localizedString
          = NSLocalizedStringFromTable(@"Moved Permanently", @"SIPResponses",
                                       @"301 Moved Permanently.");
        break;
      case PJSIP_SC_MOVED_TEMPORARILY:
        localizedString
          = NSLocalizedStringFromTable(@"Moved Temporarily", @"SIPResponses",
                                       @"302 Moved Temporarily.");
        break;
      case PJSIP_SC_USE_PROXY:
        localizedString
          = NSLocalizedStringFromTable(@"Use Proxy", @"SIPResponses",
                                       @"305 Use Proxy.");
        break;
      case PJSIP_SC_ALTERNATIVE_SERVICE:
        localizedString
          = NSLocalizedStringFromTable(@"Alternative Service", @"SIPResponses",
                                       @"380 Alternative Service.");
        break;
        
        // Request Failure 4xx.
      case PJSIP_SC_BAD_REQUEST:
        localizedString
          = NSLocalizedStringFromTable(@"Bad Request", @"SIPResponses",
                                       @"400 Bad Request.");
        break;
      case PJSIP_SC_UNAUTHORIZED:
        localizedString
          = NSLocalizedStringFromTable(@"Unauthorized", @"SIPResponses",
                                       @"401 Unauthorized.");
        break;
      case PJSIP_SC_PAYMENT_REQUIRED:
        localizedString
          = NSLocalizedStringFromTable(@"Payment Required", @"SIPResponses",
                                       @"402 Payment Required.");
        break;
      case PJSIP_SC_FORBIDDEN:
        localizedString
          = NSLocalizedStringFromTable(@"Forbidden", @"SIPResponses",
                                       @"403 Forbidden.");
        break;
      case PJSIP_SC_NOT_FOUND:
        localizedString
          = NSLocalizedStringFromTable(@"Not Found", @"SIPResponses",
                                       @"404 Not Found.");
        break;
      case PJSIP_SC_METHOD_NOT_ALLOWED:
        localizedString
          = NSLocalizedStringFromTable(@"Method Not Allowed", @"SIPResponses",
                                       @"405 Method Not Allowed.");
        break;
      case PJSIP_SC_NOT_ACCEPTABLE:
        localizedString
          = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses",
                                       @"406 Not Acceptable.");
        break;
      case PJSIP_SC_PROXY_AUTHENTICATION_REQUIRED:
        localizedString
          = NSLocalizedStringFromTable(@"Proxy Authentication Required",
                                       @"SIPResponses",
                                       @"407 Proxy Authentication Required.");
        break;
      case PJSIP_SC_REQUEST_TIMEOUT:
        localizedString
          = NSLocalizedStringFromTable(@"Request Timeout", @"SIPResponses",
                                       @"408 Request Timeout.");
        break;
      case PJSIP_SC_GONE:
        localizedString
          = NSLocalizedStringFromTable(@"Gone", @"SIPResponses", @"410 Gone.");
        break;
      case PJSIP_SC_REQUEST_ENTITY_TOO_LARGE:
        localizedString
          = NSLocalizedStringFromTable(@"Request Entity Too Large",
                                       @"SIPResponses",
                                       @"413 Request Entity Too Large.");
        break;
      case PJSIP_SC_REQUEST_URI_TOO_LONG:
        localizedString
          = NSLocalizedStringFromTable(@"Request-URI Too Long", @"SIPResponses",
                                       @"414 Request-URI Too Long.");
        break;
      case PJSIP_SC_UNSUPPORTED_MEDIA_TYPE:
        localizedString
          = NSLocalizedStringFromTable(@"Unsupported Media Type", @"SIPResponses",
                                       @"415 Unsupported Media Type.");
        break;
      case PJSIP_SC_UNSUPPORTED_URI_SCHEME:
        localizedString
          = NSLocalizedStringFromTable(@"Unsupported URI Scheme", @"SIPResponses",
                                       @"416 Unsupported URI Scheme.");
        break;
      case PJSIP_SC_BAD_EXTENSION:
        localizedString
          = NSLocalizedStringFromTable(@"Bad Extension", @"SIPResponses",
                                       @"420 Bad Extension.");
        break;
      case PJSIP_SC_EXTENSION_REQUIRED:
        localizedString
          = NSLocalizedStringFromTable(@"Extension Required", @"SIPResponses",
                                       @"421 Extension Required.");
        break;
      case PJSIP_SC_SESSION_TIMER_TOO_SMALL:
        localizedString
          = NSLocalizedStringFromTable(@"Session Timer Too Small", @"SIPResponses",
                                       @"422 Session Timer Too Small.");
        break;
      case PJSIP_SC_INTERVAL_TOO_BRIEF:
        localizedString
          = NSLocalizedStringFromTable(@"Interval Too Brief", @"SIPResponses",
                                       @"423 Interval Too Brief.");
        break;
      case PJSIP_SC_TEMPORARILY_UNAVAILABLE:
        localizedString
          = NSLocalizedStringFromTable(@"Temporarily Unavailable", @"SIPResponses",
                                       @"480 Temporarily Unavailable.");
        break;
      case PJSIP_SC_CALL_TSX_DOES_NOT_EXIST:
        localizedString
          = NSLocalizedStringFromTable(@"Call/Transaction Does Not Exist",
                                       @"SIPResponses",
                                       @"481 Call/Transaction Does Not Exist.");
        break;
      case PJSIP_SC_LOOP_DETECTED:
        localizedString
          = NSLocalizedStringFromTable(@"Loop Detected", @"SIPResponses",
                                       @"482 Loop Detected.");
        break;
      case PJSIP_SC_TOO_MANY_HOPS:
        localizedString
          = NSLocalizedStringFromTable(@"Too Many Hops", @"SIPResponses",
                                       @"483 Too Many Hops.");
        break;
      case PJSIP_SC_ADDRESS_INCOMPLETE:
        localizedString
          = NSLocalizedStringFromTable(@"Address Incomplete", @"SIPResponses",
                                       @"484 Address Incomplete.");
        break;
      case PJSIP_AC_AMBIGUOUS:
        localizedString
          = NSLocalizedStringFromTable(@"Ambiguous", @"SIPResponses",
                                       @"485 Ambiguous.");
        break;
      case PJSIP_SC_BUSY_HERE:
        localizedString
          = NSLocalizedStringFromTable(@"Busy Here", @"SIPResponses",
                                       @"486 Busy Here.");
        break;
      case PJSIP_SC_REQUEST_TERMINATED:
        localizedString
          = NSLocalizedStringFromTable(@"Request Terminated", @"SIPResponses",
                                       @"487 Request Terminated.");
        break;
      case PJSIP_SC_NOT_ACCEPTABLE_HERE:
        localizedString
          = NSLocalizedStringFromTable(@"Not Acceptable Here", @"SIPResponses",
                                       @"488 Not Acceptable Here.");
        break;
      case PJSIP_SC_BAD_EVENT:
        localizedString
          = NSLocalizedStringFromTable(@"Bad Event", @"SIPResponses",
                                       @"489 Bad Event.");
        break;
      case PJSIP_SC_REQUEST_UPDATED:
        localizedString
          = NSLocalizedStringFromTable(@"Request Updated", @"SIPResponses",
                                       @"490 Request Updated.");
        break;
      case PJSIP_SC_REQUEST_PENDING:
        localizedString
          = NSLocalizedStringFromTable(@"Request Pending", @"SIPResponses",
                                       @"491 Request Pending.");
        break;
      case PJSIP_SC_UNDECIPHERABLE:
        localizedString
          = NSLocalizedStringFromTable(@"Undecipherable", @"SIPResponses",
                                       @"493 Undecipherable.");
        break;
        
        // Server Failure 5xx.
      case PJSIP_SC_INTERNAL_SERVER_ERROR:
        localizedString
          = NSLocalizedStringFromTable(@"Server Internal Error", @"SIPResponses",
                                       @"500 Server Internal Error.");
        break;
      case PJSIP_SC_NOT_IMPLEMENTED:
        localizedString
          = NSLocalizedStringFromTable(@"Not Implemented", @"SIPResponses",
                                       @"501 Not Implemented.");
        break;
      case PJSIP_SC_BAD_GATEWAY:
        localizedString
          = NSLocalizedStringFromTable(@"Bad Gateway", @"SIPResponses",
                                       @"502 Bad Gateway.");
        break;
      case PJSIP_SC_SERVICE_UNAVAILABLE:
        localizedString
          = NSLocalizedStringFromTable(@"Service Unavailable", @"SIPResponses",
                                       @"503 Service Unavailable.");
        break;
      case PJSIP_SC_SERVER_TIMEOUT:
        localizedString
          = NSLocalizedStringFromTable(@"Server Time-out", @"SIPResponses",
                                       @"504 Server Time-out.");
        break;
      case PJSIP_SC_VERSION_NOT_SUPPORTED:
        localizedString
          = NSLocalizedStringFromTable(@"Version Not Supported", @"SIPResponses",
                                       @"505 Version Not Supported.");
        break;
      case PJSIP_SC_MESSAGE_TOO_LARGE:
        localizedString
          = NSLocalizedStringFromTable(@"Message Too Large", @"SIPResponses",
                                       @"513 Message Too Large.");
        break;
      case PJSIP_SC_PRECONDITION_FAILURE:
        localizedString
          = NSLocalizedStringFromTable(@"Precondition Failure", @"SIPResponses",
                                       @"580 Precondition Failure.");
        break;
        
        // Global Failures 6xx.
      case PJSIP_SC_BUSY_EVERYWHERE:
        localizedString
          = NSLocalizedStringFromTable(@"Busy Everywhere", @"SIPResponses",
                                       @"600 Busy Everywhere.");
        break;
      case PJSIP_SC_DECLINE:
        localizedString
          = NSLocalizedStringFromTable(@"Decline", @"SIPResponses",
                                       @"603 Decline.");
        break;
      case PJSIP_SC_DOES_NOT_EXIST_ANYWHERE:
        localizedString
          = NSLocalizedStringFromTable(@"Does Not Exist Anywhere", @"SIPResponses",
                                       @"604 Does Not Exist Anywhere.");
        break;
      case PJSIP_SC_NOT_ACCEPTABLE_ANYWHERE:
        localizedString
          = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses",
                                       @"606 Not Acceptable.");
        break;
      default:
        localizedString = nil;
        break;
  }
  
  return localizedString;
}


#pragma mark -
#pragma mark PreferenceController delegate

- (void)preferenceControllerDidAddAccount:(NSNotification *)notification
{
  NSDictionary *accountDict = [notification userInfo];
  AccountController *theAccountController
    = [[[AccountController alloc]
        initWithFullName:[accountDict objectForKey:kFullName]
              SIPAddress:[accountDict objectForKey:kSIPAddress]
               registrar:[accountDict objectForKey:kRegistrar]
                   realm:[accountDict objectForKey:kRealm]
                username:[accountDict objectForKey:kUsername]]
       autorelease];
  
  [theAccountController setEnabled:YES];
  
  [[self accountControllers] addObject:theAccountController];
  
  [[theAccountController window] orderFront:self];
  
  // Register account.
  [theAccountController setAccountRegistered:YES];
}

- (void)preferenceControllerDidRemoveAccount:(NSNotification *)notification
{
  NSInteger index
    = [[[notification userInfo] objectForKey:kAccountIndex] integerValue];
  AccountController *anAccountController
    = [[self accountControllers] objectAtIndex:index];
  
  if ([anAccountController isEnabled])
    [anAccountController removeAccountFromTelephone];
  
  [[self accountControllers] removeObjectAtIndex:index];
}

- (void)preferenceControllerDidChangeAccountEnabled:(NSNotification *)notification
{
  NSUInteger index
    = [[[notification userInfo] objectForKey:kAccountIndex] integerValue];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
  NSDictionary *accountDict = [savedAccounts objectAtIndex:index];
  
  BOOL isEnabled = [[accountDict objectForKey:kAccountEnabled] boolValue];
  if (isEnabled) {
    AccountController *theAccountController
      = [[[AccountController alloc]
         initWithFullName:[accountDict objectForKey:kFullName]
               SIPAddress:[accountDict objectForKey:kSIPAddress]
                registrar:[accountDict objectForKey:kRegistrar]
                    realm:[accountDict objectForKey:kRealm]
                 username:[accountDict objectForKey:kUsername]]
         autorelease];
    
    [[theAccountController account] setReregistrationTime:
     [[accountDict objectForKey:kReregistrationTime] integerValue]];
    
    if ([[accountDict objectForKey:kUseProxy] boolValue]) {
      [[theAccountController account] setProxyHost:
       [accountDict objectForKey:kProxyHost]];
      [[theAccountController account] setProxyPort:
       [[accountDict objectForKey:kProxyPort] integerValue]];
    }
    
    [theAccountController setEnabled:YES];
    [theAccountController setSubstitutesPlusCharacter:
     [[accountDict objectForKey:kSubstitutePlusCharacter] boolValue]];
    [theAccountController setPlusCharacterSubstitution:
     [accountDict objectForKey:kPlusCharacterSubstitutionString]];
    
    [[self accountControllers] replaceObjectAtIndex:index
                                         withObject:theAccountController];
    
    [[theAccountController window] orderFront:nil];
    
    // Register account (as a result, it will be added to Telephone).
    [theAccountController setAttemptingToRegisterAccount:YES];
    [theAccountController setAccountRegistered:YES];
    
  } else {
    AccountController *theAccountController
      = [[self accountControllers] objectAtIndex:index];
    
    // Close all call windows hanging up all calls.
    [[theAccountController callControllers]
     makeObjectsPerformSelector:@selector(close)];
    
    // Remove account from Telephone.
    [theAccountController removeAccountFromTelephone];
    [theAccountController setEnabled:NO];
    [theAccountController setAttemptingToRegisterAccount:NO];
    [theAccountController setAttemptingToUnregisterAccount:NO];
    [[theAccountController window] orderOut:nil];
    
    // Prevent conflict with setFrameAutosaveName: when re-enabling the account.
    [theAccountController setWindow:nil];
  }
}

- (void)preferenceControllerDidSwapAccounts:(NSNotification *)notification
{
  NSDictionary *userInfo = [notification userInfo];
  NSInteger sourceIndex = [[userInfo objectForKey:kSourceIndex] integerValue];
  NSInteger destinationIndex = [[userInfo objectForKey:kDestinationIndex]
                                integerValue];
  
  if (sourceIndex == destinationIndex)
    return;
  
  [[self accountControllers] insertObject:[[self accountControllers]
                                           objectAtIndex:sourceIndex]
                                  atIndex:destinationIndex];
  if (sourceIndex < destinationIndex)
    [[self accountControllers] removeObjectAtIndex:sourceIndex];
  else if (sourceIndex > destinationIndex)
    [[self accountControllers] removeObjectAtIndex:(sourceIndex + 1)];
}

- (void)preferenceControllerDidChangeNetworkSettings:(NSNotification *)notification
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [[self telephone] setTransportPort:
   [[defaults objectForKey:kTransportPort] integerValue]];
  [[self telephone] setSTUNServerHost:[defaults stringForKey:kSTUNServerHost]];
  [[self telephone] setSTUNServerPort:
   [[defaults objectForKey:kSTUNServerPort] integerValue]];
  [[self telephone] setUsesICE:[[defaults objectForKey:kUseICE] boolValue]];
  [[self telephone] setOutboundProxyHost:
   [defaults stringForKey:kOutboundProxyHost]];
  [[self telephone] setOutboundProxyPort:
   [[defaults objectForKey:kOutboundProxyPort] integerValue]];
    
  
  if ([[self telephone] userAgentStarted]) {
    [self setShouldRegisterAllAccounts:YES];
    [self stopTelephone];
  }
}


#pragma mark -
#pragma mark AKTelephoneDelegate protocol

// This method decides whether Telephone should add an account.
// Telephone is started in this method if needed.
- (BOOL)telephoneShouldAddAccount:(AKTelephoneAccount *)anAccount
{
  if ([[self telephone] userAgentState] < kAKTelephoneUserAgentStarting) {
    [[self telephone] startUserAgent];
    
    // Don't add the account right now, let user agent start first.
    // The account should be added later, from the callback.
    return NO;
    
  } else if ([[self telephone] userAgentState] < kAKTelephoneUserAgentStarted) {
    // User agent is starting, don't add account right now.
    // The account should be added later, from the callback.
    return NO;
  }
  
  return YES;
}


#pragma mark -
#pragma mark AKTelephone notifications

- (void)telephoneUserAgentDidFinishStarting:(NSNotification *)notification
{
  if ([[self telephone] userAgentStarted]) {
    if ([self shouldRegisterAllAccounts])
      for (AccountController *anAccountController in [self enabledAccountControllers])
        [anAccountController setAccountRegistered:YES];
    
    [self setShouldRegisterAllAccounts:NO];
    
  } else {
    NSLog(@"Could not start SIP user agent. "
          "Please check your network connection and STUN server settings.");
    
    [self setShouldRegisterAllAccounts:NO];
    
    if (![self didWakeFromSleep]) {
      // Display application modal alert.
      NSAlert *alert = [[[NSAlert alloc] init] autorelease];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:NSLocalizedString(@"Could not start SIP user agent.",
                                              @"SIP user agent start error.")];
      [alert setInformativeText:
       NSLocalizedString(@"Please check your network connection and STUN server settings.",
                         @"SIP user agent start error informative text.")];
      [alert runModal];
      
    } else {
      [self setDidWakeFromSleep:NO];
    }
  }
}

- (void)telephoneUserAgentDidFinishStopping:(NSNotification *)notification
{
  if ([self isTerminating]) {
    [NSApp replyToApplicationShouldTerminate:YES];
  
  } else if ([self shouldRegisterAllAccounts]) {
    if ([[self enabledAccountControllers] count] > 0)
      [[self telephone] startUserAgent];
    else
      [self setShouldRegisterAllAccounts:NO];
  }
}

- (void)telephoneDidDetectNAT:(NSNotification *)notification
{
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:@"OK"];
  
  switch ([[self telephone] detectedNATType]) {
      case kAKNATTypeBlocked:
        [alert setMessageText:
         NSLocalizedString(@"Failed to communicate with STUN server.",
                           @"Failed to communicate with STUN server.")];
        [alert setInformativeText:
         NSLocalizedString(@"UDP packets are probably blocked. It is "
                           "impossible to make or receive calls without that. "
                           "Make sure that your local firewall and the "
                           "firewall at your router allow UDP protocol.",
                           @"Failed to communicate with STUN server informative text.")];
        [alert runModal];
        break;
        
      case kAKNATTypeSymmetric:
        [alert setMessageText:
         NSLocalizedString(@"Symmetric NAT detected.", @"Detected Symmetric NAT.")];
        [alert setInformativeText:
         NSLocalizedString(@"It very unlikely that two-way conversations will "
                           "be possible with the symmetric NAT. Contact you "
                           "SIP provider to find out other NAT traversal options. "
                           "If you are connected to the internet through the "
                           "personal router, try to replace it with the one "
                           "that supports \\U201Cfull cone\\U201D, "
                           "\\U201Crestricted cone\\U201D or "
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
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
               name:NSWindowWillCloseNotification
             object:[[self preferenceController] addAccountWindow]];
    
    [NSApp terminate:self];
  }
}


#pragma mark -
#pragma mark NSApplication delegate methods

// Reopen all account windows when the user clicks the dock icon.
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag
{
  // Show incoming call window, if any.
  if ([self hasIncomingCallControllers]) {
    for (AccountController *anAccountController in [self enabledAccountControllers]) {
      for (CallController *aCallController in [anAccountController callControllers])
        if ([[aCallController call] identifier] != kAKTelephoneInvalidIdentifier &&
            [[aCallController call] state] == kAKTelephoneCallIncomingState)
        {
          [aCallController showWindow:nil];
          return YES;
        }
    }
  }
  
  // No incoming calls, show window of the enabled accounts.
  for (AccountController *anAccountController in [self enabledAccountControllers]) {
    if (![[anAccountController window] isVisible])
      [[anAccountController window] orderFront:nil];
  }
  
  // Make first enabled account window key if there are no other key windows.
  if ([NSApp keyWindow] == nil && [[self enabledAccountControllers] count] > 0)
    [[[[self enabledAccountControllers] objectAtIndex:0] window] makeKeyWindow];
  
  return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  if ([self hasActiveCallControllers]) {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:NSLocalizedString(@"Quit", @"Quit button.")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
    [[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
    [alert setMessageText:
     NSLocalizedString(@"Are you sure you want to quit Telephone?",
                       @"Telephone quit confirmation.")];
    [alert setInformativeText:
     NSLocalizedString(@"All active calls will be disconnected.",
                       @"Telephone quit confirmation informative text.")];
    
    NSInteger choice = [alert runModal];

    if (choice == NSAlertSecondButtonReturn)
      return NSTerminateCancel;
  }
  
  if ([[self telephone] userAgentStarted]) {
    [self setTerminating:YES];
    [self stopTelephone];
    
    // Terminate after SIP user agent is stopped in the secondary thread.
    // We should send replyToApplicationShouldTerminate: to NSApp from
    // AKTelephoneUserAgentDidFinishStoppingNotification.
    return NSTerminateLater;
  }
  
  return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  // TODO(eofster): we should save preferences on quit.
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


#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate protocol

- (void)growlNotificationWasClicked:(id)clickContext
{
  NSString *identifier = (NSString *)clickContext;
  CallController *aCallController = [self callControllerByIdentifier:identifier];
  
  // Make application active.
  if (![NSApp isActive])
    [NSApp activateIgnoringOtherApps:YES];
  
  // Make corresponding call window key.
  [aCallController showWindow:nil];
}


#pragma mark -
#pragma mark NSWorkspace notifications

// End all calls, remove all accounts from Telephone and destroy SIP user agent
// before computer goes to sleep.
- (void)workspaceWillSleep:(NSNotification *)notification
{
  if ([[self telephone] userAgentStarted])
    [self stopTelephone];
}

- (void)workspaceDidWake:(NSNotification *)notification
{
  [NSTimer scheduledTimerWithTimeInterval:3.0
                                   target:self
                                 selector:@selector(startUserAgentAfterDidWakeTick:)
                                 userInfo:nil
                                  repeats:NO];
}

// Unregister all accounts when a user session is switched out.
- (void)workspaceSessionDidResignActive:(NSNotification *)notification
{
  for (AccountController *anAccountController in [self enabledAccountControllers])
    [anAccountController setAccountRegistered:NO];
}

// Re-register all accounts when a user session in switched in.
- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification
{
  for (AccountController *anAccountController in [self enabledAccountControllers])
    [anAccountController setAccountRegistered:YES];
}


#pragma mark -
#pragma mark Address Book plug-in notifications

// TODO(eofster): Here we receive contact's name and call destination (phone or
// SIP address). Then we set text field string value as when the user types in
// the name directly and Telephone autocomplets input. The result is that
// Address Book is being searched to find the person record. As an alternative
// we could send person and selected call destination identifiers and only
// get another destinations here (no new AB search).
// If we change it to work with identifiers, we'll probably want to somehow
// change AccountController's tokenField:representedObjectForEditingString:.
- (void)addressBookDidDialCallDestination:(NSNotification *)notification
{
  // Do nothing if there is a modal window.
  if ([NSApp modalWindow] != nil)
    return;
  
  NSDictionary *userInfo = [notification userInfo];
  
  NSString *callDestination;
  if ([[notification name] isEqualToString:AKAddressBookDidDialPhoneNumberNotification])
    callDestination = [userInfo objectForKey:@"AKPhoneNumber"];
  else if ([[notification name] isEqualToString:AKAddressBookDidDialSIPAddressNotification])
    callDestination = [userInfo objectForKey:@"AKSIPAddress"];

  NSString *fullName = [userInfo objectForKey:@"AKFullName"];
  
  AccountController *firstAccountController
    = [[self accountControllers] objectAtIndex:0];
  
  if (![firstAccountController isEnabled])
    return;
  
  [[firstAccountController callDestinationField] setTokenStyle:NSRoundedTokenStyle];
  
  [NSApp activateIgnoringOtherApps:YES];
  
  NSString *theString;
  if ([fullName length] > 0)
    theString = [NSString stringWithFormat:@"%@ <%@>", fullName, callDestination];
  else
    theString = callDestination;

  [[firstAccountController callDestinationField] setStringValue:theString];
  
  if ([[firstAccountController account] identifier] == kAKTelephoneInvalidIdentifier) {
    // Go Available if it's Offline. Make call from the callback.
    [firstAccountController setShouldMakeCall:YES];
    [firstAccountController setAccountRegistered:YES];
    
  } else {
    [firstAccountController makeCall:[firstAccountController callDestinationField]];
  }
}


#pragma mark -
#pragma mark Apple event handler for URLs support

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
           withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
  AccountController *firstAccountController
    = [[self accountControllers] objectAtIndex:0];
  
  if (![firstAccountController isEnabled])
    return;
  
  NSString *URLString = [[event paramDescriptorForKeyword:keyDirectObject]
                         stringValue];
  
  [firstAccountController setCatchedURLString:URLString];
  
  if ([[firstAccountController account] identifier] == kAKTelephoneInvalidIdentifier) {
    // Go Available if it's Offline. Make call from the callback.
    [firstAccountController setAccountRegistered:YES];
  } else {
    [firstAccountController handleCatchedURL];
  }
}

@end


#pragma mark -

// Send updateAudioDevices to AppController.
static OSStatus AKAudioDevicesChanged(AudioHardwarePropertyID propertyID,
                                      void *clientData)
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
  
  [pool release];
  
  return noErr;
}

static OSStatus AKGetAudioDevices(Ptr *devices, UInt16 *devicesCount)
{
  OSStatus err = noErr;
  UInt32 size;
  Boolean isWritable;
  
  // Get sound devices count.
  err = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &size,
                                     &isWritable);
  if (err != noErr)
    return err;
  
  *devicesCount = size / sizeof(AudioDeviceID);
  if (*devicesCount < 1)
    return err;
  
  // Allocate space for devices.
  *devices = (Ptr)malloc(size);
  memset(*devices, 0, size);
  
  // Get the data.
  err = AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &size,
                                 (void *)*devices);
  if (err != noErr)
    return err;
  
  return err;
}


// Growl notification names.
NSString * const kGrowlNotificationIncomingCall = @"Incoming Call";
NSString * const kGrowlNotificationCallEnded = @"Call Ended";
