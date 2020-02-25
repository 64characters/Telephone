//
//  AccountPreferencesViewController.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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
#import "UserDefaultsKeys.h"


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
    NSUInteger accountsCount = [[defaults arrayForKey:kAccounts] count];
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
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete button.")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
    [[alert buttons][1] setKeyEquivalent:@"\033"];
    [alert setMessageText:[NSString stringWithFormat:
                           NSLocalizedString(@"Delete “%@”?", @"Account removal confirmation."),
                           selectedAccount]];
    [alert setInformativeText:
     [NSString stringWithFormat:
      NSLocalizedString(@"This will delete your currently set up account “%@”.",
                        @"Account removal confirmation informative text."),
      selectedAccount]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[[self accountsTable] window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self removeAccountAtIndex:[[self accountsTable] selectedRow]];
        }
    }];
}

- (void)removeAccountAtIndex:(NSInteger)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
    NSString *uuid = savedAccounts[index][kUUID];
    [savedAccounts removeObjectAtIndex:index];
    [defaults setObject:savedAccounts forKey:kAccounts];
    
    if ([savedAccounts count] < kAccountsMax) {
        [[self addAccountButton] setEnabled:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKPreferencesControllerDidRemoveAccountNotification
                                                        object:[self preferencesController]
                                                      userInfo:@{kAccountIndex: @(index), kUUID: uuid}];
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
    NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
    
    if (index >= 0) {
        NSDictionary *accountDict = savedAccounts[index];
        
        [[self accountEnabledCheckBox] setEnabled:YES];
        
        // Conditionally enable fields and set checkboxes state.
        if ([accountDict[kAccountEnabled] boolValue]) {
            [[self accountEnabledCheckBox] setState:NSOnState];
            [[self accountDescriptionField] setEnabled:NO];
            [[self fullNameField] setEnabled:NO];
            [[self domainField] setEnabled:NO];
            [[self usernameField] setEnabled:NO];
            [[self passwordField] setEnabled:NO];
            [[self reregistrationTimeField] setEnabled:NO];
            [[self substitutePlusCharacterCheckBox] setEnabled:NO];
            [[self substitutePlusCharacterCheckBox] setState:[accountDict[kSubstitutePlusCharacter] integerValue]];
            [[self plusCharacterSubstitutionField] setEnabled:NO];
            [[self plusCharacterSubstitutionLabel] setTextColor:[NSColor disabledControlTextColor]];
            [[self useProxyCheckBox] setState:[accountDict[kUseProxy] integerValue]];
            [[self useProxyCheckBox] setEnabled:NO];
            [[self proxyHostField] setEnabled:NO];
            [[self proxyPortField] setEnabled:NO];
            [[self SIPAddressField] setEnabled:NO];
            [[self registrarField] setEnabled:NO];
            [[self cantEditAccountLabel] setHidden:NO];
            [[self updateIPAddressCheckBox] setEnabled:NO];
            [[self useIPv6OnlyCheckBox] setEnabled:NO];
            
        } else {
            [[self accountEnabledCheckBox] setState:NSOffState];
            [[self accountDescriptionField] setEnabled:YES];
            [[self fullNameField] setEnabled:YES];
            [[self domainField] setEnabled:YES];
            [[self usernameField] setEnabled:YES];
            [[self passwordField] setEnabled:YES];
            
            [[self reregistrationTimeField] setEnabled:YES];
            [[self substitutePlusCharacterCheckBox] setEnabled:YES];
            [[self substitutePlusCharacterCheckBox] setState:[accountDict[kSubstitutePlusCharacter] integerValue]];
            if ([[self substitutePlusCharacterCheckBox] state] == NSOnState) {
                [[self plusCharacterSubstitutionField] setEnabled:YES];
            } else {
                [[self plusCharacterSubstitutionField] setEnabled:NO];
            }
            [[self plusCharacterSubstitutionLabel] setTextColor:[NSColor controlTextColor]];
            
            [[self useProxyCheckBox] setEnabled:YES];
            [[self useProxyCheckBox] setState:[accountDict[kUseProxy] integerValue]];
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
            [[self updateIPAddressCheckBox] setEnabled:YES];
            [[self useIPv6OnlyCheckBox] setEnabled:YES];
        }
        
        // Populate fields.
        
        // Description.
        if ([accountDict[kDescription] length] > 0) {
            [[self accountDescriptionField] setStringValue:accountDict[kDescription]];
        } else {
            [[self accountDescriptionField] setStringValue:@""];
        }
        
        // Description's placeholder string.
        if ([accountDict[kSIPAddress] length] > 0) {
            [[self accountDescriptionField] setPlaceholderString:accountDict[kSIPAddress]];
        } else {
            [[self accountDescriptionField] setPlaceholderString:
             [[SIPAddress alloc] initWithUser:accountDict[kUsername] host:accountDict[kDomain]].stringValue];
        }
        
        // Full Name.
        [[self fullNameField] setStringValue:accountDict[kFullName]];
        
        // Domain.
        if ([accountDict[kDomain] length] > 0) {
            [[self domainField] setStringValue:accountDict[kDomain]];
        } else {
            [[self domainField] setStringValue:@""];
        }
        
        // User Name.
        [[self usernameField] setStringValue:accountDict[kUsername]];
        
        NSString *keychainService;
        if ([accountDict[kRegistrar] length] > 0) {
            keychainService = [NSString stringWithFormat:@"SIP: %@", accountDict[kRegistrar]];
        } else {
            keychainService = [NSString stringWithFormat:@"SIP: %@", accountDict[kDomain]];
        }
        
        // Password.
        [[self passwordField] setStringValue:[AKKeychain passwordForService:keychainService account:accountDict[kUsername]]];
        
        // Reregister every...
        if ([accountDict[kReregistrationTime] integerValue] > 0) {
            [[self reregistrationTimeField] setStringValue:[accountDict[kReregistrationTime] stringValue]];
        } else {
            [[self reregistrationTimeField] setStringValue:@""];
        }
        
        // Substitute ... for "+".
        if (accountDict[kPlusCharacterSubstitutionString] != nil) {
            [[self plusCharacterSubstitutionField] setStringValue:
             accountDict[kPlusCharacterSubstitutionString]];
        } else {
            [[self plusCharacterSubstitutionField] setStringValue:@"00"];
        }
        
        // Proxy Server.
        if ([accountDict[kProxyHost] length] > 0) {
            [[self proxyHostField] setStringValue:accountDict[kProxyHost]];
        } else {
            [[self proxyHostField] setStringValue:@""];
        }
        
        // Proxy Port.
        if ([accountDict[kProxyPort] integerValue] > 0) {
            [[self proxyPortField] setStringValue:[accountDict[kProxyPort] stringValue]];
        } else {
            [[self proxyPortField] setStringValue:@""];
        }
        
        // SIP Address.
        if ([accountDict[kSIPAddress] length] > 0) {
            [[self SIPAddressField] setStringValue:accountDict[kSIPAddress]];
        } else {
            [[self SIPAddressField] setStringValue:@""];
        }
        
        // Registry Server.
        if ([accountDict[kRegistrar] length] > 0) {
            [[self registrarField] setStringValue:accountDict[kRegistrar]];
        } else {
            [[self registrarField] setStringValue:@""];
        }
        
        // SIP Address and Registry Server placeholder strings.
        if ([accountDict[kDomain] length] > 0) {
            [[self SIPAddressField] setPlaceholderString:[[SIPAddress alloc] initWithUser:accountDict[kUsername] host:accountDict[kDomain]].stringValue];
            [[self registrarField] setPlaceholderString:accountDict[kDomain]];
        } else {
            [[self SIPAddressField] setPlaceholderString:nil];
            [[self registrarField] setPlaceholderString:nil];
        }
        
        // Update headers checkbox.
        if ([accountDict[kUpdateContactHeader] boolValue] && [accountDict[kUpdateViaHeader] boolValue] && [accountDict[kUpdateSDP] boolValue]) {
            [[self updateIPAddressCheckBox] setAllowsMixedState:NO];
            [[self updateIPAddressCheckBox] setState:NSOnState];
        } else if ([accountDict[kUpdateContactHeader] boolValue] || [accountDict[kUpdateViaHeader] boolValue] || [accountDict[kUpdateSDP] boolValue]) {
            [[self updateIPAddressCheckBox] setAllowsMixedState:YES];
            [[self updateIPAddressCheckBox] setState:NSMixedState];
        } else {
            [[self updateIPAddressCheckBox] setAllowsMixedState:NO];
            [[self updateIPAddressCheckBox] setState:NSOffState];
        }

        // Use IPv6 Only checkbox.
        [[self useIPv6OnlyCheckBox] setState:[accountDict[kUseIPv6Only] integerValue]];
        
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
        [[self updateIPAddressCheckBox] setState:NSOffState];
        [[self useIPv6OnlyCheckBox] setState:NSOffState];
        
        [[self accountEnabledCheckBox] setEnabled:NO];
        [[self accountDescriptionField] setEnabled:NO];
        [[self fullNameField] setEnabled:NO];
        [[self domainField] setEnabled:NO];
        [[self usernameField] setEnabled:NO];
        [[self passwordField] setEnabled:NO];
        [[self reregistrationTimeField] setEnabled:NO];
        [[self substitutePlusCharacterCheckBox] setEnabled:NO];
        [[self plusCharacterSubstitutionField] setEnabled:NO];
        [[self plusCharacterSubstitutionLabel] setTextColor:[NSColor disabledControlTextColor]];
        [[self useProxyCheckBox] setEnabled:NO];
        [[self proxyHostField] setEnabled:NO];
        [[self proxyPortField] setEnabled:NO];
        [[self SIPAddressField] setEnabled:NO];
        [[self SIPAddressField] setPlaceholderString:nil];
        [[self registrarField] setEnabled:NO];
        [[self registrarField] setPlaceholderString:nil];
        [[self cantEditAccountLabel] setHidden:YES];
        [[self updateIPAddressCheckBox] setEnabled:NO];
        [[self useIPv6OnlyCheckBox] setEnabled:NO];
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
    
    NSMutableArray *savedAccounts = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
    
    NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary:savedAccounts[index]];
    
    BOOL isChecked = [[self accountEnabledCheckBox] state] == NSOnState;
    accountDict[kAccountEnabled] = @(isChecked);
    
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
        
        accountDict[kDescription] = accountDescription;
        accountDict[kFullName] = fullName;
        accountDict[kDomain] = domain;
        accountDict[kUsername] = username;
        
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
        
        accountDict[kReregistrationTime] = @([[self reregistrationTimeField] integerValue]);
        
        accountDict[kSubstitutePlusCharacter] = @([[self substitutePlusCharacterCheckBox] state] == NSOnState);
        accountDict[kPlusCharacterSubstitutionString] = [[self plusCharacterSubstitutionField] stringValue];
        
        accountDict[kUseProxy] = @([[self useProxyCheckBox] state] == NSOnState);
        NSString *proxyHost = [[[self proxyHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        accountDict[kProxyHost] = proxyHost;
        accountDict[kProxyPort] = @([[self proxyPortField] integerValue]);
        
        NSString *sipAddress = [[[self SIPAddressField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        accountDict[kSIPAddress] = sipAddress;
        
        accountDict[kRegistrar] = registrar;
        
        if (self.updateIPAddressCheckBox.state == NSOnState) {
            accountDict[kUpdateContactHeader] = @YES;
            accountDict[kUpdateViaHeader] = @YES;
            accountDict[kUpdateSDP] = @YES;
        } else if (self.updateIPAddressCheckBox.state == NSMixedState) {
            accountDict[kUpdateContactHeader] = @YES;
            accountDict[kUpdateViaHeader] = @YES;
            accountDict[kUpdateSDP] = @NO;
        } else {
            accountDict[kUpdateContactHeader] = @NO;
            accountDict[kUpdateViaHeader] = @NO;
            accountDict[kUpdateSDP] = @NO;
        }

        accountDict[kUseIPv6Only] = @(self.useIPv6OnlyCheckBox.state == NSOnState);
        
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
        [[self plusCharacterSubstitutionLabel] setTextColor:[NSColor disabledControlTextColor]];
        [[self useProxyCheckBox] setEnabled:NO];
        [[self proxyHostField] setEnabled:NO];
        [[self proxyPortField] setEnabled:NO];
        [[self SIPAddressField] setEnabled:NO];
        [[self registrarField] setEnabled:NO];
        [[self cantEditAccountLabel] setHidden:NO];
        [[self updateIPAddressCheckBox] setEnabled:NO];
        [[self useIPv6OnlyCheckBox] setEnabled:NO];
        
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
        [[self substitutePlusCharacterCheckBox] setState:[accountDict[kSubstitutePlusCharacter] integerValue]];
        if ([[self substitutePlusCharacterCheckBox] state] == NSOnState) {
            [[self plusCharacterSubstitutionField] setEnabled:YES];
        }
        [[self plusCharacterSubstitutionLabel] setTextColor:[NSColor controlTextColor]];
        
        [[self useProxyCheckBox] setEnabled:YES];
        [[self useProxyCheckBox] setState:[accountDict[kUseProxy] integerValue]];
        if ([[self useProxyCheckBox] state] == NSOnState) {
            [[self proxyHostField] setEnabled:YES];
            [[self proxyPortField] setEnabled:YES];
        }
        
        [[self SIPAddressField] setEnabled:YES];
        [[self registrarField] setEnabled:YES];
        [[self cantEditAccountLabel] setHidden:YES];
        [[self updateIPAddressCheckBox] setEnabled:YES];
        [[self useIPv6OnlyCheckBox] setEnabled:YES];
    }
    
    savedAccounts[index] = accountDict;
    
    [defaults setObject:savedAccounts forKey:kAccounts];
    
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


#pragma mark -
#pragma mark NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults arrayForKey:kAccounts] count];
}

- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(NSInteger)rowIndex {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *accountDict = [defaults arrayForKey:kAccounts][rowIndex];
    
    NSString *returnValue;
    NSString *accountDescription = accountDict[kDescription];
    if ([accountDescription length] > 0) {
        returnValue = accountDescription;
        
    } else {
        NSString *sipAddress;
        if ([accountDict[kSIPAddress] length] > 0) {
            sipAddress = accountDict[kSIPAddress];
        } else {
            sipAddress = [[SIPAddress alloc] initWithUser:accountDict[kUsername] host:accountDict[kDomain]].stringValue;
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
    NSMutableArray *accounts = [[defaults arrayForKey:kAccounts] mutableCopy];
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
    
    [defaults setObject:accounts forKey:kAccounts];
    
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
    NSUInteger accountsCount = [[defaults arrayForKey:kAccounts] count];
    NSUInteger index = accountsCount - 1;
    if (index != 0) {
        [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
    
    if (accountsCount >= kAccountsMax) {
        [[self addAccountButton] setEnabled:NO];
    }
}

@end
