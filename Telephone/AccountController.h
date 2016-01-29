//
//  AccountController.h
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

#import "AKSIPAccount.h"

#import "CallController.h"


// Account states.
enum {
    kSIPAccountOffline     = 1,
    kSIPAccountUnavailable = 2,
    kSIPAccountAvailable   = 3
};

// Address Book label for SIP address in the email field.
extern NSString * const kEmailSIPLabel;

@class AKSIPURI, AKNetworkReachability;
@class ActiveAccountViewController, AuthenticationFailureController;
@class CallTransferController;
@protocol RingtonePlaybackInteractorInput;

// A SIP account controller.
@interface AccountController : NSWindowController <AKSIPAccountDelegate, CallControllerDelegate>

// A Boolean value indicating whether receiver is enabled.
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;

// A SIP account the receiver controls.
@property(nonatomic, strong) AKSIPAccount *account;

@property(nonatomic, readonly, strong) id<RingtonePlaybackInteractorInput> ringtonePlaybackInteractor;

// A Boolean value indicating whether account is registered.
@property(nonatomic, assign, getter=isAccountRegistered) BOOL accountRegistered;

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

// A Boolean value indicating whether the receiver should make a call ASAP.
// (User can initiate a call from the Address Book when application is not yet launched.)
@property(nonatomic, assign) BOOL shouldMakeCall;

// URL string catched by the URL handler.
@property(nonatomic, copy) NSString *catchedURLString;

// Registrar network reachability. When registrar becomes reachable, we try to register the receiver's account.
@property(nonatomic, strong) AKNetworkReachability *registrarReachability;

// A Boolean value indicating whether a plus character at the beginning of the phone number to be dialed should be
// replaced.
@property(nonatomic, assign) BOOL substitutesPlusCharacter;

// A replacement for the plus character in the phone number.
@property(nonatomic, copy) NSString *plusCharacterSubstitution;

// An active account view controller.
@property(nonatomic, readonly) ActiveAccountViewController *activeAccountViewController;

// An authentication failure controller.
@property(nonatomic, readonly) AuthenticationFailureController *authenticationFailureController;

// Account state pop-up button outlet.
@property(nonatomic, weak) IBOutlet NSPopUpButton *accountStatePopUp;

// A Boolean value indicating if call windows should display account name.
@property(nonatomic, assign) BOOL callsShouldDisplayAccountInfo;


// Designated initializer.
// Initializes an AccountController object with a given account.
- (instancetype)initWithSIPAccount:(AKSIPAccount *)account
        ringtonePlaybackInteractor:(id<RingtonePlaybackInteractorInput>)ringtonePlaybackInteractor;

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

// Handles |catchedURLString| populated by a URL handler, initiating the call.
- (void)handleCatchedURL;

@end
