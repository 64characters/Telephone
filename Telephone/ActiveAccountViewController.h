//
//  ActiveAccountViewController.h
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


// Call destination keys.
extern NSString * const kURI;
extern NSString * const kPhoneLabel;

@class AccountController, AKSIPURI;

// An active account view controller.
@interface ActiveAccountViewController : NSViewController {
    AccountController * __weak _accountController;
}

@property(nonatomic, readonly, weak) AccountController *accountController;

// Call destination token field outlet.
@property(nonatomic, weak) IBOutlet NSTokenField *callDestinationField;

// Index of a URI in a call destination token.
@property(nonatomic, assign) NSUInteger callDestinationURIIndex;

// Call destination URI.
@property(nonatomic, readonly, copy) AKSIPURI *callDestinationURI;

@property(nonatomic, readonly) BOOL allowsCallDestinationInput;
@property(nonatomic, readonly) NSView *keyView;

- (instancetype)initWithAccountController:(AccountController *)accountController NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSNibName)name bundle:(NSBundle *)bundle NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

// Makes a call.
- (IBAction)makeCall:(id)sender;

// Changes the active SIP URI index in the call destination token.
- (IBAction)changeCallDestinationURIIndex:(id)sender;

- (void)allowCallDestinationInput;
- (void)disallowCallDestinationInput;

- (void)updateNextKeyView:(NSView *)view;

@end
