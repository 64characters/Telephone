//
//  AccountController.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
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

#import "AKSIPAccount.h"

#import "CallController.h"


// Address Book label for SIP address in the email field.
extern NSString * const kEmailSIPLabel;

@class AKSIPURI, AKNetworkReachability;
@class AuthenticationFailureController;
@class CallHistoryViewEventTargetFactory, CallTransferController, WorkspaceSleepStatus;
@protocol MusicPlayer, RingtonePlaybackUseCase;

// A SIP account controller.
@interface AccountController : NSWindowController <AKSIPAccountDelegate, CallControllerDelegate>

// A Boolean value indicating whether receiver is enabled.
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;

@property(nonatomic, readonly) AKSIPAccount *account;
@property(nonatomic, readonly) AKSIPUserAgent *userAgent;
@property(nonatomic, readonly) id<RingtonePlaybackUseCase> ringtonePlayback;
@property(nonatomic, readonly) id<MusicPlayer> musicPlayer;
@property(nonatomic, readonly) WorkspaceSleepStatus *sleepStatus;
@property(nonatomic, readonly) CallHistoryViewEventTargetFactory *factory;

// A Boolean value indicating whether account is registered.
@property(nonatomic, readonly, getter=isAccountRegistered) BOOL accountRegistered;

// An array of call controllers managed by the receiver.
@property(nonatomic, strong) NSMutableArray *callControllers;

// Account description.
@property(nonatomic, copy) NSString *accountDescription;

// A Boolean value indicating whether a user is attempting to register an account.
@property(nonatomic, assign) BOOL attemptingToRegisterAccount;

// A Boolean value indicating whether a user is attempting to unregister an account.
@property(nonatomic, assign) BOOL attemptingToUnregisterAccount;

// A Boolean value indicting whether the receiver should present account registration error to the user.
@property(nonatomic, assign) BOOL shouldPresentRegistrationError;

// A Boolean value indicating whether account is unavailable. When it is, we reply with |480 Temporarily Unavailable|
// to all incoming calls.
@property(nonatomic, assign, getter=isAccountUnavailable) BOOL accountUnavailable;

// Registrar network reachability. When registrar becomes reachable, we try to register the receiver's account.
@property(nonatomic, strong) AKNetworkReachability *registrarReachability;

// A Boolean value indicating whether a plus character at the beginning of the phone number to be dialed should be
// replaced.
@property(nonatomic, assign) BOOL substitutesPlusCharacter;

// A replacement for the plus character in the phone number.
@property(nonatomic, copy) NSString *plusCharacterSubstitution;

// An authentication failure controller.
@property(nonatomic, readonly) AuthenticationFailureController *authenticationFailureController;

// A Boolean value indicating if call windows should display account name.
@property(nonatomic, assign) BOOL callsShouldDisplayAccountInfo;

@property(nonatomic, readonly) BOOL canMakeCalls;


- (instancetype)initWithSIPAccount:(AKSIPAccount *)account
                         userAgent:(AKSIPUserAgent *)userAgent
                  ringtonePlayback:(id<RingtonePlaybackUseCase>)ringtonePlayback
                       musicPlayer:(id<MusicPlayer>)musicPlayer
                       sleepStatus:(WorkspaceSleepStatus *)sleepStatus
                           factory:(CallHistoryViewEventTargetFactory *)factory;

// Registers the account adding it to the user agent, if needed. The user agent will be started, if it hasn't been yet.
- (void)registerAccount;
- (void)unregisterAccount;

// Removes account from the user agent.
- (void)removeAccountFromUserAgent;

// Makes a call to a given destination URI with a given phone label.
// When |callTransferController| is not nil, no new window will be created, existing |callTransferController| will be
// used instead. Host part of the |destinationURI| can be empty, in which case host part from the account's
// |registrationURI| will be taken.
- (void)makeCallToURI:(AKSIPURI *)destinationURI
        phoneLabel:(NSString *)phoneLabel
        callTransferController:(CallTransferController *)callTransferController;

// Calls makeCallToURI:phoneLabel:callTransferController: with |callTransferController| set to nil.
- (void)makeCallToURI:(AKSIPURI *)destinationURI phoneLabel:(NSString *)phoneLabel;

- (void)makeCallToDestinationRegisteringAccountIfNeeded:(NSString *)destination;

// Changes account state.
- (IBAction)changeAccountState:(id)sender;

// Shows alert saying that connection to the registrar failed.
- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error;

// Switches account window to the available state.
- (void)showAvailableState;

// Switches account window to the unavailable state.
- (void)showUnavailableState;

// Switches account window to the offline state.
- (void)showOfflineState;

// Switches account window to the connecting state.
- (void)showConnectingState;

@end
