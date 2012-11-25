//
//  NetworkPreferencesViewController.m
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

#import "NetworkPreferencesViewController.h"

#import "AppController.h"
#import "PreferencesController.h"


@interface NetworkPreferencesViewController ()

// Method to be called when an alert about network changes is dismissed.
- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end

@implementation NetworkPreferencesViewController

@synthesize preferencesController = preferencesController_;

@synthesize transportPortField = transportPortField_;
@synthesize STUNServerHostField = STUNServerHostField_;
@synthesize STUNServerPortField = STUNServerPortField_;
@synthesize useICECheckBox = useICECheckBox_;
@synthesize useDNSSRVCheckBox = useDNSSRVCheckBox_;
@synthesize outboundProxyHostField = outboundProxyHostField_;
@synthesize outboundProxyPortField = outboundProxyPortField_;

- (id)init {
    self = [super initWithNibName:@"NetworkPreferencesView" bundle:nil];
    if (self != nil) {
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
    
    // Show user agent's current transport port as a placeholder string.
    if ([[[NSApp delegate] userAgent] isStarted]) {
        [[[self transportPortField] cell] setPlaceholderString:
         [[NSNumber numberWithUnsignedInteger:[[[NSApp delegate] userAgent] transportPort]] stringValue]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:kTransportPort] > 0) {
        [[self transportPortField] setIntegerValue:[defaults integerForKey:kTransportPort]];
    }
    
    [[self STUNServerHostField] setStringValue:[defaults stringForKey:kSTUNServerHost]];
    
    if ([defaults integerForKey:kSTUNServerPort] > 0) {
        [[self STUNServerPortField] setIntegerValue:[defaults integerForKey:kSTUNServerPort]];
    }
    
    [[self useICECheckBox] setState:[defaults integerForKey:kUseICE]];
    
    [[self useDNSSRVCheckBox] setState:[defaults integerForKey:kUseDNSSRV]];
    
    [[self outboundProxyHostField] setStringValue:[defaults stringForKey:kOutboundProxyHost]];
    
    if ([defaults integerForKey:kOutboundProxyPort] > 0) {
        [[self outboundProxyPortField] setIntegerValue:[defaults integerForKey:kOutboundProxyPort]];
    }
}

- (void)dealloc {
    [transportPortField_ release];
    [STUNServerHostField_ release];
    [STUNServerPortField_ release];
    [useICECheckBox_ release];
    [useDNSSRVCheckBox_ release];
    [outboundProxyHostField_ release];
    [outboundProxyPortField_ release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (BOOL)checkForNetworkSettingsChanges:(id)sender {
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
        
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:NSLocalizedString(@"Save", @"Save button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
        [alert addButtonWithTitle:NSLocalizedString(@"Don't Save", @"Don't save button.")];
        [[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
        [alert setMessageText:NSLocalizedString(@"Save changes to the network settings?",
                                                @"Network settings change confirmation.")];
        [alert setInformativeText:NSLocalizedString(@"New network settings will be applied immediately, all "
                                                     "accounts will be reconnected.",
                                                    @"Network settings change confirmation informative text.")];
        
        [alert beginSheetModalForWindow:[[self preferencesController] window]
                          modalDelegate:self
                         didEndSelector:@selector(networkSettingsChangeAlertDidEnd:returnCode:contextInfo:)
                            contextInfo:sender];
        return YES;
    }
    
    return NO;
}

- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    [[alert window] orderOut:nil];
    
    if (returnCode == NSAlertSecondButtonReturn) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSCharacterSet *spacesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    id sender = (id)contextInfo;
    
    if (returnCode == NSAlertFirstButtonReturn) {
        [[[self transportPortField] cell] setPlaceholderString:[[self transportPortField] stringValue]];
        
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
        if ([defaults integerForKey:kTransportPort] == 0) {
            [[self transportPortField] setStringValue:@""];
        } else {
            [[self transportPortField] setIntegerValue:[defaults integerForKey:kTransportPort]];
        }
        
        [[self STUNServerHostField] setStringValue:[defaults stringForKey:kSTUNServerHost]];
        
        if ([defaults integerForKey:kSTUNServerPort] == 0) {
            [[self STUNServerPortField] setStringValue:@""];
        } else {
            [[self STUNServerPortField] setIntegerValue:[defaults integerForKey:kSTUNServerPort]];
        }
        
        [[self useICECheckBox] setState:[defaults integerForKey:kUseICE]];
        
        [[self useDNSSRVCheckBox] setState:[defaults integerForKey:kUseDNSSRV]];
        
        [[self outboundProxyHostField] setStringValue:[defaults stringForKey:kOutboundProxyHost]];
        
        if ([defaults integerForKey:kOutboundProxyPort] == 0) {
            [[self outboundProxyPortField] setStringValue:@""];
        } else {
            [[self outboundProxyPortField] setIntegerValue:[defaults integerForKey:kOutboundProxyPort]];
        }
    }
    
    if ([sender isMemberOfClass:[NSToolbarItem class]]) {
        [[[self preferencesController] toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
        [[self preferencesController] changeView:sender];
    } else if ([sender isMemberOfClass:[NSWindow class]]) {
        [sender close];
    }
}


#pragma mark -
#pragma mark AKSIPUserAgent notifications

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    if (![[[NSApp delegate] userAgent] isStarted]) {
        return;
    }
    
    // Show transport port in the network preferences as a placeholder string.
    [[[self transportPortField] cell] setPlaceholderString:
     [[NSNumber numberWithUnsignedInteger:[[[NSApp delegate] userAgent] transportPort]] stringValue]];
}

@end
