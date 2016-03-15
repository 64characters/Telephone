//
//  AppController.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

#import <Cocoa/Cocoa.h>

#import "AKSIPUserAgent.h"


/// NSUserNotification user info dictionary key containing call controller identifier.
extern NSString * const kUserNotificationCallControllerIdentifierKey;

// Growl notification names.
extern NSString * const kGrowlNotificationIncomingCall;
extern NSString * const kGrowlNotificationCallEnded;

@class AKSIPUserAgent, PreferencesController, CallController;
@class AccountSetupController;

// Application controller and NSApplication delegate.
@interface AppController : NSObject <AKSIPUserAgentDelegate>

// SIP user agent.
@property(nonatomic, readonly, strong) AKSIPUserAgent *userAgent;

// An array of account controllers.
@property(nonatomic, readonly, strong) NSMutableArray *accountControllers;

// An array of account controllers which are currently enabled.
@property(nonatomic, readonly, strong) NSArray *enabledAccountControllers;

// Account setup controller.
@property(nonatomic, readonly) AccountSetupController *accountSetupController;

// A Boolean value indicating whether accounts should be registered ASAP, e.g. when the user agent finishes starting.
@property(nonatomic, assign) BOOL shouldRegisterAllAccounts;

// A Boolean value indicating whether user agent should be restarted ASAP.
@property(nonatomic, assign) BOOL shouldRestartUserAgentASAP;

// A Boolean value indicating whether application is terminating.
// We need to destroy the user agent gracefully on quit.
@property(nonatomic, assign, getter=isTerminating) BOOL terminating;

// A Boolean value indicating whether there are any call controllers with the incoming calls.
@property(nonatomic, readonly, assign) BOOL hasIncomingCallControllers;

// A Boolean value indicating whether there are any call controllers with the active calls.
@property(nonatomic, readonly, assign) BOOL hasActiveCallControllers;

// An array of nameservers currently in use in the OS.
@property(nonatomic, readonly, strong) NSArray *currentNameservers;

// A Boolean value indicating whether the receiver has paused iTunes.
@property(nonatomic, assign) BOOL didPauseITunes;

// A Boolean value indicating whether user agent launch error should be presented to the user.
@property(nonatomic, assign) BOOL shouldPresentUserAgentLaunchError;

// Unhandled incoming calls count.
@property(nonatomic, readonly, assign) NSUInteger unhandledIncomingCallsCount;

// Timer for bouncing icon in the Dock.
@property(nonatomic, strong) NSTimer *userAttentionTimer;

// Accounts menu items to show in windows menu.
@property(nonatomic, strong) NSArray *accountsMenuItems;

// Application Window menu.
@property(nonatomic, weak) IBOutlet NSMenu *windowMenu;

// Preferences menu item outlet.
@property(nonatomic, weak) IBOutlet NSMenuItem *preferencesMenuItem;

// Stops and destroys SIP user agent hanging up all calls and unregistering all accounts.
- (void)stopUserAgent;

// A shortcut to restart user agent. Sets appropriate flags to start user agent, and then calls |stopUserAgent|.
- (void)restartUserAgent;

// Shows preferences window.
- (IBAction)showPreferencePanel:(id)sender;

// Adds an account on first application launch.
- (IBAction)addAccountOnFirstLaunch:(id)sender;

- (BOOL)canStopPlayingRingtone;

// Starts a timer for bouncing icon in the Dock.
- (void)startUserAttentionTimer;

// Stops a timer for bouncing icon in the Dock if needed.
- (void)stopUserAttentionTimerIfNeeded;

// Method to be called when a user attention timer fires.
- (void)requestUserAttentionTick:(NSTimer *)theTimer;

// Pauses iTunes.
- (void)pauseITunes;

// Resumes iTunes if needed.
- (void)resumeITunesIfNeeded;

// Returns a call controller with a given identifier.
- (CallController *)callControllerByIdentifier:(NSString *)identifier;

// Updates Dock tile badge label.
- (void)updateDockTileBadgeLabel;

// Updates accounts menu items.
- (void)updateAccountsMenuItems;

// Makes account winfow key or hides it.
- (IBAction)toggleAccountWindow:(id)sender;

// Installs Address Book plug-ins to |~/Library/Address Book Plug-Ins|. Updates plug-ins if the installed versions are
// outdated. Does not guaranteed to return a valid |error| if the method returns NO.
- (BOOL)installAddressBookPlugInsAndReturnError:(NSError **)error;

// Returns a localized string describing a given SIP response code.
- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode;

@end
