//
//  AuthenticationFailureController.m
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

#import "AuthenticationFailureController.h"

#import "AKSIPUserAgent.h"
#import "AKKeychain.h"

#import "AccountController.h"
#import "AppController.h"
#import "SIPResponseLocalization.h"


NSString * const AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
    = @"AKAuthenticationFailureControllerDidChangeUsernameAndPassword";

@implementation AuthenticationFailureController

- (instancetype)initWithAccountController:(AccountController *)accountController userAgent:(AKSIPUserAgent *)userAgent {
    self = [super initWithWindowNibName:@"AuthenticationFailure"];
    if (self != nil) {
        _accountController = accountController;
        _userAgent = userAgent;
    }
    return self;
}

- (void)awakeFromNib {
    [[self  informativeText] setStringValue:
     [NSString stringWithFormat:
      NSLocalizedString(@"Telephone was unable to login to %@. Change user name or password and try again.",
                        @"Registrar authentication failed."), self.accountController.account.registrar]];
    
    NSString *username = [[[self accountController] account] username];
    NSString *service = [NSString stringWithFormat:@"SIP: %@", [[[self accountController] account] registrar]];
    NSString *password = [AKKeychain passwordForService:service account:username];
    
    [[self usernameField] setStringValue:username];
    [[self passwordField] setStringValue:password];
}

- (IBAction)closeSheet:(id)sender {
    [self.window.sheetParent endSheet:self.window];
}

- (IBAction)changeUsernameAndPassword:(id)sender {
    [self closeSheet:sender];
    
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *username = [[[self usernameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    
    if ([username length] > 0) {
        [[self accountController] removeAccountFromUserAgent];
        [[[self accountController] account] updateUsername:username];
        
        [[self accountController] showConnectingState];
        
        // Add account to the user agent.
        [[self userAgent] addAccount:[[self accountController] account]
                        withPassword:[[self passwordField] stringValue]];
        
        // Error connecting to registrar.
        if (![[self accountController] isAccountRegistered] &&
            [[[self accountController] account] registrationExpireTime] == kAKSIPAccountRegistrationExpireTimeNotSpecified) {
            
            [[self accountController] showUnavailableState];
            
            NSString *statusText;
            NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
            if ([preferredLocalization isEqualToString:@"ru"]) {
                statusText = LocalizedStringForSIPResponseCode([[[self accountController] account] registrationStatus]);
            } else {
                statusText = [[[self accountController] account] registrationStatusText];
            }
            
            NSString *error;
            if (statusText == nil) {
                error = [NSString stringWithFormat:
                         NSLocalizedString(@"Error %ld", @"Error #."),
                         [[[self accountController] account] registrationStatus]];
                error = [error stringByAppendingString:@"."];
            } else {
                error = [NSString stringWithFormat:
                         NSLocalizedString(@"The error was: “%ld %@”.", @"Error description."),
                         [[[self accountController] account] registrationStatus], statusText];
            }
            
            [[self accountController] showRegistrarConnectionErrorSheetWithError:error];
        }
        
        if ([[self mustSaveCheckBox] state] == NSOnState) {
            NSString *service = [NSString stringWithFormat:@"SIP: %@", [[[self accountController] account] registrar]];
            [AKKeychain addItemWithService:service account:username password:[[self passwordField] stringValue]];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
                       object:self];
    }
    
    [[self passwordField] setStringValue:@""];
}

@end
