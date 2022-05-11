//
//  AppController.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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
#import "NameServers.h"
#import "PreferencesController.h"

#import "Telephone-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppController () <AKSIPUserAgentDelegate, NSUserNotificationCenterDelegate, NameServersChangeEventTarget, PreferencesControllerDelegate, ObjCStoreEventTarget>

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;
@property(nonatomic, readonly) AccountControllers *accountControllers;
@property(nonatomic, readonly) AccountSetupController *accountSetupController;
@property(nonatomic) BOOL shouldRegisterAllAccounts;
@property(nonatomic) BOOL shouldRestartUserAgentASAP;
@property(nonatomic, getter=isTerminating) BOOL terminating;
@property(nonatomic) BOOL shouldPresentUserAgentLaunchError;
@property(nonatomic) AccountsMenuItems *accountsMenuItems;
@property(nonatomic, weak) IBOutlet NSMenu *windowMenu;
@property(nonatomic, weak) IBOutlet NSMenuItem *preferencesMenuItem;
@property(nonatomic, weak) IBOutlet HelpMenuActionRedirect *helpMenuActionRedirect;

@property(nonatomic, readonly) CompositionRoot *compositionRoot;
@property(nonatomic, readonly) PreferencesController *preferencesController;
@property(nonatomic, readonly) StoreWindowPresenter *storeWindowPresenter;
@property(nonatomic, readonly) id<RingtonePlaybackUseCase> ringtonePlayback;
@property(nonatomic, readonly) id<UseCase> userAgentStart;
@property(nonatomic, readonly) WorkspaceSleepStatus *sleepStatus;
@property(nonatomic, readonly) AsyncCallHistoryViewEventTargetFactory *callHistoryViewEventTargetFactory;
@property(nonatomic, readonly) AsyncCallHistoryPurchaseCheckUseCaseFactory *purchaseCheckUseCaseFactory;
@property(nonatomic, getter=isFinishedLaunching) BOOL finishedLaunching;
@property(nonatomic, copy) NSString *destinationToCall;
@property(nonatomic, getter=isUserSessionActive) BOOL userSessionActive;
@property(nonatomic, readonly) NameServers *nameServers;

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

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _compositionRoot = [[CompositionRoot alloc] initWithPreferencesControllerDelegate:self
                                                         nameServersChangeEventTarget:self
                                                                     storeEventTarget:self];
    
    _userAgent = _compositionRoot.userAgent;
    [[self userAgent] setDelegate:self];
    _preferencesController = _compositionRoot.preferencesController;
    _storeWindowPresenter = _compositionRoot.storeWindowPresenter;
    _ringtonePlayback = _compositionRoot.ringtonePlayback;
    _userAgentStart = _compositionRoot.userAgentStart;
    _sleepStatus = _compositionRoot.workstationSleepStatus;
    _callHistoryViewEventTargetFactory = _compositionRoot.callHistoryViewEventTargetFactory;
    _purchaseCheckUseCaseFactory = _compositionRoot.callHistoryPurchaseCheckUseCaseFactory;
    _destinationToCall = @"";
    _userSessionActive = YES;
    _accountControllers = _compositionRoot.accountControllers;
    _nameServers = _compositionRoot.nameServers;
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

- (void)restartUserAgentAfterDelayOrMarkForRestart {
    if (!self.accountControllers.haveActiveCallControllers) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartUserAgent) object:nil];
        [self performSelector:@selector(restartUserAgent) withObject:nil afterDelay:3.0];
    } else {
        self.shouldRestartUserAgentASAP = YES;
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

- (void)showAccountPreferencesIfNeeded {
    if (self.accountControllers.enabled.count == 0)  {
        [self.preferencesController showWindowCentered];
        [self.preferencesController showAccounts];
    }
}

- (AccountController *)accountControllerWithDictionary:(NSDictionary *)dict {
    AKSIPAccount *account = [[AKSIPAccount alloc] initWithDictionary:dict parser:self.userAgent.parser];

    NSString *description = dict[AKSIPAccountKeys.desc];
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

    [controller setEnabled:[dict[UserDefaultsKeys.accountEnabled] boolValue]];
    [controller setSubstitutesPlusCharacter:[dict[UserDefaultsKeys.substitutePlusCharacter] boolValue]];
    [controller setPlusCharacterSubstitution:dict[UserDefaultsKeys.plusCharacterSubstitutionString]];

    return controller;
}


#pragma mark -
#pragma mark AccountSetupController delegate

- (void)accountSetupControllerDidAddAccount:(NSNotification *)notification {
    AccountController *controller = [self accountControllerWithDictionary:notification.userInfo];
    
    [self.accountControllers addController:controller];
    [self.accountControllers updateCallsShouldDisplayAccountInfo];
    [self.accountsMenuItems update];
    
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
    [self.accountsMenuItems update];
}

- (void)preferencesControllerDidChangeAccountEnabled:(NSNotification *)notification {
    NSUInteger index = [[notification userInfo][kAccountIndex] integerValue];
    
    NSDictionary *account = [NSUserDefaults.standardUserDefaults arrayForKey:UserDefaultsKeys.accounts][index];

    if ([account[UserDefaultsKeys.accountEnabled] boolValue]) {
        AccountController *controller = [self accountControllerWithDictionary:account];
        [controller setAccountUnavailable:NO];

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
    [self.accountsMenuItems update];
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
    
    [self.accountsMenuItems update];
}

- (void)preferencesControllerDidChangeNetworkSettings:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[self userAgent] setTransportPort:[defaults integerForKey:UserDefaultsKeys.transportPort]];
    [[self userAgent] setSTUNServerHost:[defaults stringForKey:UserDefaultsKeys.stunServerHost]];
    [[self userAgent] setSTUNServerPort:[defaults integerForKey:UserDefaultsKeys.stunServerPort]];
    [[self userAgent] setUsesICE:[defaults boolForKey:UserDefaultsKeys.useICE]];
    [[self userAgent] setOutboundProxyHost:[defaults stringForKey:UserDefaultsKeys.outboundProxyHost]];
    [[self userAgent] setOutboundProxyPort:[defaults integerForKey:UserDefaultsKeys.outboundProxyPort]];
    
    if ([defaults boolForKey:UserDefaultsKeys.useDNSSRV]) {
        [[self userAgent] setNameServers:self.nameServers.all];
    } else {
        [[self userAgent] setNameServers:nil];
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
            [self.userAgentStart execute];
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
            [[self userAgentStart] execute];
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow.allowsAutomaticWindowTabbing = NO;
    [self.compositionRoot.defaultAppSettings registerDefaults];
    [self.compositionRoot.settingsMigration execute];
    self.helpMenuActionRedirect.target = self.compositionRoot.helpMenuActionTarget;
    [self configureUserAgent];
    self.accountsMenuItems = [[AccountsMenuItems alloc] initWithMenu:self.windowMenu controllers:self.accountControllers];
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
    NSApp.servicesProvider = self;
    NSArray *accounts = [NSUserDefaults.standardUserDefaults arrayForKey:UserDefaultsKeys.accounts];
    if (accounts.count == 0) {
        [[self preferencesMenuItem] setAction:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowWillClose:)
                                                     name:NSWindowWillCloseNotification
                                                   object:[[self accountSetupController] window]];
        [[[self accountSetupController] defaultButton] setTarget:self];
        [[[self accountSetupController] defaultButton] setAction:@selector(addAccountOnFirstLaunch:)];
        [[[self accountSetupController] otherButton] setTarget:[[self accountSetupController] window]];
        [[[self accountSetupController] otherButton] setAction:@selector(performClose:)];
        [[[self accountSetupController] window] center];
        [[[self accountSetupController] window] makeKeyAndOrderFront:self];
        return;
    }
    for (NSUInteger i = 0; i < accounts.count; ++i) {
        AccountController *controller = [self accountControllerWithDictionary:accounts[i]];
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
    [self.accountsMenuItems update];
    [self setShouldPresentUserAgentLaunchError:YES];
    [self remindAboutPurchasingAfterDelay];
    [self.accountControllers registerAllAccountsWhereManualRegistrationRequired];
    [self makeCallAfterLaunchIfNeeded];
    [self.compositionRoot.orphanLogFileRemoval performSelector:@selector(execute) withObject:nil afterDelay:0];
    [self showAccountPreferencesIfNeeded];
    [self setFinishedLaunching:YES];
}

- (void)configureUserAgent {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults boolForKey:UserDefaultsKeys.useDNSSRV]) {
        self.userAgent.nameServers = self.nameServers.all;
    }
    self.userAgent.outboundProxyHost = [defaults stringForKey:UserDefaultsKeys.outboundProxyHost];
    self.userAgent.outboundProxyPort = [defaults integerForKey:UserDefaultsKeys.outboundProxyPort];
    self.userAgent.STUNServerHost = [defaults stringForKey:UserDefaultsKeys.stunServerHost];
    self.userAgent.STUNServerPort = [defaults integerForKey:UserDefaultsKeys.stunServerPort];
    self.userAgent.userAgentString = [NSString stringWithFormat:@"%@ %@",
                                      NSBundle.mainBundle.infoDictionary[@"CFBundleName"],
                                      NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]];
    self.userAgent.logFileName = self.compositionRoot.logFileURL.pathValue;
    self.userAgent.logLevel = [defaults integerForKey:UserDefaultsKeys.logLevel];
    self.userAgent.consoleLogLevel = [defaults integerForKey:UserDefaultsKeys.consoleLogLevel];
    self.userAgent.detectsVoiceActivity = [defaults boolForKey:UserDefaultsKeys.voiceActivityDetection];
    self.userAgent.usesICE = [defaults boolForKey:UserDefaultsKeys.useICE];
    self.userAgent.usesQoS = [defaults boolForKey:UserDefaultsKeys.useQoS];
    self.userAgent.transportPort = [defaults integerForKey:UserDefaultsKeys.transportPort];
    self.userAgent.usesG711Only = [defaults boolForKey:UserDefaultsKeys.useG711Only];
    self.userAgent.locksCodec = [defaults boolForKey:UserDefaultsKeys.lockCodec];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if (self.userAgent.hasUnansweredIncomingCalls) {
        [self.accountControllers showIncomingCallWindows];
    } else if ([NSApp keyWindow] == nil && self.accountControllers.enabled.count > 0) {
        [self.accountControllers.enabled.firstObject showWindow];
    }
    return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [NSUserNotificationCenter.defaultUserNotificationCenter removeAllDeliveredNotifications];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (self.accountControllers.haveActiveCallControllers) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"Quit", @"Quit button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")].keyEquivalent = @"\033";
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
}

- (void)SIPCallConnecting:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [self updateDockTileBadgeLabel];
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
        NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:UserDefaultsKeys.accounts]];
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:accounts[index]];
        account[AKSIPAccountKeys.username] = controller.account.username;
        accounts[index] = account;
        [defaults setObject:accounts forKey:UserDefaultsKeys.accounts];
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
    if ([pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        [self makeCallOrRememberDestination:[pboard stringForType:NSPasteboardTypeString]];
    } else {
        NSLog(@"Could not make call, pboard couldn't give string.");
    }
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

#pragma mark - NameServersChangeEventTarget

- (void)nameServersDidChange:(NameServers *)nameServers {
    NSArray *servers = nameServers.all;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultsKeys.useDNSSRV] &&
        servers.count > 0 &&
        ![self.userAgent.nameServers isEqualToArray:servers]) {

        self.userAgent.nameServers = servers;
        [self restartUserAgentAfterDelayOrMarkForRestart];
    }
}

#pragma mark - ObjCStoreEventTarget

- (void)didPurchase {
    [self restartUserAgentAfterDelayOrMarkForRestart];
}

@end
