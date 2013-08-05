//
//  AccountSetupController.m
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

#import "AccountSetupController.h"

#import "AKKeychain.h"

#import "PreferencesController.h"


NSString * const AKAccountSetupControllerDidAddAccountNotification = @"AKAccountSetupControllerDidAddAccount";

@implementation AccountSetupController

- (id)init {
    self = [super initWithWindowNibName:@"AccountSetup"];
    
    return self;
}

- (IBAction)closeSheet:(id)sender {
    [NSApp endSheet:[sender window]];
    [[sender window] orderOut:sender];
}

- (IBAction)addAccount:(id)sender {
    // Reset hidden states of the invalid data indicators.
    [[self fullNameInvalidDataView] setHidden:YES];
    [[self domainInvalidDataView] setHidden:YES];
    [[self usernameInvalidDataView] setHidden:YES];
    [[self passwordInvalidDataView] setHidden:YES];
    
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *fullName = [[[self fullNameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    NSString *domain = [[[self domainField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    NSString *username = [[[self usernameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    
    BOOL invalidFormData = NO;
    
    if ([fullName length] == 0) {
        [[self fullNameInvalidDataView] setHidden:NO];
        invalidFormData = YES;
    }
    
    if ([domain length] == 0) {
        [[self domainInvalidDataView] setHidden:NO];
        invalidFormData = YES;
    }
    
    if ([username length] == 0) {
        [[self usernameInvalidDataView] setHidden:NO];
        invalidFormData = YES;
    }
    
    if ([[[self passwordField] stringValue] length] == 0) {
        [[self passwordInvalidDataView] setHidden:NO];
        invalidFormData = YES;
    }
    
    if (invalidFormData) {
        return;
    }
    
    NSMutableDictionary *accountDict = [NSMutableDictionary dictionary];
    [accountDict setObject:[NSNumber numberWithBool:YES] forKey:kAccountEnabled];
    [accountDict setObject:fullName forKey:kFullName];
    [accountDict setObject:domain forKey:kDomain];
    [accountDict setObject:@"*" forKey:kRealm];
    [accountDict setObject:username forKey:kUsername];
    [accountDict setObject:[NSNumber numberWithInteger:0] forKey:kReregistrationTime];
    [accountDict setObject:[NSNumber numberWithBool:NO] forKey:kSubstitutePlusCharacter];
    [accountDict setObject:@"00" forKey:kPlusCharacterSubstitutionString];
    [accountDict setObject:[NSNumber numberWithBool:NO] forKey:kUseProxy];
    [accountDict setObject:@"" forKey:kProxyHost];
    [accountDict setObject:[NSNumber numberWithInteger:0] forKey:kProxyPort];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
    [savedAccounts addObject:accountDict];
    [defaults setObject:savedAccounts forKey:kAccounts];
    [defaults synchronize];
    
    [AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@", domain]
                           accountName:username
                              password:[[self passwordField] stringValue]];
    
    [self closeSheet:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKAccountSetupControllerDidAddAccountNotification
                                                        object:self
                                                      userInfo:accountDict];
}

@end
