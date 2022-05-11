//
//  AccountSetupController.m
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

#import "AccountSetupController.h"

#import "AKKeychain.h"

#import "Telephone-Swift.h"


NSString * const AKAccountSetupControllerDidAddAccountNotification = @"AKAccountSetupControllerDidAddAccount";

@implementation AccountSetupController

- (instancetype)init {
    self = [super initWithWindowNibName:@"AccountSetup"];
    
    return self;
}

- (IBAction)closeSheet:(id)sender {
    if (self.window.sheetParent) {
        [self.window.sheetParent endSheet:self.window];
    } else {
        [self.window orderOut:sender];
    }
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
    accountDict[UserDefaultsKeys.accountEnabled] = @YES;
    accountDict[AKSIPAccountKeys.uuid] = [NSUUID UUID].UUIDString;
    accountDict[AKSIPAccountKeys.fullName] = fullName;
    accountDict[AKSIPAccountKeys.domain] = domain;
    accountDict[AKSIPAccountKeys.realm] = @"*";
    accountDict[AKSIPAccountKeys.username] = username;
    accountDict[AKSIPAccountKeys.reregistrationTime] = @0;
    accountDict[UserDefaultsKeys.substitutePlusCharacter] = @NO;
    accountDict[UserDefaultsKeys.plusCharacterSubstitutionString] = @"00";
    accountDict[AKSIPAccountKeys.useProxy] = @NO;
    accountDict[AKSIPAccountKeys.proxyHost] = @"";
    accountDict[AKSIPAccountKeys.proxyPort] = @0;
    accountDict[AKSIPAccountKeys.transport] = AKSIPAccountKeys.transportUDP;
    accountDict[AKSIPAccountKeys.ipVersion] = AKSIPAccountKeys.ipVersion4;
    accountDict[AKSIPAccountKeys.updateContactHeader] = @YES;
    accountDict[AKSIPAccountKeys.updateViaHeader] = @YES;
    accountDict[AKSIPAccountKeys.updateSDP] = @YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:UserDefaultsKeys.accounts]];
    [savedAccounts addObject:accountDict];
    [defaults setObject:savedAccounts forKey:UserDefaultsKeys.accounts];
    
    [AKKeychain addItemWithService:[NSString stringWithFormat:@"SIP: %@", domain]
                           account:username
                          password:[[self passwordField] stringValue]];
    
    [self closeSheet:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKAccountSetupControllerDidAddAccountNotification
                                                        object:self
                                                      userInfo:accountDict];
}

@end
