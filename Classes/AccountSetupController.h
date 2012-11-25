//
//  AccountSetupController.h
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


// Sent when account setup controller adds an account.
// |userInfo| object contains dictionary with the account data (see the account keys defined in
// PreferencesController.h).
extern NSString * const AKAccountSetupControllerDidAddAccountNotification;

// A class to manage account setup.
@interface AccountSetupController : NSWindowController {
  @private
    NSTextField *fullNameField_;
    NSTextField *domainField_;
    NSTextField *usernameField_;
    NSTextField *passwordField_;
    NSImageView *fullNameInvalidDataView_;
    NSImageView *domainInvalidDataView_;
    NSImageView *usernameInvalidDataView_;
    NSImageView *passwordInvalidDataView_;
    NSButton *defaultButton_;
    NSButton *otherButton_;
}

// Outlets.
@property (nonatomic, retain) IBOutlet NSTextField *fullNameField;
@property (nonatomic, retain) IBOutlet NSTextField *domainField;
@property (nonatomic, retain) IBOutlet NSTextField *usernameField;
@property (nonatomic, retain) IBOutlet NSTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSImageView *fullNameInvalidDataView;
@property (nonatomic, retain) IBOutlet NSImageView *domainInvalidDataView;
@property (nonatomic, retain) IBOutlet NSImageView *usernameInvalidDataView;
@property (nonatomic, retain) IBOutlet NSImageView *passwordInvalidDataView;
@property (nonatomic, retain) IBOutlet NSButton *defaultButton;
@property (nonatomic, retain) IBOutlet NSButton *otherButton;

// Closes a sheet.
- (IBAction)closeSheet:(id)sender;

// Adds new account.
- (IBAction)addAccount:(id)sender;

@end
