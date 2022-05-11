//
//  AccountSetupController.h
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


// Sent when account setup controller adds an account.
// |userInfo| object contains dictionary with the account data (see the account keys defined in
// PreferencesController.h).
extern NSString * const AKAccountSetupControllerDidAddAccountNotification;

// A class to manage account setup.
@interface AccountSetupController : NSWindowController

// Outlets.
@property(nonatomic, weak) IBOutlet NSTextField *fullNameField;
@property(nonatomic, weak) IBOutlet NSTextField *domainField;
@property(nonatomic, weak) IBOutlet NSTextField *usernameField;
@property(nonatomic, weak) IBOutlet NSTextField *passwordField;
@property(nonatomic, weak) IBOutlet NSImageView *fullNameInvalidDataView;
@property(nonatomic, weak) IBOutlet NSImageView *domainInvalidDataView;
@property(nonatomic, weak) IBOutlet NSImageView *usernameInvalidDataView;
@property(nonatomic, weak) IBOutlet NSImageView *passwordInvalidDataView;
@property(nonatomic, weak) IBOutlet NSButton *defaultButton;
@property(nonatomic, weak) IBOutlet NSButton *otherButton;

// Closes a sheet.
- (IBAction)closeSheet:(id)sender;

// Adds new account.
- (IBAction)addAccount:(id)sender;

@end
