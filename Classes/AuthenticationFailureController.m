//
//  AuthenticationFailureController.m
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

#import "AuthenticationFailureController.h"

#import "AKSIPUserAgent.h"
#import "AKKeychain.h"

#import "AccountController.h"
#import "AppController.h"


NSString * const AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
    = @"AKAuthenticationFailureControllerDidChangeUsernameAndPassword";

@implementation AuthenticationFailureController

@synthesize accountController = accountController_;

@synthesize informativeText = informativeText_;
@synthesize usernameField = usernameField_;
@synthesize passwordField = passwordField_;
@synthesize mustSaveCheckBox = mustSaveCheckBox_;
@synthesize cancelButton = cancelButton_;

- (id)initWithAccountController:(AccountController *)anAccountController {
    self = [super initWithWindowNibName:@"AuthenticationFailure"];
    if (self != nil) {
        [self setAccountController:anAccountController];
    }
    
    return self;
}

- (id)init {
    return [self initWithAccountController:nil];
}

- (void)dealloc {
    [informativeText_ release];
    [usernameField_ release];
    [passwordField_ release];
    [mustSaveCheckBox_ release];
    [cancelButton_ release];
    
    [super dealloc];
}

- (void)awakeFromNib {
    NSString *registrar = [[[self accountController] account] registrar];
    [[self  informativeText] setStringValue:
     [NSString stringWithFormat:
      NSLocalizedString(@"Telephone was unable to login to %@. Change user name or password and try again.",
                        @"Registrar authentication failed."), registrar]];
    
    NSString *username = [[[self accountController] account] username];
    NSString *serviceName = [NSString stringWithFormat:@"SIP: %@", [[[self accountController] account] registrar]];
    NSString *password = [AKKeychain passwordForServiceName:serviceName accountName:username];
    
    [[self usernameField] setStringValue:username];
    [[self passwordField] setStringValue:password];
}

- (IBAction)closeSheet:(id)sender {
    [NSApp endSheet:[sender window]];
    [[sender window] orderOut:self];
}

- (IBAction)changeUsernameAndPassword:(id)sender {
    [self closeSheet:sender];
    
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *username = [[[self usernameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    
    if ([username length] > 0) {
        [[self accountController] removeAccountFromUserAgent];
        [[[self accountController] account] setUsername:username];
        
        [[self accountController] showConnectingState];
        
        // Add account to the user agent.
        [[[NSApp delegate] userAgent] addAccount:[[self accountController] account]
                                    withPassword:[[self passwordField] stringValue]];
        
        // Error connecting to registrar.
        if (![[self accountController] isAccountRegistered] &&
            [[[self accountController] account] registrationExpireTime] < 0) {
            
            [[self accountController] showUnavailableState];
            
            NSString *statusText;
            NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            if ([preferredLocalization isEqualToString:@"Russian"]) {
                statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                              [[[self accountController] account] registrationStatus]];
            } else {
                statusText = [[[self accountController] account] registrationStatusText];
            }
            
            NSString *error;
            if (statusText == nil) {
                error = [NSString stringWithFormat:
                         NSLocalizedString(@"Error %d", @"Error #."),
                         [[[self accountController] account] registrationStatus]];
                error = [error stringByAppendingString:@"."];
            } else {
                error = [NSString stringWithFormat:
                         NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.", @"Error description."),
                         [[[self accountController] account] registrationStatus], statusText];
            }
            
            [[self accountController] showRegistrarConnectionErrorSheetWithError:error];
        }
        
        if ([[self mustSaveCheckBox] state] == NSOnState) {
            NSString *serviceName = [NSString stringWithFormat:@"SIP: %@",
                                     [[[self accountController] account] registrar]];
            [AKKeychain addItemWithServiceName:serviceName
                                   accountName:username
                                      password:[[self passwordField] stringValue]];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AKAuthenticationFailureControllerDidChangeUsernameAndPasswordNotification
                       object:self];
    }
    
    [[self passwordField] setStringValue:@""];
}

@end
