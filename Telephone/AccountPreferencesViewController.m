//
//  AccountPreferencesViewController.m
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

#import "AccountPreferencesViewController.h"

@import UseCases;

#import "AKKeychain.h"

#import "AccountSetupController.h"
#import "PreferencesController.h"

#import "Telephone-Swift.h"


// Pasteboard type.
static NSString * const kAKSIPAccountPboardType = @"AKSIPAccountPboardType";

// Maximum number of accounts.
static const NSUInteger kAccountsMax = 32;

@implementation AccountPreferencesViewController

@synthesize accountSetupController = _accountSetupController;

- (AccountSetupController *)accountSetupController {
    if (_accountSetupController == nil) {
        _accountSetupController = [[AccountSetupController alloc] init];
    }
    return _accountSetupController;
}

- (instancetype)init {
    self = [super initWithNibName:@"AccountPreferencesView" bundle:nil];
    if (self != nil) {
        [self setTitle:NSLocalizedString(@"Accounts", @"Accounts preferences window title.")];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Register a pasteboard type to rearrange accounts with drag and drop.
    [[self accountsTable] registerForDraggedTypes:@[kAKSIPAccountPboardType]];
    
    NSInteger row = [[self accountsTable] selectedRow];
    if (row != -1) {
        [self populateFieldsForAccountAtIndex:row];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger accountsCount = [[defaults arrayForKey:UserDefaultsKeys.accounts] count];
    if (accountsCount >= kAccountsMax) {
        [[self addAccountButton] setEnabled:NO];
    }
    
    // Subscribe to the account setup notifications.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(accountSetupControllerDidAddAccount:)
               name:AKAccountSetupControllerDidAddAccountNotification
             object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)showAddAccountSheet:(id)sender {
    [[[self accountSetupController] fullNameField] setStringValue:@""];
    [[[self accountSetupController] domainField] setStringValue:@""];
    [[[self accountSetupController] usernameField] setStringValue:@""];
    [[[self accountSetupController] passwordField] setStringValue:@""];
    
    [[[self accountSetupController] fullNameInvalidDataView] setHidden:YES];
    [[[self accountSetupController] domainInvalidDataView] setHidden:YES];
    [[[self accountSetupController] usernameInvalidDataView] setHidden:YES];
    [[[self accountSetupController] passwordInvalidDataView] setHidden:YES];
    
    [[[self accountSetupController] window] makeFirstResponder:
     [[self accountSetupController] fullNameField]];

    [[[self view] window] beginSheet:[[self accountSetupController] window] completionHandler:nil];
}

- (IBAction)showRemoveAccountSheet:(id)sender {
    NSInteger index = [[self accountsTable] selectedRow];
    if (index == -1) {
        NSBeep();
        return;
    }
    
    NSTableColumn *theColumn = [[NSTableColumn alloc] initWithIdentifier:@"SIPAddress"];
    NSString *selectedAccount = [[[self accountsTable] dataSource] tableView:[self accountsTable]
                                                   objectValueForTableColumn:theColumn
                                                                         row:index];
    
    NSAlert *alert = [[NSAlert alloc] init];
    NSButton *delete = [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete button.")];
    if (@available(macOS 11, *)) {
        delete.hasDestructiveAction = YES;
    }
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")].keyEquivalent = @"\033";
    [alert setMessageText:[NSString stringWithFormat:
                           NSLocalizedString(@"Delete “%@”?", @"Account removal confirmation."),
                           selectedAccount]];
    [alert setInformativeText:
     [NSString stringWithFormat:
      NSLocalizedString(@"This will delete your currently set up account “%@”.",
                        @"Account removal confirmation informative text."),
      selectedAccount]];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[[self accountsTable] window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self removeAccountAtIndex:[[self accountsTable] selectedRow]];
        }
    }];
}

- (void)removeAccountAtIndex:(NSInteger)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:UserDefaultsKeys.accounts]];
    NSString *uuid = savedAccounts[index][AKSIPAccountKeys.uuid];
    [savedAccounts removeObjectAtIndex:index];
    [defaults setObject:savedAccounts forKey:UserDefaultsKeys.accounts];
    
    if ([savedAccounts count] < kAccountsMax) {
        [[self addAccountButton] setEnabled:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKPreferencesControllerDidRemoveAccountNotification
                                                        object:[self preferencesController]
                                                      userInfo:@{kAccountIndex: @(index), AKSIPAccountKeys.uuid: uuid}];
    [[self accountsTable] reloadData];
    
    // Select none, last or previous account.
    if ([savedAccounts count] == 0) {
        return;
        
    } else if (index >= ([savedAccounts count] - 1)) {
        [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:([savedAccounts count] - 1)]
                          byExtendingSelection:NO];
        
        [self populateFieldsForAccountAtIndex:([savedAccounts count] - 1)];
        
    } else {
        [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        
        [self populateFieldsForAccountAtIndex:index];
    }
}

- (void)populateFieldsForAccountAtIndex:(NSInteger)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedAccounts = [defaults arrayForKey:UserDefaultsKeys.accounts];
    
    if (index >= 0) {
        NSDictionary *accountDict = savedAccounts[index];
        
        [[self accountEnabledCheckBox] setEnabled:YES];
        
        // Conditionally enable fields and set checkboxes state.
        if ([accountDict[UserDefaultsKeys.accountEnabled] boolValue]) {
            [[self accountEnabledCheckBox] setState:NSOnState];
            [[self accountDescriptionField] setEnabled:NO];
            [[self fullNameField] setEnabled:NO];
            [[self domainField] setEnabled:NO];
            [[self usernameField] setEnabled:NO];
            [[self passwordField] setEnabled:NO];
            [[self reregistrationTimeField] setEnabled:NO];
            [[self substitutePlusCharacterCheckBox] setEnabled:NO];
            [[self substitutePlusCharacterCheckBox] setState:[accountDict[UserDefaultsKeys.substitutePlusCharacter] integerValue]];
            [[self plusCharacterSubstitutionField] setEnabled:NO];
            [[self useProxyCheckBox] setState:[accountDict[AKSIPAccountKeys.useProxy] integerValue]];
            [[self useProxyCheckBox] setEnabled:NO];
            [[self proxyHostField] setEnabled:NO];
            [[self proxyPortField] setEnabled:NO];
            [[self SIPAddressField] setEnabled:NO];
            [[self registrarField] setEnabled:NO];
            [[self cantEditAccountLabel] setHidden:NO];
            [[self UDPButton] setEnabled:NO];
            [[self TCPButton] setEnabled:NO];
            [[self TLSButton] setEnabled:NO];
            [[self IPv4Button] setEnabled:NO];
            [[self IPv6Button] setEnabled:NO];
            [[self updateIPAddressCheckBox] setEnabled:NO];

        } else {
            [[self accountEnabledCheckBox] setState:NSOffState];
            [[self accountDescriptionField] setEnabled:YES];
            [[self fullNameField] setEnabled:YES];
            [[self domainField] setEnabled:YES];
            [[self usernameField] setEnabled:YES];
            [[self passwordField] setEnabled:YES];
            
            [[self reregistrationTimeField] setEnabled:YES];
            [[self substitutePlusCharacterCheckBox] setEnabled:YES];
            [[self substitutePlusCharacterCheckBox] setState:[accountDict[UserDefaultsKeys.substitutePlusCharacter] integerValue]];
            if ([[self substitutePlusCharacterCheckBox] state] == NSOnState) {
                [[self plusCharacterSubstitutionField] setEnabled:YES];
            } else {
                [[self plusCharacterSubstitutionField] setEnabled:NO];
            }

            [[self useProxyCheckBox] setEnabled:YES];
            [[self useProxyCheckBox] setState:[accountDict[AKSIPAccountKeys.useProxy] integerValue]];
            if ([[self useProxyCheckBox] state] == NSOnState) {
                [[self proxyHostField] setEnabled:YES];
                [[self proxyPortField] setEnabled:YES];
            } else {
                [[self proxyHostField] setEnabled:NO];
                [[self proxyPortField] setEnabled:NO];
            }
            
            [[self SIPAddressField] setEnabled:YES];
            [[self registrarField] setEnabled:YES];
            [[self cantEditAccountLabel] setHidden:YES];
            [[self UDPButton] setEnabled:YES];
            [[self TCPButton] setEnabled:YES];
            [[self TLSButton] setEnabled:YES];
            [[self IPv4Button] setEnabled:YES];
            [[self IPv6Button] setEnabled:YES];
            [[self updateIPAddressCheckBox] setEnabled:YES];
        }
        
        // Populate fields.
        
        // Description.
        if ([accountDict[AKSIPAccountKeys.desc] length] > 0) {
            [[self accountDescriptionField] setStringValue:accountDict[AKSIPAccountKeys.desc]];
        } else {
            [[self accountDescriptionField] setStringValue:@""];
        }
        
        // Description's placeholder string.
        if ([accountDict[AKSIPAccountKeys.sipAddress] length] > 0) {
            [[self accountDescriptionField] setPlaceholderString:accountDict[AKSIPAccountKeys.sipAddress]];
        } else {
            [[self accountDescriptionField] setPlaceholderString:
             [[SIPAddress alloc] initWithUser:accountDict[AKSIPAccountKeys.username]
                                         host:accountDict[AKSIPAccountKeys.domain]].stringValue];
        }
        
        // Full Name.
        [[self fullNameField] setStringValue:accountDict[AKSIPAccountKeys.fullName]];
        
        // Domain.
        if ([accountDict[AKSIPAccountKeys.domain] length] > 0) {
            [[self domainField] setStringValue:accountDict[AKSIPAccountKeys.domain]];
        } else {
            [[self domainField] setStringValue:@""];
        }
        
        // User Name.
        [[self usernameField] setStringValue:accountDict[AKSIPAccountKeys.username]];
        
        NSString *keychainService;
        if ([accountDict[AKSIPAccountKeys.registrar] length] > 0) {
            keychainService = [NSString stringWithFormat:@"SIP: %@", accountDict[AKSIPAccountKeys.registrar]];
        } else {
            keychainService = [NSString stringWithFormat:@"SIP: %@", accountDict[AKSIPAccountKeys.domain]];
        }
        
        // Password.
        [[self passwordField] setStringValue:[AKKeychain passwordForService:keychainService
                                                                    account:accountDict[AKSIPAccountKeys.username]]];
        
        // Reregister every...
        if ([accountDict[AKSIPAccountKeys.reregistrationTime] integerValue] > 0) {
            [[self reregistrationTimeField] setStringValue:[accountDict[AKSIPAccountKeys.reregistrationTime] stringValue]];
        } else {
            [[self reregistrationTimeField] setStringValue:@""];
        }
        
        // Substitute ... for "+".
        if (accountDict[UserDefaultsKeys.plusCharacterSubstitutionString] != nil) {
            [[self plusCharacterSubstitutionField] setStringValue:
             accountDict[UserDefaultsKeys.plusCharacterSubstitutionString]];
        } else {
            [[self plusCharacterSubstitutionField] setStringValue:@"00"];
        }
        
        // Proxy Server.
        if ([accountDict[AKSIPAccountKeys.proxyHost] length] > 0) {
            [[self proxyHostField] setStringValue:accountDict[AKSIPAccountKeys.proxyHost]];
        } else {
            [[self proxyHostField] setStringValue:@""];
        }
        
        // Proxy Port.
        if ([accountDict[AKSIPAccountKeys.proxyPort] integerValue] > 0) {
            [[self proxyPortField] setStringValue:[accountDict[AKSIPAccountKeys.proxyPort] stringValue]];
        } else {
            [[self proxyPortField] setStringValue:@""];
        }
        
        // SIP Address.
        if ([accountDict[AKSIPAccountKeys.sipAddress] length] > 0) {
            [[self SIPAddressField] setStringValue:accountDict[AKSIPAccountKeys.sipAddress]];
        } else {
            [[self SIPAddressField] setStringValue:@""];
        }
        
        // Registry Server.
        if ([accountDict[AKSIPAccountKeys.registrar] length] > 0) {
            [[self registrarField] setStringValue:accountDict[AKSIPAccountKeys.registrar]];
        } else {
            [[self registrarField] setStringValue:@""];
        }
        
        // SIP Address and Registry Server placeholder strings.
        if ([accountDict[AKSIPAccountKeys.domain] length] > 0) {
            [[self SIPAddressField] setPlaceholderString:
             [[SIPAddress alloc] initWithUser:accountDict[AKSIPAccountKeys.username]
                                         host:accountDict[AKSIPAccountKeys.domain]].stringValue];
            [[self registrarField] setPlaceholderString:accountDict[AKSIPAccountKeys.domain]];
        } else {
            [[self SIPAddressField] setPlaceholderString:nil];
            [[self registrarField] setPlaceholderString:nil];
        }

        // Update SIP Transport.
        if ([accountDict[AKSIPAccountKeys.transport] isEqualToString:AKSIPAccountKeys.transportTCP]) {
            [[self TCPButton] setState:NSOnState];
        } else if ([accountDict[AKSIPAccountKeys.transport] isEqualToString:AKSIPAccountKeys.transportTLS]) {
            [[self TLSButton] setState:NSOnState];
        } else {
            [[self UDPButton] setState:NSOnState];
        }
        [self updateProxyPortFieldPlaceholder];

        // Update IP Version.
        if ([accountDict[AKSIPAccountKeys.ipVersion] isEqualToString:AKSIPAccountKeys.ipVersion6]) {
            [[self IPv6Button] setState:NSOnState];
        } else {
            [[self IPv4Button] setState:NSOnState];
        }
        
        // Update headers checkbox.
        if ([accountDict[AKSIPAccountKeys.updateContactHeader] boolValue] &&
            [accountDict[AKSIPAccountKeys.updateViaHeader] boolValue] &&
            [accountDict[AKSIPAccountKeys.updateSDP] boolValue]) {
            [[self updateIPAddressCheckBox] setAllowsMixedState:NO];
            [[self updateIPAddressCheckBox] setState:NSOnState];
        } else if ([accountDict[AKSIPAccountKeys.updateContactHeader] boolValue] ||
                   [accountDict[AKSIPAccountKeys.updateViaHeader] boolValue] ||
                   [accountDict[AKSIPAccountKeys.updateSDP] boolValue]) {
            [[self updateIPAddressCheckBox] setAllowsMixedState:YES];
            [[self updateIPAddressCheckBox] setState:NSMixedState];
        } else {
            [[self updateIPAddressCheckBox] setAllowsMixedState:NO];
            [[self updateIPAddressCheckBox] setState:NSOffState];
        }

    } else {  // if (index >= 0)
        [[self accountEnabledCheckBox] setState:NSOffState];
        [[self accountDescriptionField] setStringValue:@""];
        [[self accountDescriptionField] setPlaceholderString:nil];
        [[self fullNameField] setStringValue:@""];
        [[self domainField] setStringValue:@""];
        [[self usernameField] setStringValue:@""];
        [[self passwordField] setStringValue:@""];
        [[self reregistrationTimeField] setStringValue:@""];
        [[self substitutePlusCharacterCheckBox] setState:NSOffState];
        [[self plusCharacterSubstitutionField] setStringValue:@"00"];
        [[self useProxyCheckBox] setState:NSOffState];
        [[self proxyHostField] setStringValue:@""];
        [[self proxyPortField] setStringValue:@""];
        [[self SIPAddressField] setStringValue:@""];
        [[self registrarField] setStringValue:@""];
        [[self UDPButton] setState:NSOffState];
        [[self TCPButton] setState:NSOffState];
        [[self TLSButton] setState:NSOffState];
        [[self IPv4Button] setState:NSOffState];
        [[self IPv6Button] setState:NSOffState];
        [[self updateIPAddressCheckBox] setState:NSOffState];

        [[self accountEnabledCheckBox] setEnabled:NO];
        [[self accountDescriptionField] setEnabled:NO];
        [[self fullNameField] setEnabled:NO];
        [[self domainField] setEnabled:NO];
        [[self usernameField] setEnabled:NO];
        [[self passwordField] setEnabled:NO];
        [[self reregistrationTimeField] setEnabled:NO];
        [[self substitutePlusCharacterCheckBox] setEnabled:NO];
        [[self plusCharacterSubstitutionField] setEnabled:NO];
        [[self useProxyCheckBox] setEnabled:NO];
        [[self proxyHostField] setEnabled:NO];
        [[self proxyPortField] setEnabled:NO];
        [[self SIPAddressField] setEnabled:NO];
        [[self SIPAddressField] setPlaceholderString:nil];
        [[self registrarField] setEnabled:NO];
        [[self registrarField] setPlaceholderString:nil];
        [[self cantEditAccountLabel] setHidden:YES];
        [[self UDPButton] setEnabled:NO];
        [[self TCPButton] setEnabled:NO];
        [[self TLSButton] setEnabled:NO];
        [[self IPv4Button] setEnabled:NO];
        [[self IPv6Button] setEnabled:NO];
        [[self updateIPAddressCheckBox] setEnabled:NO];
    }
}

- (IBAction)changeAccountEnabled:(id)sender {
    NSInteger index = [[self accountsTable] selectedRow];
    if (index == -1) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    userInfo[kAccountIndex] = @(index);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:UserDefaultsKeys.accounts]];
    
    NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:savedAccounts[index]];
    
    BOOL isChecked = [[self accountEnabledCheckBox] state] == NSOnState;
    accountDict[UserDefaultsKeys.accountEnabled] = @(isChecked);
    
    if (isChecked) {
        // User enabled the account.
        // Account fields could be edited, save them.
        
        NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *accountDescription = [[[self accountDescriptionField] stringValue]
                                        stringByTrimmingCharactersInSet:spacesSet];
        NSString *fullName = [[[self fullNameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        NSString *domain = [[[self domainField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        NSString *username = [[[self usernameField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        NSString *registrar = [[[self registrarField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        
        accountDict[AKSIPAccountKeys.desc] = accountDescription;
        accountDict[AKSIPAccountKeys.fullName] = fullName;
        accountDict[AKSIPAccountKeys.domain] = domain;
        accountDict[AKSIPAccountKeys.username] = username;
        
        NSString *keychainService;
        if ([registrar length] > 0) {
            keychainService = [NSString stringWithFormat:@"SIP: %@", registrar];
        } else {
            keychainService = [NSString stringWithFormat:@"SIP: %@", domain];
        }
        
        NSString *keychainAccount = username;
        
        NSString *keychainPassword = [AKKeychain passwordForService:keychainService account:keychainAccount];
        
        NSString *currentPassword = [[self passwordField] stringValue];
        
        // Save password only if it's been changed.
        if (![keychainPassword isEqualToString:currentPassword]) {
            [AKKeychain addItemWithService:keychainService account:keychainAccount password:currentPassword];
        }
        
        accountDict[AKSIPAccountKeys.reregistrationTime] = @([[self reregistrationTimeField] integerValue]);
        
        accountDict[UserDefaultsKeys.substitutePlusCharacter] = @([[self substitutePlusCharacterCheckBox] state] == NSOnState);
        accountDict[UserDefaultsKeys.plusCharacterSubstitutionString] = [[self plusCharacterSubstitutionField] stringValue];
        
        accountDict[AKSIPAccountKeys.useProxy] = @([[self useProxyCheckBox] state] == NSOnState);
        NSString *proxyHost = [[[self proxyHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        accountDict[AKSIPAccountKeys.proxyHost] = proxyHost;
        accountDict[AKSIPAccountKeys.proxyPort] = @([[self proxyPortField] integerValue]);
        
        NSString *sipAddress = [[[self SIPAddressField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        accountDict[AKSIPAccountKeys.sipAddress] = sipAddress;
        
        accountDict[AKSIPAccountKeys.registrar] = registrar;

        if (self.TCPButton.state == NSOnState) {
            accountDict[AKSIPAccountKeys.transport] = AKSIPAccountKeys.transportTCP;
        } else if (self.TLSButton.state == NSOnState) {
            accountDict[AKSIPAccountKeys.transport] = AKSIPAccountKeys.transportTLS;
        } else {
            accountDict[AKSIPAccountKeys.transport] = AKSIPAccountKeys.transportUDP;
        }

        accountDict[AKSIPAccountKeys.ipVersion] = self.IPv6Button.state == NSOnState ? AKSIPAccountKeys.ipVersion6 : AKSIPAccountKeys.ipVersion4;

        if (self.updateIPAddressCheckBox.state == NSOnState) {
            accountDict[AKSIPAccountKeys.updateContactHeader] = @YES;
            accountDict[AKSIPAccountKeys.updateViaHeader] = @YES;
            accountDict[AKSIPAccountKeys.updateSDP] = @YES;
        } else if (self.updateIPAddressCheckBox.state == NSMixedState) {
            accountDict[AKSIPAccountKeys.updateContactHeader] = @YES;
            accountDict[AKSIPAccountKeys.updateViaHeader] = @YES;
            accountDict[AKSIPAccountKeys.updateSDP] = @NO;
        } else {
            accountDict[AKSIPAccountKeys.updateContactHeader] = @NO;
            accountDict[AKSIPAccountKeys.updateViaHeader] = @NO;
            accountDict[AKSIPAccountKeys.updateSDP] = @NO;
        }

        // Set placeholders.
        
        if ([sipAddress length] > 0) {
            [[self accountDescriptionField] setPlaceholderString:sipAddress];
        } else {
            [[self accountDescriptionField] setPlaceholderString:
             [[SIPAddress alloc] initWithUser:username host:domain].stringValue];
        }
        
        if ([domain length] > 0) {
            [[self SIPAddressField] setPlaceholderString:[[SIPAddress alloc] initWithUser:username host:domain].stringValue];

            [[self registrarField] setPlaceholderString:domain];
            
        } else {
            [[self SIPAddressField] setPlaceholderString:nil];
            [[self registrarField] setPlaceholderString:nil];
        }
        
        // Disable account fields.
        [[self accountDescriptionField] setEnabled:NO];
        [[self fullNameField] setEnabled:NO];
        [[self domainField] setEnabled:NO];
        [[self usernameField] setEnabled:NO];
        [[self passwordField] setEnabled:NO];
        
        [[self reregistrationTimeField] setEnabled:NO];
        [[self substitutePlusCharacterCheckBox] setEnabled:NO];
        [[self plusCharacterSubstitutionField] setEnabled:NO];
        [[self useProxyCheckBox] setEnabled:NO];
        [[self proxyHostField] setEnabled:NO];
        [[self proxyPortField] setEnabled:NO];
        [[self SIPAddressField] setEnabled:NO];
        [[self registrarField] setEnabled:NO];
        [[self cantEditAccountLabel] setHidden:NO];
        [[self UDPButton] setEnabled:NO];
        [[self TCPButton] setEnabled:NO];
        [[self TLSButton] setEnabled:NO];
        [[self IPv4Button] setEnabled:NO];
        [[self IPv6Button] setEnabled:NO];
        [[self updateIPAddressCheckBox] setEnabled:NO];

        // Mark accounts table as needing redisplay.
        [[self accountsTable] reloadData];
        
    } else {  // if (isChecked)
        // User disabled the account - enable account fields, set checkboxes state.
        [[self accountDescriptionField] setEnabled:YES];
        [[self fullNameField] setEnabled:YES];
        [[self domainField] setEnabled:YES];
        [[self usernameField] setEnabled:YES];
        [[self passwordField] setEnabled:YES];
        
        [[self reregistrationTimeField] setEnabled:YES];
        [[self substitutePlusCharacterCheckBox] setEnabled:YES];
        [[self substitutePlusCharacterCheckBox] setState:[accountDict[UserDefaultsKeys.substitutePlusCharacter] integerValue]];
        if ([[self substitutePlusCharacterCheckBox] state] == NSOnState) {
            [[self plusCharacterSubstitutionField] setEnabled:YES];
        }
        
        [[self useProxyCheckBox] setEnabled:YES];
        [[self useProxyCheckBox] setState:[accountDict[AKSIPAccountKeys.useProxy] integerValue]];
        if ([[self useProxyCheckBox] state] == NSOnState) {
            [[self proxyHostField] setEnabled:YES];
            [[self proxyPortField] setEnabled:YES];
        }
        
        [[self SIPAddressField] setEnabled:YES];
        [[self registrarField] setEnabled:YES];
        [[self cantEditAccountLabel] setHidden:YES];
        [[self UDPButton] setEnabled:YES];
        [[self TCPButton] setEnabled:YES];
        [[self TLSButton] setEnabled:YES];
        [[self IPv4Button] setEnabled:YES];
        [[self IPv6Button] setEnabled:YES];
        [[self updateIPAddressCheckBox] setEnabled:YES];
    }
    
    savedAccounts[index] = accountDict;
    
    [defaults setObject:savedAccounts forKey:UserDefaultsKeys.accounts];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AKPreferencesControllerDidChangeAccountEnabledNotification
                   object:[self preferencesController]
                 userInfo:userInfo];
}

- (IBAction)changeSubstitutePlusCharacter:(id)sender {
    [[self plusCharacterSubstitutionField] setEnabled:([[self substitutePlusCharacterCheckBox] state] == NSOnState)];
}

- (IBAction)changeUseProxy:(id)sender {
    BOOL isChecked = [[self useProxyCheckBox] state] == NSOnState;
    [[self proxyHostField] setEnabled:isChecked];
    [[self proxyPortField] setEnabled:isChecked];
}

- (IBAction)changeTransport:(id)sender {
    [self updateProxyPortFieldPlaceholder];
}

- (void)updateProxyPortFieldPlaceholder {
    self.proxyPortField.placeholderString = self.TLSButton.state == NSOnState ? @"5061" : @"5060";
}

// Group radio buttons by providing them the same action.
- (IBAction)changeIPVersion:(id)sender {}


#pragma mark -
#pragma mark NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults arrayForKey:UserDefaultsKeys.accounts] count];
}

- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(NSInteger)rowIndex {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *accountDict = [defaults arrayForKey:UserDefaultsKeys.accounts][rowIndex];
    
    NSString *returnValue;
    NSString *accountDescription = accountDict[AKSIPAccountKeys.desc];
    if ([accountDescription length] > 0) {
        returnValue = accountDescription;
        
    } else {
        NSString *sipAddress;
        if ([accountDict[AKSIPAccountKeys.sipAddress] length] > 0) {
            sipAddress = accountDict[AKSIPAccountKeys.sipAddress];
        } else {
            sipAddress = [[SIPAddress alloc] initWithUser:accountDict[AKSIPAccountKeys.username]
                                                     host:accountDict[AKSIPAccountKeys.domain]].stringValue;
        }
        
        returnValue = sipAddress;
    }
    
    return returnValue;
}

- (BOOL)tableView:(NSTableView *)aTableView
        writeRowsWithIndexes:(NSIndexSet *)rowIndexes
        toPasteboard:(NSPasteboard *)pboard {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    
    [pboard declareTypes:@[kAKSIPAccountPboardType] owner:self];
    
    [pboard setData:data forType:kAKSIPAccountPboardType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
    
    NSData *data = [[info draggingPasteboard] dataForType:kAKSIPAccountPboardType];
    NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger draggingRow = [indexes firstIndex];
    
    if (row == draggingRow || row == draggingRow + 1) {
        return NSDragOperationNone;
    }
    
    [[self accountsTable] setDropRow:row dropOperation:NSTableViewDropAbove];
    
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
    
    NSData *data = [[info draggingPasteboard] dataForType:kAKSIPAccountPboardType];
    NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger draggingRow = [indexes firstIndex];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accounts = [[defaults arrayForKey:UserDefaultsKeys.accounts] mutableCopy];
    id selectedAccount = accounts[[[self accountsTable] selectedRow]];
    
    // Swap accounts.
    [accounts insertObject:accounts[draggingRow] atIndex:row];
    if (draggingRow < row) {
        [accounts removeObjectAtIndex:draggingRow];
    } else if (draggingRow > row) {
        [accounts removeObjectAtIndex:(draggingRow + 1)];
    } else {  // This should never happen because we don't validate such drop.
        return NO;
    }
    
    [defaults setObject:accounts forKey:UserDefaultsKeys.accounts];
    
    [[self accountsTable] reloadData];
    
    // Preserve account selection.
    NSUInteger selectedAccountIndex = [accounts indexOfObject:selectedAccount];
    [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedAccountIndex] byExtendingSelection:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKPreferencesControllerDidSwapAccountsNotification
                                                        object:[self preferencesController]
                                                      userInfo:@{kSourceIndex: @(draggingRow), kDestinationIndex: @(row)}];
    
    return YES;
}


#pragma mark -
#pragma mark NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger row = [[self accountsTable] selectedRow];
    [self populateFieldsForAccountAtIndex:row];
}


#pragma mark -
#pragma mark AccountSetupController notifications

- (void)accountSetupControllerDidAddAccount:(NSNotification *)notification {
    [[self accountsTable] reloadData];
    
    // Select the newly added account.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger accountsCount = [[defaults arrayForKey:UserDefaultsKeys.accounts] count];
    NSUInteger index = accountsCount - 1;
    if (index != 0) {
        [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
    
    if (accountsCount >= kAccountsMax) {
        [[self addAccountButton] setEnabled:NO];
    }
}

@end
