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
@interface AccountPreferencesViewController : NSViewController

// Preferences controller the receiver belongs to.
@property (nonatomic, weak) PreferencesController *preferencesController;

// Account setup controller.
@property (nonatomic, readonly) AccountSetupController *accountSetupController;

// Outlets.
@property (nonatomic, weak) IBOutlet NSTableView *accountsTable;
@property (nonatomic, weak) IBOutlet NSButton *addAccountButton;
@property (nonatomic, weak) IBOutlet NSButton *accountEnabledCheckBox;
@property (nonatomic, weak) IBOutlet NSTextField *accountDescriptionField;
@property (nonatomic, weak) IBOutlet NSTextField *fullNameField;
@property (nonatomic, weak) IBOutlet NSTextField *domainField;
@property (nonatomic, weak) IBOutlet NSTextField *usernameField;
@property (nonatomic, weak) IBOutlet NSTextField *passwordField;
@property (nonatomic, weak) IBOutlet NSTextField *reregistrationTimeField;
@property (nonatomic, weak) IBOutlet NSButton *substitutePlusCharacterCheckBox;
@property (nonatomic, weak) IBOutlet NSTextField *plusCharacterSubstitutionField;
@property (nonatomic, weak) IBOutlet NSButton *useProxyCheckBox;
@property (nonatomic, weak) IBOutlet NSTextField *proxyHostField;
@property (nonatomic, weak) IBOutlet NSTextField *proxyPortField;
@property (nonatomic, weak) IBOutlet NSTextField *SIPAddressField;
@property (nonatomic, weak) IBOutlet NSTextField *registrarField;
@property (nonatomic, weak) IBOutlet NSTextField *cantEditAccountLabel;

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
