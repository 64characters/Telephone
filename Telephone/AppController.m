//
//  AppController.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import "AppController.h"

@import SystemConfiguration;
@import UseCases;

#import "AKAddressBookPhonePlugIn.h"
#import "AKAddressBookSIPAddressPlugIn.h"
#import "AKNetworkReachability.h"
#import "AKNSString+Scanning.h"
#import "AKSIPAccount.h"
#import "AKSIPCall.h"

#import "AccountController.h"
#import "AccountControllers.h"
#import "AccountPreferencesViewController.h"
#import "AccountSetupController.h"
#import "ActiveAccountViewController.h"
#import "AuthenticationFailureController.h"
#import "CallController.h"
#import "PreferencesController.h"
#import "UserDefaultsKeys.h"

#import "Telephone-Swift.h"


// Bouncing icon in the Dock time interval.
static const NSTimeInterval kUserAttentionRequestInterval = 8.0;

// Delay for restarting user agent when DNS servers change.
static const NSTimeInterval kUserAgentRestartDelayAfterDNSChange = 3.0;

static NSString * const kDynamicStoreDNSSettings = @"State:/Network/Global/DNS";
static NSArray *CurrentNameservers(void);
static void InstallNameserversChangesCallback(void);
static void NameserversDidChange(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info);

NS_ASSUME_NONNULL_BEGIN

@interface AppController () <AKSIPUserAgentDelegate, NSUserNotificationCenterDelegate, PreferencesControllerDelegate>

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;
@property(nonatomic, readonly) AccountControllers *accountControllers;
@property(nonatomic, readonly) AccountSetupController *accountSetupController;
@property(nonatomic) BOOL shouldRegisterAllAccounts;
@property(nonatomic) BOOL shouldRestartUserAgentASAP;
@property(nonatomic, getter=isTerminating) BOOL terminating;
@property(nonatomic) BOOL shouldPresentUserAgentLaunchError;
@property(nonatomic, nullable) NSTimer *userAttentionTimer;
@property(nonatomic) NSArray *accountsMenuItems;
@property(nonatomic, weak) IBOutlet NSMenu *windowMenu;
@property(nonatomic, weak) IBOutlet NSMenuItem *preferencesMenuItem;
@property(nonatomic, weak) IBOutlet HelpMenuActionRedirect *helpMenuActionRedirect;

@property(nonatomic, readonly) CompositionRoot *compositionRoot;
@property(nonatomic, readonly) PreferencesController *preferencesController;
@property(nonatomic, readonly) StoreWindowPresenter *storeWindowPresenter;
@property(nonatomic, readonly) id<RingtonePlaybackUseCase> ringtonePlayback;
@property(nonatomic, readonly) WorkspaceSleepStatus *sleepStatus;
@property(nonatomic, readonly) AsyncCallHistoryViewEventTargetFactory *callHistoryViewEventTargetFactory;
@property(nonatomic, readonly) AsyncCallHistoryPurchaseCheckUseCaseFactory *purchaseCheckUseCaseFactory;
@property(nonatomic, getter=isFinishedLaunching) BOOL finishedLaunching;
@property(nonatomic, copy) NSString *destinationToCall;
@property(nonatomic, getter=isUserSessionActive) BOOL userSessionActive;

@end

NS_ASSUME_NONNULL_END


@implementation AppController

@synthesize accountSetupController = _accountSetupController;

- (AccountSetupController *)accountSetupController {
    if (_accountSetupController == nil) {
        _accountSetupController = [[AccountSetupController alloc] init];
    }
    return _accountSetupController;
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
        defaultsDict[kLogLevel] = @3;
        defaultsDict[kConsoleLogLevel] = @0;
        defaultsDict[kTransportPort] = @0;
        defaultsDict[kTransportPublicHost] = @"";
        defaultsDict[kRingingSound] = @"Purr";
        defaultsDict[kSignificantPhoneNumberLength] = @9;
        defaultsDict[kAutoCloseCallWindow] = @YES;
        defaultsDict[kAutoCloseMissedCallWindow] = @YES;
        defaultsDict[kCallWaiting] = @YES;
        defaultsDict[kUseG711Only] = @NO;
        defaultsDict[kLockCodec] = @NO;

        NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
        
        // Do not format phone numbers in German localization by default.
        if ([preferredLocalization isEqualToString:@"de"]) {
            defaultsDict[kFormatTelephoneNumbers] = @NO;
        } else {
            defaultsDict[kFormatTelephoneNumbers] = @YES;
        }
        
        // Split last four digits in Russian localization by default.
        if ([preferredLocalization isEqualToString:@"ru"]) {
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

    _compositionRoot = [[CompositionRoot alloc] initWithPreferencesControllerDelegate:self conditionalRingtonePlaybackUseCaseDelegate:self];
    
    _userAgent = _compositionRoot.userAgent;
    [[self userAgent] setDelegate:self];
    _preferencesController = _compositionRoot.preferencesController;
    _storeWindowPresenter = _compositionRoot.storeWindowPresenter;
    _ringtonePlayback = _compositionRoot.ringtonePlayback;
    _sleepStatus = _compositionRoot.workstationSleepStatus;
    _callHistoryViewEventTargetFactory = _compositionRoot.callHistoryViewEventTargetFactory;
    _purchaseCheckUseCaseFactory = _compositionRoot.callHistoryPurchaseCheckUseCaseFactory;
    _destinationToCall = @"";
    _userSessionActive = YES;
    _accountControllers = [[AccountControllers alloc] init];
    _accountsMenuItems = @[];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(accountSetupControllerDidAddAccount:)
                               name:AKAccountSetupControllerDidAddAccountNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallCalling:)
                               name:AKSIPCallCallingNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallIncoming:)
                               name:AKSIPCallIncomingNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallConnecting:)
                               name:AKSIPCallConnectingNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(SIPCallDidDisconnect:)
                               name:AKSIPCallDidDisconnectNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(authenticationFailureControllerDidChangeUsernameAndPassword:)
                               name:AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
                             object:nil];
    
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
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopUserAgent {
    [self.accountControllers hangUpCallsAndRemoveAccountsFromUserAgent];
    [self.userAgent stop];
}

- (void)stopUserAgentAndWait {
    [self.accountControllers hangUpCallsAndRemoveAccountsFromUserAgent];
    [self.userAgent stopAndWait];
}

- (void)restartUserAgent {
    if ([[self userAgent] isStarted]) {
        [self setShouldRegisterAllAccounts:YES];
        [self stopUserAgent];
    }
}

- (IBAction)showStoreWindow:(id)sender {
    [self.storeWindowPresenter present];
}

- (IBAction)showPreferencePanel:(id)sender {
    [self.preferencesController showWindowCentered];
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
        
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        InstallNameserversChangesCallback();
    }
}

- (BOOL)canStopPlayingRingtone {
    return !self.accountControllers.haveIncomingCallControllers;
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

- (void)stopUserAttentionTimer {
    if (self.userAttentionTimer != nil) {
        [self.userAttentionTimer invalidate];
        self.userAttentionTimer = nil;
    }
}

- (void)stopUserAttentionTimerIfNeeded {
    if (!self.accountControllers.haveIncomingCallControllers) {
        [self stopUserAttentionTimer];
    }
}

- (void)requestUserAttentionTick:(NSTimer *)theTimer {
    [NSApp requestUserAttention:NSInformationalRequest];
}

- (void)updateAccountsMenuItems {
    // Remove old menu items.
    for (NSMenuItem *item in [self accountsMenuItems]) {
        [[self windowMenu] removeItem:item];
    }
    
    // Create new menu items.
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSUInteger accountNumber = 1;
    for (AccountController *accountController in self.accountControllers.enabled) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        [menuItem setRepresentedObject:accountController];
        [menuItem setAction:@selector(toggleAccountWindow:)];
        [menuItem setTitle:[accountController accountDescription]];
        if (accountNumber < 10) {
            // Only add key equivalents for Command-[1..9].
            [menuItem setKeyEquivalent:[NSString stringWithFormat:@"%lu", accountNumber]];
        }
        [items addObject:menuItem];
        accountNumber++;
    }
    if (items.count > 0) {
        [items insertObject:[NSMenuItem separatorItem] atIndex:0];
    }
    [self setAccountsMenuItems:items];
    
    // Add menu items to the Window menu.
    NSUInteger tag = 4;
    for (NSMenuItem *item in items) {
        [[self windowMenu] insertItem:item atIndex:tag];
        tag++;
    }
}

- (IBAction)toggleAccountWindow:(id)sender {
    AccountController *controller = [sender representedObject];
    if (controller.isWindowKey) {
        [controller hideWindow];
    } else {
        [controller showWindow];
    }
}

- (void)updateDockTileBadgeLabel {
    NSString *badgeString;
    NSInteger badgeNumber = self.accountControllers.unhandledIncomingCallsCount;
    if (badgeNumber == 0) {
        badgeString = @"";
    } else {
        badgeString = [NSString stringWithFormat:@"%ld", badgeNumber];
    }
    
    [[NSApp dockTile] setBadgeLabel:badgeString];
}

- (void)remindAboutPurchasingAfterDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.compositionRoot.purchaseReminder execute];
    });
}

- (void)optOutOfAutomaticWindowTabbing {
    if ([NSWindow respondsToSelector:@selector(allowsAutomaticWindowTabbing)]) {
        NSWindow.allowsAutomaticWindowTabbing = NO;
    }
}

- (void)showAccountPreferencesIfNeeded {
    if (self.accountControllers.enabled.count == 0)  {
        [self.preferencesController showWindowCentered];
        [self.preferencesController showAccounts];
    }
}


#pragma mark -
#pragma mark AccountSetupController delegate

- (void)accountSetupControllerDidAddAccount:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    
    AKSIPAccount *account = [[AKSIPAccount alloc] initWithUUID:dict[kUUID]
                                                      fullName:dict[kFullName]
                                                    SIPAddress:dict[kSIPAddress]
                                                     registrar:dict[kDomain]
                                                         realm:dict[kRealm]
                                                      username:dict[kUsername]
                                                        domain:dict[kDomain]];
    
    AccountController *controller = [[AccountController alloc] initWithSIPAccount:account
                                                               accountDescription:account.SIPAddress
                                                                        userAgent:self.userAgent
                                                                 ringtonePlayback:self.ringtonePlayback
                                                                      sleepStatus:self.sleepStatus
                                                callHistoryViewEventTargetFactory:self.callHistoryViewEventTargetFactory
                                                      purchaseCheckUseCaseFactory:self.purchaseCheckUseCaseFactory
                                                             storeWindowPresenter:self.storeWindowPresenter];
    controller.enabled = YES;
    
    [self.accountControllers addController:controller];
    [self.accountControllers updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
    
    [controller showWindowWithoutMakingKey];

    [self.accountControllers registerAccountIfManualRegistrationRequired:controller];
}


#pragma mark -
#pragma mark PreferencesController delegate

- (void)preferencesControllerDidRemoveAccount:(NSNotification *)notification {
    NSInteger index = [notification.userInfo[kAccountIndex] integerValue];
    AccountController *controller = self.accountControllers[index];
    
    if ([controller isEnabled]) {
        [controller removeAccountFromUserAgent];
    }
    
    [self.accountControllers removeControllerAtIndex:index];
    [self.accountControllers updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
}

- (void)preferencesControllerDidChangeAccountEnabled:(NSNotification *)notification {
    NSUInteger index = [[notification userInfo][kAccountIndex] integerValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
    NSDictionary *accountDict = savedAccounts[index];
    
    BOOL isEnabled = [accountDict[kAccountEnabled] boolValue];
    if (isEnabled) {
        AKSIPAccount *account = [[AKSIPAccount alloc] initWithUUID:accountDict[kUUID]
                                                          fullName:accountDict[kFullName]
                                                        SIPAddress:accountDict[kSIPAddress]
                                                         registrar:accountDict[kRegistrar]
                                                             realm:accountDict[kRealm]
                                                          username:accountDict[kUsername]
                                                            domain:accountDict[kDomain]];

        account.reregistrationTime = [accountDict[kReregistrationTime] integerValue];
        if ([accountDict[kUseProxy] boolValue]) {
            account.proxyHost = accountDict[kProxyHost];
            account.proxyPort = [accountDict[kProxyPort] integerValue];
        }
        account.updatesContactHeader = [accountDict[kUpdateContactHeader] boolValue];
        account.updatesViaHeader = [accountDict[kUpdateViaHeader] boolValue];

        NSString *description = accountDict[kDescription];
        if ([description length] == 0) {
            description = account.SIPAddress;
        }
        
        AccountController *controller = [[AccountController alloc] initWithSIPAccount:account
                                                                   accountDescription:description
                                                                            userAgent:self.userAgent
                                                                     ringtonePlayback:self.ringtonePlayback
                                                                          sleepStatus:self.sleepStatus
                                                    callHistoryViewEventTargetFactory:self.callHistoryViewEventTargetFactory
                                                          purchaseCheckUseCaseFactory:self.purchaseCheckUseCaseFactory
                                                                 storeWindowPresenter:self.storeWindowPresenter];
        [controller setAccountUnavailable:NO];
        [controller setEnabled:YES];
        [controller setSubstitutesPlusCharacter:[accountDict[kSubstitutePlusCharacter] boolValue]];
        [controller setPlusCharacterSubstitution:accountDict[kPlusCharacterSubstitutionString]];
        
        self.accountControllers[index] = controller;
        
        [controller showWindowWithoutMakingKey];

        [self.accountControllers registerAccountIfManualRegistrationRequired:controller];
        
    } else {
        AccountController *controller = self.accountControllers[index];
        
        // Close all call windows hanging up all calls.
        [[controller callControllers] makeObjectsPerformSelector:@selector(close)];
        
        // Remove account from the user agent.
        [controller removeAccountFromUserAgent];
        [controller setEnabled:NO];
        [controller setAttemptingToRegisterAccount:NO];
        [controller setAttemptingToUnregisterAccount:NO];
        [controller setShouldPresentRegistrationError:NO];
        [controller hideWindow];
    }
    
    [self.accountControllers updateCallsShouldDisplayAccountInfo];
    [self updateAccountsMenuItems];
}

- (void)preferencesControllerDidSwapAccounts:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSInteger sourceIndex = [userInfo[kSourceIndex] integerValue];
    NSInteger destinationIndex = [userInfo[kDestinationIndex] integerValue];
    
    if (sourceIndex == destinationIndex) {
        return;
    }
    
    [self.accountControllers insertController:self.accountControllers[sourceIndex] atIndex:destinationIndex];
    if (sourceIndex < destinationIndex) {
        [self.accountControllers removeControllerAtIndex:sourceIndex];
    } else if (sourceIndex > destinationIndex) {
        [self.accountControllers removeControllerAtIndex:(sourceIndex + 1)];
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
        [[self userAgent] setNameservers:CurrentNameservers()];
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

- (BOOL)SIPUserAgentShouldAddAccount:(AKSIPAccount *)account {
    if (self.userAgent.isStarted) {
        return YES;
    } else {
        if (self.userAgent.state == AKSIPUserAgentStateStopped) {
            [self.userAgent start];
        }
        return NO;
    }
}

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    if ([[self userAgent] isStarted]) {
        if ([self shouldRegisterAllAccounts]) {
            [self.accountControllers registerAllAccounts];
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
            for (AccountController *controller in self.accountControllers.enabled) {
                if ([controller shouldPresentRegistrationError]) {
                    [self setShouldPresentUserAgentLaunchError:YES];
                    [controller setAttemptingToRegisterAccount:NO];
                    [controller setAttemptingToUnregisterAccount:NO];
                    [controller setShouldPresentRegistrationError:NO];
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
        if (self.accountControllers.enabled.count > 0) {
            [[self userAgent] start];
        } else {
            [self setShouldRegisterAllAccounts:NO];
        }
    }
}

- (void)SIPUserAgentDidDetectNAT:(NSNotification *)notification {
    if ([[self userAgent] detectedNATType] != kAKNATTypeBlocked) {
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];

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

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSFullScreenMenuItemEverywhere"];
}

// Application control starts here.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self optOutOfAutomaticWindowTabbing];

    [self.compositionRoot.settingsMigration execute];

    self.helpMenuActionRedirect.target = self.compositionRoot.helpMenuActionTarget;
    
    // Read main settings from defaults.
    if ([defaults boolForKey:kUseDNSSRV]) {
        [[self userAgent] setNameservers:CurrentNameservers()];
    }
    
    [[self userAgent] setOutboundProxyHost:[defaults stringForKey:kOutboundProxyHost]];
    
    [[self userAgent] setOutboundProxyPort:[defaults integerForKey:kOutboundProxyPort]];
    
    [[self userAgent] setSTUNServerHost:[defaults stringForKey:kSTUNServerHost]];
    
    [[self userAgent] setSTUNServerPort:[defaults integerForKey:kSTUNServerPort]];
    
    NSString *bundleName = [mainBundle infoDictionary][@"CFBundleName"];
    NSString *bundleShortVersion = [mainBundle infoDictionary][@"CFBundleShortVersionString"];
    
    [[self userAgent] setUserAgentString:[NSString stringWithFormat:@"%@ %@", bundleName, bundleShortVersion]];
    [[self userAgent] setLogFileName:self.compositionRoot.logFileURL.pathValue];
    [[self userAgent] setLogLevel:[defaults integerForKey:kLogLevel]];
    [[self userAgent] setConsoleLogLevel:[defaults integerForKey:kConsoleLogLevel]];
    [[self userAgent] setDetectsVoiceActivity:[defaults boolForKey:kVoiceActivityDetection]];
    [[self userAgent] setUsesICE:[defaults boolForKey:kUseICE]];
    [[self userAgent] setTransportPort:[defaults integerForKey:kTransportPort]];
    [[self userAgent] setTransportPublicHost:[defaults stringForKey:kTransportPublicHost]];
    [[self userAgent] setUsesG711Only:[defaults boolForKey:kUseG711Only]];
    [[self userAgent] setLocksCodec:[defaults boolForKey:kLockCodec]];

    NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
    
    // Setup an account on first launch.
    if (savedAccounts.count == 0) {
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
    for (NSUInteger i = 0; i < savedAccounts.count; ++i) {
        NSDictionary *accountDict = savedAccounts[i];

        AKSIPAccount *account = [[AKSIPAccount alloc] initWithUUID:accountDict[kUUID]
                                                          fullName:accountDict[kFullName]
                                                        SIPAddress:accountDict[kSIPAddress]
                                                         registrar:accountDict[kRegistrar]
                                                             realm:accountDict[kRealm]
                                                          username:accountDict[kUsername]
                                                            domain:accountDict[kDomain]];

        account.reregistrationTime = [accountDict[kReregistrationTime] integerValue];
        if ([accountDict[kUseProxy] boolValue]) {
            account.proxyHost = accountDict[kProxyHost];
            account.proxyPort = [accountDict[kProxyPort] integerValue];
        }
        account.updatesContactHeader = [accountDict[kUpdateContactHeader] boolValue];
        account.updatesViaHeader = [accountDict[kUpdateViaHeader] boolValue];

        NSString *description = accountDict[kDescription];
        if ([description length] == 0) {
            description = account.SIPAddress;
        }
        
        AccountController *controller = [[AccountController alloc] initWithSIPAccount:account
                                                                   accountDescription:description
                                                                            userAgent:self.userAgent
                                                                     ringtonePlayback:self.ringtonePlayback
                                                                          sleepStatus:self.sleepStatus
                                                    callHistoryViewEventTargetFactory:self.callHistoryViewEventTargetFactory
                                                          purchaseCheckUseCaseFactory:self.purchaseCheckUseCaseFactory
                                                                 storeWindowPresenter:self.storeWindowPresenter];

        [controller setEnabled:[accountDict[kAccountEnabled] boolValue]];
        [controller setSubstitutesPlusCharacter:[accountDict[kSubstitutePlusCharacter] boolValue]];
        [controller setPlusCharacterSubstitution:accountDict[kPlusCharacterSubstitutionString]];
        
        [self.accountControllers addController:controller];
        
        if (![controller isEnabled]) {
            continue;
        }
        
        if (i == 0) {
            [controller showWindow];
        } else {
            AccountController *previous = self.accountControllers[i - 1];
            [controller orderWindow:NSWindowBelow relativeTo:previous.windowNumber];
        }
    }
    
    [self.accountControllers updateCallsShouldDisplayAccountInfo];
    
    // Update account menu items.
    [self updateAccountsMenuItems];
    
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
    InstallNameserversChangesCallback();
    
    [self setShouldPresentUserAgentLaunchError:YES];
    
    // Register as service provider to allow making calls from the Services
    // menu and context menus.
    [NSApp setServicesProvider:self];

    [self remindAboutPurchasingAfterDelay];
    
    [self.accountControllers registerAllAccountsWhereManualRegistrationRequired];

    [self makeCallAfterLaunchIfNeeded];

    [self.compositionRoot.orphanLogFileRemoval performSelector:@selector(execute) withObject:nil afterDelay:0];

    [self showAccountPreferencesIfNeeded];

    [self setFinishedLaunching:YES];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if (self.accountControllers.haveIncomingCallControllers) {
        [self.accountControllers showIncomingCallWindows];
    } else if ([NSApp keyWindow] == nil && self.accountControllers.enabled.count > 0) {
        [self.accountControllers.enabled.firstObject showWindow];
    }
    return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [self stopUserAttentionTimer];
    [NSUserNotificationCenter.defaultUserNotificationCenter removeAllDeliveredNotifications];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (self.accountControllers.haveActiveCallControllers) {
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
#pragma mark AKSIPCall notifications

- (void)SIPCallCalling:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
}

- (void)SIPCallIncoming:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
    if (![NSApp isActive]) {
        [NSApp requestUserAttention:NSInformationalRequest];
        [self startUserAttentionTimer];
    }
}

- (void)SIPCallConnecting:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
    if ([[notification object] isIncoming]) {
        [self stopUserAttentionTimerIfNeeded];
    }
    if (self.shouldRestartUserAgentASAP && !self.accountControllers.haveActiveCallControllers) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartUserAgent) object:nil];
        [self setShouldRestartUserAgentASAP:NO];
        [self restartUserAgent];
    }
}


#pragma mark -
#pragma mark AuthenticationFailureController notifications

- (void)authenticationFailureControllerDidChangeUsernameAndPassword:(NSNotification *)notification {
    AccountController *controller = [[notification object] accountController];
    NSInteger index = [self.accountControllers indexOfController:controller];
    if (index != NSNotFound) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:accounts[index]];
        account[kUsername] = controller.account.username;
        accounts[index] = account;
        [defaults setObject:accounts forKey:kAccounts];
        AccountPreferencesViewController *viewController = self.preferencesController.accountPreferencesViewController;
        if (viewController.accountsTable.selectedRow == index) {
            [viewController populateFieldsForAccountAtIndex:index];
        }
    }
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    CallController *controller = [self.accountControllers callControllerByIdentifier:notification.identifier];
    switch (notification.activationType) {
        case NSUserNotificationActivationTypeContentsClicked:
            [controller showWindow:self];
            [center removeDeliveredNotification:notification];
            break;
        case NSUserNotificationActivationTypeActionButtonClicked:
            [controller acceptCall];
            break;
        case NSUserNotificationActivationTypeAdditionalActionClicked:
            [controller hangUpCall];
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark NSWorkspace notifications

- (void)workspaceWillSleep:(NSNotification *)notification {
    if (self.userAgent.isStarted) {
        [self stopUserAgentAndWait];
    }
}

- (void)workspaceDidWake:(NSNotification *)notification {
    if (self.isUserSessionActive) {
        [self.accountControllers registerReachableAccounts];
    }
}

- (void)workspaceSessionDidResignActive:(NSNotification *)notification {
    self.userSessionActive = NO;
    [self.accountControllers unregisterAllAccounts];
}

- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification {
    self.userSessionActive = YES;
    [self.accountControllers registerAllAccounts];
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
    [NSApp activateIgnoringOtherApps:YES];
    [self makeCallOrRememberDestination:[self callDestinationWithAddressBookDidDialNotification:notification]];
}

- (NSString *)callDestinationWithAddressBookDidDialNotification:(NSNotification *)notification {
    NSString *SIPAddressOrNumber = nil;
    if ([[notification name] isEqualToString:AKAddressBookDidDialPhoneNumberNotification]) {
        SIPAddressOrNumber = notification.userInfo[@"AKPhoneNumber"];
    } else if ([[notification name] isEqualToString:AKAddressBookDidDialSIPAddressNotification]) {
        SIPAddressOrNumber = notification.userInfo[@"AKSIPAddress"];
    }

    NSString *name = notification.userInfo[@"AKFullName"];

    NSString *result;
    if ([name length] > 0) {
        result = [NSString stringWithFormat:@"%@ <%@>", name, SIPAddressOrNumber];
    } else {
        result = SIPAddressOrNumber;
    }

    return result;
}


#pragma mark -
#pragma mark Apple event handler for URLs support

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    [self makeCallOrRememberDestination:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
}


#pragma mark -
#pragma mark Service Provider

- (void)makeCallFromTextService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    if ([NSPasteboard instancesRespondToSelector:@selector(canReadObjectForClasses:options:)] &&
        ![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        NSLog(@"Could not make call, pboard couldn't give string.");
        return;
    }
    [self makeCallOrRememberDestination:[pboard stringForType:NSPasteboardTypeString]];
}

#pragma mark -

- (void)makeCallAfterLaunchIfNeeded {
    if (self.destinationToCall.length > 0) {
        [self makeCallTo:self.destinationToCall];
        self.destinationToCall = @"";
    }
}

- (void)makeCallOrRememberDestination:(NSString *)destination {
    if (self.isFinishedLaunching) {
        [self makeCallTo:destination];
    } else {
        self.destinationToCall = destination;
    }
}

- (void)makeCallTo:(NSString *)destination {
    if ([self canMakeCall]) {
        [self.accountControllers.enabled.firstObject makeCallToDestinationRegisteringAccountIfNeeded:
         [[SanitizedCallDestination alloc] initWithString:destination]];
    }
}

- (BOOL)canMakeCall {
    return NSApp.modalWindow == nil && self.accountControllers.enabled.count > 0;
}

@end


#pragma mark -

static NSArray *CurrentNameservers() {
    SCDynamicStoreRef store
    = SCDynamicStoreCreate(NULL,
                           (__bridge CFStringRef)[[NSBundle mainBundle] infoDictionary][@"CFBundleName"],
                           NULL,
                           NULL);
    CFPropertyListRef settings = SCDynamicStoreCopyValue(store, (__bridge CFStringRef)kDynamicStoreDNSSettings);
    NSArray *result = nil;
    if (settings != NULL) {
        result = ((__bridge NSDictionary *)settings)[@"ServerAddresses"];
        CFRelease(settings);
    }
    CFRelease(store);
    return result;
}

static void InstallNameserversChangesCallback() {
    SCDynamicStoreRef store
    = SCDynamicStoreCreate(kCFAllocatorDefault,
                           (__bridge CFStringRef)[[NSBundle mainBundle] infoDictionary][@"CFBundleName"],
                           &NameserversDidChange,
                           NULL);
    SCDynamicStoreSetNotificationKeys(store, (__bridge CFArrayRef)@[kDynamicStoreDNSSettings], NULL);
    CFRunLoopSourceRef source = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, store, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    CFRelease(store);
}

static void NameserversDidChange(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info) {
    id appDelegate = [NSApp delegate];
    NSArray *nameservers = CurrentNameservers();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:kUseDNSSRV] &&
        nameservers.count > 0 &&
        ![[[appDelegate userAgent] nameservers] isEqualToArray:nameservers]) {
        
        [[appDelegate userAgent] setNameservers:nameservers];
        
        if (![[appDelegate accountControllers] haveActiveCallControllers]) {
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
