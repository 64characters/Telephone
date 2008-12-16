//
//  AKAccountController.h
//  Telephone
//
//  Copyright (c) 2008 Alexei Kuznetsov. All rights reserved.
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


// Account registration pull-down list tags
enum {
	AKTelephoneAccountUnregisterTag	= 0,
	AKTelephoneAccountRegisterTag	= 1
};

@class AKTelephoneAccount;

@interface AKAccountController : NSWindowController <AKTelephoneAccountDelegate> {
@private
	BOOL enabled;
	AKTelephoneAccount *account;
	NSMutableArray *callControllers;
	
	IBOutlet NSView *registeredAccountView;
	IBOutlet NSView *unregisteredAccountView;
	IBOutlet NSPopUpButton *accountRegistrationPopUp;
	IBOutlet NSTokenField *callDestination;
	NSUInteger callDestinationURIIndex;
	
	// Authentication failure sheet outlets
	IBOutlet NSWindow *authenticationFailureSheet;
	IBOutlet NSTextField *updateCredentialsInformativeText;
	IBOutlet NSTextField *newUsername;
	IBOutlet NSTextField *newPassword;
	IBOutlet NSButton *mustSave;
	IBOutlet NSButton *authenticationFailureCancelButton;
}

@property(readwrite, assign, getter=isEnabled) BOOL enabled;
@property(readwrite, retain) AKTelephoneAccount *account;
@property(nonatomic, readwrite, assign, getter=isAccountRegistered) BOOL accountRegistered;
@property(readonly, retain) NSMutableArray *callControllers;
@property(readwrite, assign) NSUInteger callDestinationURIIndex;

// Designated initializer
- (id)initWithTelephoneAccount:(AKTelephoneAccount *)anAccount;

- (id)initWithFullName:(NSString *)aFullName
			SIPAddress:(NSString *)aSIPAddress
			 registrar:(NSString *)aRegistrar
				 realm:(NSString *)aRealm
			  username:(NSString *)aUsername;

- (IBAction)makeCall:(id)sender;

- (IBAction)changeAccountRegistration:(id)sender;

// When authentication fails, the sheet is being raised.
// This action method applies new username and password entered by user for the account.
- (IBAction)changeUsernameAndPassword:(id)sender;

- (IBAction)closeSheet:(id)sender;

// Change the active SIP URI index in the call destination token.
- (IBAction)changeCallDestinationURIIndex:(id)sender;

// Show alert saying that connection to the registrar failed.
- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error;

@end
