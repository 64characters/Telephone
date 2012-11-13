//
//  AccountPreferencesViewController.h
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


@class PreferencesController, AccountSetupController;

// A view controller to manage account preferences.
@interface AccountPreferencesViewController : NSViewController {
 @private
  PreferencesController *preferencesController_;
  AccountSetupController *accountSetupController_;
  
  NSTableView *accountsTable_;
  NSButton *addAccountButton_;
  NSButton *accountEnabledCheckBox_;
  NSTextField *accountDescriptionField_;
  NSTextField *fullNameField_;
  NSTextField *domainField_;
  NSTextField *usernameField_;
  NSTextField *passwordField_;
  NSTextField *reregistrationTimeField_;
  NSButton *substitutePlusCharacterCheckBox_;
  NSTextField *plusCharacterSubstitutionField_;
  NSButton *useProxyCheckBox_;
  NSTextField *proxyHostField_;
  NSTextField *proxyPortField_;
  NSTextField *SIPAddressField_;
  NSTextField *registrarField_;
  NSTextField *cantEditAccountLabel_;
}

// Preferences controller the receiver belongs to.
@property (nonatomic, assign) PreferencesController *preferencesController;

// Account setup controller.
@property (nonatomic, readonly) AccountSetupController *accountSetupController;

// Outlets.
@property (nonatomic, retain) IBOutlet NSTableView *accountsTable;
@property (nonatomic, retain) IBOutlet NSButton *addAccountButton;
@property (nonatomic, retain) IBOutlet NSButton *accountEnabledCheckBox;
@property (nonatomic, retain) IBOutlet NSTextField *accountDescriptionField;
@property (nonatomic, retain) IBOutlet NSTextField *fullNameField;
@property (nonatomic, retain) IBOutlet NSTextField *domainField;
@property (nonatomic, retain) IBOutlet NSTextField *usernameField;
@property (nonatomic, retain) IBOutlet NSTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSTextField *reregistrationTimeField;
@property (nonatomic, retain) IBOutlet NSButton *substitutePlusCharacterCheckBox;
@property (nonatomic, retain) IBOutlet NSTextField *plusCharacterSubstitutionField;
@property (nonatomic, retain) IBOutlet NSButton *useProxyCheckBox;
@property (nonatomic, retain) IBOutlet NSTextField *proxyHostField;
@property (nonatomic, retain) IBOutlet NSTextField *proxyPortField;
@property (nonatomic, retain) IBOutlet NSButton *inbandDTMFField;
@property (nonatomic, retain) IBOutlet NSTextField *SIPAddressField;
@property (nonatomic, retain) IBOutlet NSTextField *registrarField;
@property (nonatomic, retain) IBOutlet NSTextField *cantEditAccountLabel;

// Raises |Add Account| sheet.
- (IBAction)showAddAccountSheet:(id)sender;

// Raises |Remove Account| sheet.
- (IBAction)showRemoveAccountSheet:(id)sender;

// Removes account with specified index.
- (void)removeAccountAtIndex:(NSInteger)index;

// Populates fields and checkboxes for the account with a specified index.
- (void)populateFieldsForAccountAtIndex:(NSInteger)index;

// Enables or disables an account.
- (IBAction)changeAccountEnabled:(id)sender;

// Enables or disables plus character replacement for an account.
- (IBAction)changeSubstitutePlusCharacter:(id)sender;

// Enables or disables proxy usage for an account.
- (IBAction)changeUseProxy:(id)sender;

@end
