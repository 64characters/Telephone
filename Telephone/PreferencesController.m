//
//  PreferencesController.m
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

#import "PreferencesController.h"

#import "AKNSWindow+Resizing.h"

#import "AccountPreferencesViewController.h"
#import "AppController.h"
#import "GeneralPreferencesViewController.h"
#import "NetworkPreferencesViewController.h"
#import "SoundPreferencesViewController.h"


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
    if (![self isSoundPreferencesViewControllerLoaded]) {
        _soundPreferencesViewController = [[SoundPreferencesViewController alloc] initWithEventTarget:_soundPreferencesViewEventTarget];
    }
    return _soundPreferencesViewController;
}

- (NetworkPreferencesViewController *)networkPreferencesViewController {
    if (_networkPreferencesViewController == nil) {
        _networkPreferencesViewController
            = [[NetworkPreferencesViewController alloc] initWithPreferencesController:self userAgent:self.userAgent];
    }
    return _networkPreferencesViewController;
}

- (BOOL)isSoundPreferencesViewControllerLoaded {
    return _soundPreferencesViewController != nil;
}

- (instancetype)initWithDelegate:(id<PreferencesControllerDelegate>)delegate
                       userAgent:(AKSIPUserAgent *)userAgent
 soundPreferencesViewEventTarget:(id<SoundPreferencesViewEventTarget>)soundPreferencesViewEventTarget {
    if ((self = [super initWithWindowNibName:@"Preferences"])) {
        self.delegate = delegate;
        _userAgent = userAgent;
        _soundPreferencesViewEventTarget = soundPreferencesViewEventTarget;
    }
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
    if ([self.window.contentView isEqual:self.networkPreferencesViewController.view] && [sender tag] != kNetworkPreferencesTag) {
        if ([self.networkPreferencesViewController checkForNetworkSettingsChanges:sender]) {
            return;
        }
    } else if ([self.window.contentView isEqual:self.soundPreferencesViewController.view] && [sender tag] != kSoundPreferencesTag) {
        [self.soundPreferencesViewController ak_viewWillDisappear];
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


#pragma mark - SoundIOPreferences

- (void)updateSoundIO {
    if ([self isSoundPreferencesViewControllerLoaded]) {
        [self.soundPreferencesViewController updateSoundIO];
    }
}


#pragma mark -
#pragma mark NSToolbar delegate

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar {
    return @[[[self generalToolbarItem] itemIdentifier],
            [[self accountsToolbarItem] itemIdentifier],
            [[self soundToolbarItem] itemIdentifier],
            [[self networkToolbarItem] itemIdentifier]];
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
    [self.soundPreferencesViewController ak_viewWillDisappear];
}

@end
