//
//  AuthenticationFailureController.h
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

@import Cocoa;

// Posted whenever an AuthenticationFailureController object changes account's
// username and password.
extern NSString * const AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification;

@class AccountController, AKSIPUserAgent;

// Instances of AuthenticationFailureController class allow user to update
// account credentials when authentication fails.
@interface AuthenticationFailureController : NSWindowController

// The receiver's account controller.
@property(nonatomic, readonly, weak) AccountController *accountController;

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;

// Informative text outlet.
@property(nonatomic, weak) IBOutlet NSTextField *informativeText;

// |User Name| field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *usernameField;

// |Password| field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *passwordField;

// |Save in the Keychain| checkbox outlet.
@property(nonatomic, weak) IBOutlet NSButton *mustSaveCheckBox;

// Cancel button outlet.
@property(nonatomic, weak) IBOutlet NSButton *cancelButton;

- (instancetype)initWithAccountController:(AccountController *)accountController userAgent:(AKSIPUserAgent *)userAgent;

// Closes a sheet.
- (IBAction)closeSheet:(id)sender;

// Sets new user name and password.
- (IBAction)changeUsernameAndPassword:(id)sender;

@end
