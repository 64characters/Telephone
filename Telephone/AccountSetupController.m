//
//  AccountSetupController.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#import "AccountSetupController.h"

#import "AKKeychain.h"

#import "UserDefaultsKeys.h"


NSString * const AKAccountSetupControllerDidAddAccountNotification = @"AKAccountSetupControllerDidAddAccount";

@implementation AccountSetupController

- (instancetype)init {
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
    accountDict[kAccountEnabled] = @YES;
    accountDict[kFullName] = fullName;
    accountDict[kDomain] = domain;
    accountDict[kRealm] = @"*";
    accountDict[kUsername] = username;
    accountDict[kReregistrationTime] = @0;
    accountDict[kSubstitutePlusCharacter] = @NO;
    accountDict[kPlusCharacterSubstitutionString] = @"00";
    accountDict[kUseProxy] = @NO;
    accountDict[kProxyHost] = @"";
    accountDict[kProxyPort] = @0;
    
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
