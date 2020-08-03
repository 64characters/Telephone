//
//  NetworkPreferencesViewController.m
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

#import "NetworkPreferencesViewController.h"

#import "AppController.h"
#import "PreferencesController.h"
#import "UserDefaultsKeys.h"

@implementation NetworkPreferencesViewController

- (instancetype)initWithPreferencesController:(PreferencesController *)preferencesController userAgent:(AKSIPUserAgent *)userAgent {
    self = [super initWithNibName:@"NetworkPreferencesView" bundle:nil];
    if (self != nil) {
        _preferencesController = preferencesController;
        _userAgent = userAgent;
        [self setTitle:NSLocalizedString(@"Network", @"Network preferences window title.")];
    }
    
    return self;
}

- (void)awakeFromNib {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // Subscribe to User Agent start events.
    [notificationCenter addObserver:self
                           selector:@selector(SIPUserAgentDidFinishStarting:)
                               name:AKSIPUserAgentDidFinishStartingNotification
                             object:nil];
    
    [self updateTransportPortPlaceholderWithValueFromUserAgent];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger transportPort = [defaults integerForKey:kTransportPort];
    if (transportPort > 0) {
        [[self transportPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)transportPort]];
    }
    
    [[self STUNServerHostField] setStringValue:[defaults stringForKey:kSTUNServerHost]];
    
    NSInteger STUNServerPort = [defaults integerForKey:kSTUNServerPort];
    if (STUNServerPort > 0) {
        [[self STUNServerPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)STUNServerPort]];
    }
    
    [[self useICECheckBox] setState:[defaults integerForKey:kUseICE]];
    
    [[self useDNSSRVCheckBox] setState:[defaults integerForKey:kUseDNSSRV]];
    
    [[self outboundProxyHostField] setStringValue:[defaults stringForKey:kOutboundProxyHost]];
    
    NSInteger outboundProxyPort = [defaults integerForKey:kOutboundProxyPort];
    if (outboundProxyPort > 0) {
        [[self outboundProxyPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)outboundProxyPort]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self updateDeleteOutboundProxyButtonVisibility];
}

- (IBAction)deleteOutboundProxy:(id)sender {
    self.outboundProxyHostField.stringValue = @"";
    self.outboundProxyPortField.stringValue = @"";
    [self updateDeleteOutboundProxyButtonVisibility];
}

- (void)updateDeleteOutboundProxyButtonVisibility {
    self.deleteOutboundProxyButton.hidden = self.outboundProxyHostField.stringValue.length == 0 && self.outboundProxyPortField.stringValue.length == 0;
}

- (BOOL)areNetworkSettingsChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSInteger newTransportPort = [[self transportPortField] integerValue];
    NSString *newSTUNServerHost = [[[self STUNServerHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    NSInteger newSTUNServerPort = [[self STUNServerPortField] integerValue];
    BOOL newUseICE = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
    BOOL newUseDNSSRV = ([[self useDNSSRVCheckBox] state] == NSOnState) ? YES : NO;
    NSString *newOutboundProxyHost
        = [[[self outboundProxyHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
    NSInteger newOutboundProxyPort = [[self outboundProxyPortField] integerValue];
    
    if ([defaults integerForKey:kTransportPort] != newTransportPort ||
        ![[defaults stringForKey:kSTUNServerHost] isEqualToString:newSTUNServerHost] ||
        [defaults integerForKey:kSTUNServerPort] != newSTUNServerPort ||
        [defaults boolForKey:kUseICE] != newUseICE ||
        [defaults boolForKey:kUseDNSSRV] != newUseDNSSRV ||
        ![[defaults stringForKey:kOutboundProxyHost] isEqualToString:newOutboundProxyHost] ||
        [defaults integerForKey:kOutboundProxyPort] != newOutboundProxyPort) {
        
        // Explicitly select Network toolbar item.
        [[[self preferencesController] toolbar] setSelectedItemIdentifier:
         [[[self preferencesController] networkToolbarItem] itemIdentifier]];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"Save", @"Save button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Don't Save", @"Don't save button.")];
        [[alert buttons][1] setKeyEquivalent:@"\033"];
        [alert setMessageText:NSLocalizedString(@"Save changes to the network settings?",
                                                @"Network settings change confirmation.")];
        [alert setInformativeText:NSLocalizedString(@"New network settings will be applied immediately, all "
                                                     "accounts will be reconnected.",
                                                    @"Network settings change confirmation informative text.")];

        [alert beginSheetModalForWindow:[[self preferencesController] window] completionHandler:^(NSModalResponse returnCode) {
            [self networkSettingsChangeAlertDidEndWithReturnCode:returnCode sender:sender];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)networkSettingsChangeAlertDidEndWithReturnCode:(NSModalResponse)returnCode sender:(id)sender {
    if (returnCode == NSAlertSecondButtonReturn) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    if (returnCode == NSAlertFirstButtonReturn) {
        [[self transportPortField] setPlaceholderString:[[self transportPortField] stringValue]];
        
        [defaults setInteger:[[self transportPortField] integerValue] forKey:kTransportPort];
        
        NSString *STUNServerHost = [[[self STUNServerHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        [defaults setObject:STUNServerHost forKey:kSTUNServerHost];
        
        [defaults setInteger:[[self STUNServerPortField] integerValue] forKey:kSTUNServerPort];
        
        BOOL useICEFlag = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
        [defaults setBool:useICEFlag forKey:kUseICE];
        
        BOOL newUseDNSSRVFlag = ([[self useDNSSRVCheckBox] state] == NSOnState) ? YES : NO;
        [defaults setBool:newUseDNSSRVFlag forKey:kUseDNSSRV];
        
        NSString *outboundProxyHost
            = [[[self outboundProxyHostField] stringValue] stringByTrimmingCharactersInSet:spacesSet];
        [defaults setObject:outboundProxyHost forKey:kOutboundProxyHost];
        
        [defaults setInteger:[[self outboundProxyPortField] integerValue] forKey:kOutboundProxyPort];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AKPreferencesControllerDidChangeNetworkSettingsNotification
                       object:[self preferencesController]];
        
    } else if (returnCode == NSAlertThirdButtonReturn) {
        NSInteger transportPort = [defaults integerForKey:kTransportPort];
        if (transportPort == 0) {
            [[self transportPortField] setStringValue:@""];
        } else {
            [[self transportPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)transportPort]];
        }
        
        [[self STUNServerHostField] setStringValue:[defaults stringForKey:kSTUNServerHost]];
        
        NSInteger STUNServerPort = [defaults integerForKey:kSTUNServerPort];
        if (STUNServerPort == 0) {
            [[self STUNServerPortField] setStringValue:@""];
        } else {
            [[self STUNServerPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)STUNServerPort]];
        }
        
        [[self useICECheckBox] setState:[defaults integerForKey:kUseICE]];
        
        [[self useDNSSRVCheckBox] setState:[defaults integerForKey:kUseDNSSRV]];
        
        [[self outboundProxyHostField] setStringValue:[defaults stringForKey:kOutboundProxyHost]];
        
        NSInteger outboundProxyPort = [defaults integerForKey:kOutboundProxyPort];
        if (outboundProxyPort == 0) {
            [[self outboundProxyPortField] setStringValue:@""];
        } else {
            [[self outboundProxyPortField] setStringValue:[NSString stringWithFormat:@"%ld", (long)outboundProxyPort]];
        }
    }
    
    if ([sender isMemberOfClass:[NSToolbarItem class]]) {
        [[[self preferencesController] toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
        [[self preferencesController] changeView:sender];
    } else if ([sender isMemberOfClass:[NSWindow class]]) {
        [sender close];
    }
}

- (void)updateTransportPortPlaceholderWithValueFromUserAgent {
    if (self.userAgent.isStarted) {
        [[self transportPortField] setPlaceholderString:
         [NSString stringWithFormat:@"%lu", (unsigned long)self.userAgent.transportPort]];
    }
}


#pragma mark -
#pragma mark AKSIPUserAgent notifications

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    [self updateTransportPortPlaceholderWithValueFromUserAgent];
}

@end
