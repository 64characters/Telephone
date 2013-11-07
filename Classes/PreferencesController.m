//
//  PreferencesController.m
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

#import "PreferencesController.h"

#import "AKNSWindow+Resizing.h"

#import "AccountPreferencesViewController.h"
#import "AppController.h"
#import "GeneralPreferencesViewController.h"
#import "NetworkPreferencesViewController.h"
#import "SoundPreferencesViewController.h"


NSString * const kAccounts = @"Accounts";
NSString * const kSTUNServerHost = @"STUNServerHost";
NSString * const kSTUNServerPort = @"STUNServerPort";
NSString * const kSTUNDomain = @"STUNDomain";
NSString * const kLogFileName = @"LogFileName";
NSString * const kLogLevel = @"LogLevel";
NSString * const kConsoleLogLevel = @"ConsoleLogLevel";
NSString * const kVoiceActivityDetection = @"VoiceActivityDetection";
NSString * const kTransportPort = @"TransportPort";
NSString * const kTransportPublicHost = @"TransportPublicHost";
NSString * const kSoundInput = @"SoundInput";
NSString * const kSoundOutput = @"SoundOutput";
NSString * const kRingtoneOutput = @"RingtoneOutput";
NSString * const kRingingSound = @"RingingSound";
NSString * const kFormatTelephoneNumbers = @"FormatTelephoneNumbers";
NSString * const kTelephoneNumberFormatterSplitsLastFourDigits = @"TelephoneNumberFormatterSplitsLastFourDigits";
NSString * const kOutboundProxyHost = @"OutboundProxyHost";
NSString * const kOutboundProxyPort = @"OutboundProxyPort";
NSString * const kUseICE = @"UseICE";
NSString * const kUseDNSSRV = @"UseDNSSRV";
NSString * const kSignificantPhoneNumberLength = @"SignificantPhoneNumberLength";
NSString * const kPauseITunes = @"PauseITunes";
NSString * const kAutoCloseCallWindow = @"AutoCloseCallWindow";
NSString * const kAutoCloseMissedCallWindow = @"AutoCloseMissedCallWindow";
NSString * const kCallWaiting = @"CallWaiting";
NSString * const kShowGrowlNotifications = @"ShowGrowlNotifications";
NSString * const kUseG711Only = @"UseG711Only";;

NSString * const kDescription = @"Description";
NSString * const kFullName = @"FullName";
NSString * const kSIPAddress = @"SIPAddress";
NSString * const kRegistrar = @"Registrar";
NSString * const kDomain = @"Domain";
NSString * const kRealm = @"Realm";
NSString * const kUsername = @"Username";
NSString * const kAccountIndex = @"AccountIndex";
NSString * const kAccountEnabled = @"AccountEnabled";
NSString * const kReregistrationTime = @"ReregistrationTime";
NSString * const kSubstitutePlusCharacter = @"SubstitutePlusCharacter";
NSString * const kPlusCharacterSubstitutionString = @"PlusCharacterSubstitutionString";
NSString * const kUseProxy = @"UseProxy";
NSString * const kProxyHost = @"ProxyHost";
NSString * const kProxyPort = @"ProxyPort";

NSString * const kSourceIndex = @"SourceIndex";
NSString * const kDestinationIndex = @"DestinationIndex";

NSString * const AKPreferencesControllerDidRemoveAccountNotification = @"AKPreferencesControllerDidRemoveAccount";
NSString * const AKPreferencesControllerDidChangeAccountEnabledNotification
    = @"AKPreferencesControllerDidChangeAccountEnabled";
NSString * const AKPreferencesControllerDidSwapAccountsNotification = @"AKPreferencesControllerDidSwapAccounts";
NSString * const AKPreferencesControllerDidChangeNetworkSettingsNotification
    = @"AKPreferencesControllerDidChangeNetworkSettings";

@implementation PreferencesController

@synthesize generalPreferencesViewController = _generalPreferencesViewController;
@synthesize accountPreferencesViewController = _accountPreferencesViewController;
@synthesize soundPreferencesViewController = _soundPreferencesViewController;
@synthesize networkPreferencesViewController = _networkPreferencesViewController;

- (void)setDelegate:(id)aDelegate {
    if (_delegate == aDelegate) {
        return;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if (_delegate != nil)
        [nc removeObserver:_delegate name:nil object:self];
    
    if (aDelegate != nil) {
        if ([aDelegate respondsToSelector:@selector(preferencesControllerDidRemoveAccount:)]) {
            [nc addObserver:aDelegate
                   selector:@selector(preferencesControllerDidRemoveAccount:)
                       name:AKPreferencesControllerDidRemoveAccountNotification
                     object:self];
        }
        
        if ([aDelegate respondsToSelector:@selector(preferencesControllerDidChangeAccountEnabled:)]) {
            [nc addObserver:aDelegate
                   selector:@selector(preferencesControllerDidChangeAccountEnabled:)
                       name:AKPreferencesControllerDidChangeAccountEnabledNotification
                     object:self];
        }
        
        if ([aDelegate respondsToSelector:@selector(preferencesControllerDidSwapAccounts:)]) {
            [nc addObserver:aDelegate
                   selector:@selector(preferencesControllerDidSwapAccounts:)
                       name:AKPreferencesControllerDidSwapAccountsNotification
                     object:self];
        }
        
        if ([aDelegate respondsToSelector:@selector(preferencesControllerDidChangeNetworkSettings:)]) {
            [nc addObserver:aDelegate
                   selector:@selector(preferencesControllerDidChangeNetworkSettings:)
                       name:AKPreferencesControllerDidChangeNetworkSettingsNotification
                     object:self];
        }
    }
    
    _delegate = aDelegate;
}

- (GeneralPreferencesViewController *)generalPreferencesViewController {
    if (_generalPreferencesViewController == nil) {
        _generalPreferencesViewController = [[GeneralPreferencesViewController alloc] init];
    }
    return _generalPreferencesViewController;
}

- (AccountPreferencesViewController *)accountPreferencesViewController {
    if (_accountPreferencesViewController == nil) {
        _accountPreferencesViewController = [[AccountPreferencesViewController alloc] init];
        [_accountPreferencesViewController setPreferencesController:self];
    }
    return _accountPreferencesViewController;
}

- (SoundPreferencesViewController *)soundPreferencesViewController {
    if (_soundPreferencesViewController == nil) {
        _soundPreferencesViewController = [[SoundPreferencesViewController alloc] init];
    }
    return _soundPreferencesViewController;
}

- (NetworkPreferencesViewController *)networkPreferencesViewController {
    if (_networkPreferencesViewController == nil) {
        _networkPreferencesViewController = [[NetworkPreferencesViewController alloc] init];
        [_networkPreferencesViewController setPreferencesController:self];
    }
    return _networkPreferencesViewController;
}

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    
    return self;
}

- (void)dealloc {
    [self setDelegate:nil];
}

- (void)awakeFromNib {
    
}

- (void)windowDidLoad {
    [[self toolbar] setSelectedItemIdentifier:[[self generalToolbarItem] itemIdentifier]];
    [[self window] ak_resizeAndSwapToContentView:[[self generalPreferencesViewController] view]];
    [[self window] setTitle:[[self generalPreferencesViewController] title]];
}

- (IBAction)changeView:(id)sender {
    // If the user switches from Network to some other view, check for network settings changes.
    NSView *contentView = [[self window] contentView];
    NSView *networkPreferencesView = [[self networkPreferencesViewController] view];
    
    if ([contentView isEqual:networkPreferencesView] && [sender tag] != kNetworkPreferencesTag) {
        if ([[self networkPreferencesViewController] checkForNetworkSettingsChanges:sender]) {
            return;
        }
    }
    
    NSView *view;
    NSString *title;
    NSView *firstResponderView;
    
    switch ([sender tag]) {
        case kGeneralPreferencesTag:
            view = [[self generalPreferencesViewController] view];
            title = [[self generalPreferencesViewController] title];
            firstResponderView = nil;
            break;
        case kAccountsPreferencesTag:
            view = [[self accountPreferencesViewController] view];
            title = [[self accountPreferencesViewController] title];
            firstResponderView = [[self accountPreferencesViewController] accountsTable];
            break;
        case kSoundPreferencesTag:
            view = [[self soundPreferencesViewController] view];
            title = [[self soundPreferencesViewController] title];
            firstResponderView = nil;
            break;
        case kNetworkPreferencesTag:
            view = [[self networkPreferencesViewController] view];
            title = [[self networkPreferencesViewController] title];
            firstResponderView = nil;
            break;
        default:
            view = nil;
            title = NSLocalizedString(@"Telephone Preferences", @"Preferences default window title.");
            firstResponderView = nil;
            break;
    }
    
    [[self window] ak_resizeAndSwapToContentView:view animate:YES];
    [[self window] setTitle:title];
    if ([firstResponderView acceptsFirstResponder]) {
        [[self window] makeFirstResponder:firstResponderView];
    }
}


#pragma mark -
#pragma mark NSToolbar delegate

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar {
    return [NSArray arrayWithObjects:
            [[self generalToolbarItem] itemIdentifier],
            [[self accountsToolbarItem] itemIdentifier],
            [[self soundToolbarItem] itemIdentifier],
            [[self networkToolbarItem] itemIdentifier],
            nil];
}


#pragma mark -
#pragma mark NSWindow delegate

- (BOOL)windowShouldClose:(id)window {
    if (_networkPreferencesViewController != nil) {
        BOOL networkSettingsChanged = [[self networkPreferencesViewController] checkForNetworkSettingsChanges:window];
        if (networkSettingsChanged) {
            return NO;
        }
    }
    
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
    // Stop currently playing ringtone that might be selected in Preferences.
    [[[NSApp delegate] ringtone] stop];
}

@end
