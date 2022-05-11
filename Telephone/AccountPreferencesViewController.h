//
//  AccountPreferencesViewController.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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


@class PreferencesController, AccountSetupController;

// A view controller to manage account preferences.
@interface AccountPreferencesViewController : NSViewController

// Preferences controller the receiver belongs to.
@property(nonatomic, weak) PreferencesController *preferencesController;

// Account setup controller.
@property(nonatomic, readonly) AccountSetupController *accountSetupController;

// Outlets.
@property(nonatomic, weak) IBOutlet NSTableView *accountsTable;
@property(nonatomic, weak) IBOutlet NSButton *addAccountButton;
@property(nonatomic, weak) IBOutlet NSButton *accountEnabledCheckBox;
@property(nonatomic, weak) IBOutlet NSTextField *accountDescriptionField;
@property(nonatomic, weak) IBOutlet NSTextField *fullNameField;
@property(nonatomic, weak) IBOutlet NSTextField *domainField;
@property(nonatomic, weak) IBOutlet NSTextField *usernameField;
@property(nonatomic, weak) IBOutlet NSTextField *passwordField;
@property(nonatomic, weak) IBOutlet NSTextField *reregistrationTimeField;
@property(nonatomic, weak) IBOutlet NSButton *substitutePlusCharacterCheckBox;
@property(nonatomic, weak) IBOutlet NSTextField *plusCharacterSubstitutionField;
@property(nonatomic, weak) IBOutlet NSButton *useProxyCheckBox;
@property(nonatomic, weak) IBOutlet NSTextField *proxyHostField;
@property(nonatomic, weak) IBOutlet NSTextField *proxyPortField;
@property(nonatomic, weak) IBOutlet NSTextField *SIPAddressField;
@property(nonatomic, weak) IBOutlet NSTextField *registrarField;
@property(nonatomic, weak) IBOutlet NSTextField *cantEditAccountLabel;
@property(nonatomic, weak) IBOutlet NSButton *UDPButton;
@property(nonatomic, weak) IBOutlet NSButton *TCPButton;
@property(nonatomic, weak) IBOutlet NSButton *TLSButton;
@property(nonatomic, weak) IBOutlet NSButton *IPv4Button;
@property(nonatomic, weak) IBOutlet NSButton *IPv6Button;
@property(nonatomic, weak) IBOutlet NSButton *updateIPAddressCheckBox;

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

// Used only for grouping radio buttons.
- (IBAction)changeTransport:(id)sender;
- (IBAction)changeIPVersion:(id)sender;

@end
