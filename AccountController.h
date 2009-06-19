//
//  AccountController.h
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

#import "AKTelephoneAccount.h"


@class AKTelephoneAccount, AKNetworkReachability;

@interface AccountController : NSWindowController <AKTelephoneAccountDelegate> {
 @private
  BOOL enabled_;
  AKTelephoneAccount *account_;
  NSMutableArray *callControllers_;
  BOOL attemptingToRegisterAccount_;
  BOOL attemptingToUnregisterAccount_;
  BOOL accountUnavailable_;
  NSTimer *reRegistrationTimer_;
  BOOL shouldMakeCall_;
  NSString *catchedURLString_;
  AKNetworkReachability *registrarReachability_;
  
  BOOL substitutesPlusCharacter_;
  NSString *plusCharacterSubstitution_;
  
  NSView *activeAccountView_;
  NSView *offlineAccountView_;
  NSPopUpButton *accountStatePopUp_;
  NSTokenField *callDestinationField_;
  NSUInteger callDestinationURIIndex_;
  
  // Authentication failure sheet elements.
  NSWindow *authenticationFailureSheet_;
  NSTextField *updateCredentialsInformativeText_;
  NSTextField *newUsernameField_;
  NSTextField *newPasswordField_;
  NSButton *mustSaveCheckBox_;
  NSButton *authenticationFailureCancelButton_;
}

@property(nonatomic, assign, getter=isEnabled) BOOL enabled;
@property(nonatomic, retain) AKTelephoneAccount *account;
@property(nonatomic, assign, getter=isAccountRegistered) BOOL accountRegistered;
@property(nonatomic, retain) NSMutableArray *callControllers;
@property(nonatomic, assign) BOOL attemptingToRegisterAccount;
@property(nonatomic, assign) BOOL attemptingToUnregisterAccount;
@property(nonatomic, assign, getter=isAccountUnavailable) BOOL accountUnavailable;
@property(nonatomic, assign) BOOL shouldMakeCall;
@property(nonatomic, copy) NSString *catchedURLString;
@property(nonatomic, retain) AKNetworkReachability *registrarReachability;
@property(nonatomic, assign) BOOL substitutesPlusCharacter;
@property(nonatomic, copy) NSString *plusCharacterSubstitution;

@property(nonatomic, retain) IBOutlet NSView *activeAccountView;
@property(nonatomic, retain) IBOutlet NSView *offlineAccountView;
@property(nonatomic, retain) IBOutlet NSPopUpButton *accountStatePopUp;
@property(nonatomic, retain) IBOutlet NSTokenField *callDestinationField;

@property(nonatomic, retain) IBOutlet NSWindow *authenticationFailureSheet;
@property(nonatomic, retain) IBOutlet NSTextField *updateCredentialsInformativeText;
@property(nonatomic, retain) IBOutlet NSTextField *newUsernameField;
@property(nonatomic, retain) IBOutlet NSTextField *newPasswordField;
@property(nonatomic, retain) IBOutlet NSButton *mustSaveCheckBox;
@property(nonatomic, retain) IBOutlet NSButton *authenticationFailureCancelButton;

// Designated initializer
- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount;

- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername;

// Remove account from Telehpone making appropriate changes in UI, timers, etc.
- (void)removeAccountFromTelephone;

- (IBAction)makeCall:(id)sender;

- (IBAction)changeAccountState:(id)sender;

// When authentication fails, the sheet is being raised.
// This action method applies new username and password entered
// by user for the account.
- (IBAction)changeUsernameAndPassword:(id)sender;

- (IBAction)closeSheet:(id)sender;

// Change the active SIP URI index in the call destination token.
- (IBAction)changeCallDestinationURIIndex:(id)sender;

// Show alert saying that connection to the registrar failed.
- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error;

// Set accountStatePopUp button title, change account window content view,
// set accountStatePopUp menu items states.
- (void)showAvailableState;
- (void)showUnavailableState;
- (void)showOfflineState;
- (void)showConnectingState;

// Handle |catchedURLString| populated by application URL handler.
- (void)handleCatchedURL;

@end


// Account states.
enum {
  kTelephoneAccountOffline     = 1,
  kTelephoneAccountUnavailable = 2,
  kTelephoneAccountAvailable   = 3
};

// Address Book label for SIP address in the email field.
extern NSString * const kEmailSIPLabel;
