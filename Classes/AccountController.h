//
//  AccountController.h
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

#import "AKSIPAccount.h"
#import "XSWindowController.h"


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

// A SIP account controller.
@interface AccountController : XSWindowController <AKSIPAccountDelegate> {
  @private
    BOOL enabled_;
    AKSIPAccount *account_;
    NSMutableArray *callControllers_;
    NSString *accountDescription_;
    BOOL attemptingToRegisterAccount_;
    BOOL attemptingToUnregisterAccount_;
    BOOL shouldPresentRegistrationError_;
    BOOL accountUnavailable_;
    NSTimer *reRegistrationTimer_;
    BOOL shouldMakeCall_;
    NSString *catchedURLString_;
    AKNetworkReachability *registrarReachability_;
    
    BOOL substitutesPlusCharacter_;
    NSString *plusCharacterSubstitution_;
    
    ActiveAccountViewController *activeAccountViewController_;
    AuthenticationFailureController *authenticationFailureController_;
    
    NSPopUpButton *accountStatePopUp_;
}

// A Boolean value indicating whether receiver is enabled.
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

// A SIP account the receiver controls.
@property (nonatomic, retain) AKSIPAccount *account;

// A Boolean value indicating whether account is registered.
@property (nonatomic, assign, getter=isAccountRegistered) BOOL accountRegistered;

// An array of call controllers managed by the receiver.
@property (nonatomic, retain) NSMutableArray *callControllers;

// Account description.
@property (nonatomic, copy) NSString *accountDescription;

// A Boolean value indicating whether a user is attempting to register an account.
@property (nonatomic, assign) BOOL attemptingToRegisterAccount;

// A Boolean value indicating whether a user is attempting to unregister an account.
@property (nonatomic, assign) BOOL attemptingToUnregisterAccount;

// A Boolean value indicting whether the receiver should present account registration error to the user.
@property (nonatomic, assign) BOOL shouldPresentRegistrationError;

// A Boolean value indicating whether account is unavailable. When it is, we reply with |480 Temporarily Unavailable|
// to all incoming calls.
@property (nonatomic, assign, getter=isAccountUnavailable) BOOL accountUnavailable;

// A Boolean value indicating whether the receiver should make a call ASAP.
// (User can initiate a call from the Address Book when application is not yet launched.)
@property (nonatomic, assign) BOOL shouldMakeCall;

// URL string catched by the URL handler.
@property (nonatomic, copy) NSString *catchedURLString;

// Registrar network reachability. When registrar becomes reachable, we try to register the receiver's account.
@property (nonatomic, retain) AKNetworkReachability *registrarReachability;

// A Boolean value indicating whether a plus character at the beginning of the phone number to be dialed should be
// replaced.
@property (nonatomic, assign) BOOL substitutesPlusCharacter;

// A replacement for the plus character in the phone number.
@property (nonatomic, copy) NSString *plusCharacterSubstitution;

// An active account view controller.
@property (nonatomic, readonly) ActiveAccountViewController *activeAccountViewController;

// An authentication failure controller.
@property (nonatomic, readonly) AuthenticationFailureController *authenticationFailureController;

// Account state pop-up button outlet.
@property (nonatomic, retain) IBOutlet NSPopUpButton *accountStatePopUp;


// Designated initializer.
// Initializes an AccountController object with a given account.
- (id)initWithSIPAccount:(AKSIPAccount *)anAccount;

// Initializes an AccountController object with a given full name, SIP address, regisrar, realm, and user name.
- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername;

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
