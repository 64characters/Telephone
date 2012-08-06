//
//  AppController.h
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "AKSIPUserAgent.h"


// Audio device dictionary keys.
extern NSString * const kAudioDeviceIdentifier;
extern NSString * const kAudioDeviceUID;
extern NSString * const kAudioDeviceName;
extern NSString * const kAudioDeviceInputsCount;
extern NSString * const kAudioDeviceOutputsCount;

// Growl notification names.
extern NSString * const kGrowlNotificationIncomingCall;
extern NSString * const kGrowlNotificationCallEnded;

@class AKSIPUserAgent, PreferencesController, CallController;
@class AccountSetupController;

// Application controller and NSApplication delegate.
@interface AppController : NSObject <AKSIPUserAgentDelegate,
GrowlApplicationBridgeDelegate> {
 @private
  AKSIPUserAgent *userAgent_;
  NSMutableArray *accountControllers_;
  PreferencesController *preferencesController_;
  AccountSetupController *accountSetupController_;
  NSArray *audioDevices_;
  NSInteger soundInputDeviceIndex_;
  NSInteger soundOutputDeviceIndex_;
  NSInteger ringtoneOutputDeviceIndex_;
  BOOL shouldSetUserAgentSoundIO_;
  NSSound *ringtone_;
  NSTimer *ringtoneTimer_;
  BOOL shouldRegisterAllAccounts_;
  BOOL shouldRestartUserAgentASAP_;
  BOOL terminating_;
  BOOL didPauseITunes_;
  BOOL didPauseRdio_;
  BOOL shouldPresentUserAgentLaunchError_;
  NSTimer *userAttentionTimer_;
  
  NSArray *accountsMenuItems_;
  NSMenu *windowMenu_;
  NSMenuItem *preferencesMenuItem_;
}

// SIP user agent.
@property (nonatomic, readonly, retain) AKSIPUserAgent *userAgent;

// An array of account controllers.
@property (nonatomic, readonly, retain) NSMutableArray *accountControllers;

// An array of account controllers which are currently enabled.
@property (nonatomic, readonly, retain) NSArray *enabledAccountControllers;

// Preferences controller.
@property (nonatomic, readonly) PreferencesController *preferencesController;

// Account setup controller.
@property (nonatomic, readonly) AccountSetupController *accountSetupController;

// An array of audio devices available in the system.
@property (retain) NSArray *audioDevices;

// Index of an audio device for sound input.
@property (nonatomic, assign) NSInteger soundInputDeviceIndex;

// Index of an audio device for sound output.
@property (nonatomic, assign) NSInteger soundOutputDeviceIndex;

// Index of an audio device for a ringtone.
@property (nonatomic, assign) NSInteger ringtoneOutputDeviceIndex;

// A Boolean value indicating whether user agent sound IO should be set as soon
// as needed, e.g. on the next call.
@property (nonatomic, assign) BOOL shouldSetUserAgentSoundIO;

// Incoming call ringtone.
@property (nonatomic, retain) NSSound *ringtone;

// Ringtone timer.
@property (nonatomic, assign) NSTimer *ringtoneTimer;

// A Boolean value indicating whether accounts should be registered ASAP,
// e.g. when the user agent finishes starting.
@property (nonatomic, assign) BOOL shouldRegisterAllAccounts;

// A Boolean value indicating whether user agent should be restarted ASAP.
@property (nonatomic, assign) BOOL shouldRestartUserAgentASAP;

// A Boolean value indicating whether application is terminating.
// We need to destroy the user agent gracefully on quit.
@property (nonatomic, assign, getter=isTerminating) BOOL terminating;

// A Boolean value indicating whether there are any call controllers with
// the incoming calls.
@property (nonatomic, readonly, assign) BOOL hasIncomingCallControllers;

// A Boolean value indicating whether there are any call controllers with
// the active calls.
@property (nonatomic, readonly, assign) BOOL hasActiveCallControllers;

// An array of nameservers currently in use in the OS.
@property (nonatomic, readonly, retain) NSArray *currentNameservers;

// A Boolean value indicating whether the receiver has paused iTunes.
@property (nonatomic, assign) BOOL didPauseITunes;
@property (nonatomic, assign) BOOL didPauseRdio;

// A Boolean value indicating whether user agent launch error should be
// presented to the user.
@property (nonatomic, assign) BOOL shouldPresentUserAgentLaunchError;

// Unhandled incoming calls count.
@property (nonatomic, readonly, assign) NSUInteger unhandledIncomingCallsCount;

// Timer for bouncing icon in the Dock.
@property (nonatomic, assign) NSTimer *userAttentionTimer;

// Accounts menu items to show in windows menu.
@property (nonatomic, retain) NSArray *accountsMenuItems;

// Application Window menu.
@property (nonatomic, retain) IBOutlet NSMenu *windowMenu;

// Preferences menu item outlet.
@property (nonatomic, retain) IBOutlet NSMenuItem *preferencesMenuItem;

// Stops and destroys SIP user agent hanging up all calls and unregistering all
// accounts.
- (void)stopUserAgent;

// A shortcut to restart user agent. Sets appropriate flags to start user agent,
// and then calls |stopUserAgent|.
- (void)restartUserAgent;

// Updates list of available audio devices.
- (void)updateAudioDevices;

// Chooses appropriate audio devices for sound IO.
- (void)selectSoundIO;

// Shows preferences window.
- (IBAction)showPreferencePanel:(id)sender;

// Adds an account on first application launch.
- (IBAction)addAccountOnFirstLaunch:(id)sender;

// Starts a ringtone timer.
- (void)startRingtoneTimer;

// Stops a ringtone timer if needed.
- (void)stopRingtoneTimerIfNeeded;

// Method to be called when a ringtone timer fires.
- (void)ringtoneTimerTick:(NSTimer *)theTimer;

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

// Installs Address Book plug-ins to |~/Library/Address Book Plug-Ins|. Updates
// plug-ins if the installed versions are outdated. Does not guaranteed to
// return a valid |error| if the method returns NO.
- (BOOL)installAddressBookPlugInsAndReturnError:(NSError **)error;

// Returns a localized string describing a given SIP response code.
- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode;

@end
