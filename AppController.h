//
//  AppController.h
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

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "AKTelephone.h"


@class AKTelephone, PreferenceController, CallController;

@interface AppController : NSObject <AKTelephoneDelegate, GrowlApplicationBridgeDelegate> {
 @private
  AKTelephone *telephone_;
  NSMutableArray *accountControllers_;
  PreferenceController *preferenceController_;
  NSArray *audioDevices_;
  NSInteger soundInputDeviceIndex_;
  NSInteger soundOutputDeviceIndex_;
  NSInteger ringtoneOutputDeviceIndex_;
  BOOL shouldSetTelephoneSoundIO_;
  NSSound *ringtone_;
  NSTimer *ringtoneTimer_;
  BOOL shouldRegisterAllAccounts_;
  BOOL terminating_;
  BOOL didPauseITunes_;
  BOOL didWakeFromSleep_;
  NSUInteger afterSleepReconnectionAttemptIndex_;
  NSArray *afterSleepReconnectionTimeIntervals_;
  NSTimer *userAttentionTimer_;
  
  NSMenuItem *preferencesMenuItem_;
}

@property(nonatomic, readonly, retain) AKTelephone *telephone;
@property(nonatomic, readonly, retain) NSMutableArray *accountControllers;
@property(nonatomic, readonly, retain) NSArray *enabledAccountControllers;
@property(nonatomic, retain) PreferenceController *preferenceController;
@property(retain) NSArray *audioDevices;
@property(nonatomic, assign) NSInteger soundInputDeviceIndex;
@property(nonatomic, assign) NSInteger soundOutputDeviceIndex;
@property(nonatomic, assign) NSInteger ringtoneOutputDeviceIndex;
@property(nonatomic, assign) BOOL shouldSetTelephoneSoundIO;
@property(nonatomic, retain) NSSound *ringtone;
@property(nonatomic, assign) NSTimer *ringtoneTimer;
@property(nonatomic, assign) BOOL shouldRegisterAllAccounts;
@property(nonatomic, assign, getter=isTerminating) BOOL terminating;
@property(nonatomic, readonly, assign) BOOL hasIncomingCallControllers;
@property(nonatomic, readonly, assign) BOOL hasActiveCallControllers;
@property(nonatomic, readonly, retain) NSArray *currentNameservers;
@property(nonatomic, assign) BOOL didPauseITunes;
@property(nonatomic, assign) BOOL didWakeFromSleep;
@property(nonatomic, readonly, assign) NSUInteger unhandledIncomingCallsCount;
@property(nonatomic, assign) NSTimer *userAttentionTimer;

@property(nonatomic, retain) IBOutlet NSMenuItem *preferencesMenuItem;

// Hang up all calls, disconnect all accounts, destroy SIP user agent.
- (void)stopTelephone;

// Update list of available audio devices.
- (void)updateAudioDevices;

// Choose appropriate audio devices for sound IO.
- (void)selectSoundIO;

- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)addAccountOnFirstLaunch:(id)sender;

- (void)startRingtoneTimer;
- (void)stopRingtoneTimerIfNeeded;
- (void)ringtoneTimerTick:(NSTimer *)theTimer;

- (void)startUserAttentionTimer;
- (void)stopUserAttentionTimerIfNeeded;
- (void)requestUserAttentionTick:(NSTimer *)theTimer;

- (void)pauseITunes;
- (void)resumeITunesIfNeeded;

// Search all account controllers for the call controller
// with the given identifier (uuid).
- (CallController *)callControllerByIdentifier:(NSString *)identifier;

- (void)updateDockTileBadgeLabel;

- (IBAction)openFAQURL:(id)sender;

// Installs Address Book plug-ins to |~/Library/Address Book Plug-Ins|.
// Updates plug-ins if the installed versions are outdated.
// Does not guaranteed to return a valid |error| if the method returns NO.
- (BOOL)installAddressBookPlugInsAndReturnError:(NSError **)error;

- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode;

@end


// Audio device dictionary keys.
extern NSString * const kAudioDeviceIdentifier;
extern NSString * const kAudioDeviceUID;
extern NSString * const kAudioDeviceName;
extern NSString * const kAudioDeviceInputsCount;
extern NSString * const kAudioDeviceOutputsCount;

// Growl notification names.
extern NSString * const kGrowlNotificationIncomingCall;
extern NSString * const kGrowlNotificationCallEnded;
