//
//  PreferencesController.m
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

#import "PreferencesController.h"

#import "AKNSWindow+Resizing.h"

#import "AccountPreferencesViewController.h"
#import "GeneralPreferencesViewController.h"
#import "NetworkPreferencesViewController.h"
#import "SoundPreferencesViewController.h"

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
        _soundPreferencesViewController
            = [[SoundPreferencesViewController alloc] initWithEventTarget:_soundPreferencesViewEventTarget
                                                                userAgent:self.userAgent];
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
 soundPreferencesViewEventTarget:(SoundPreferencesViewEventTarget *)soundPreferencesViewEventTarget {
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
    [super awakeFromNib];
    if (@available(macOS 11, *)) {
        self.generalToolbarItem.image = [NSImage imageWithSystemSymbolName:@"gearshape" accessibilityDescription:nil];
        self.accountsToolbarItem.image = [NSImage imageWithSystemSymbolName:@"at" accessibilityDescription:nil];
        self.soundToolbarItem.image = [NSImage imageWithSystemSymbolName:@"speaker.wave.2" accessibilityDescription:nil];
        self.networkToolbarItem.image = [NSImage imageWithSystemSymbolName:@"network" accessibilityDescription:nil];
    } else {
        self.generalToolbarItem.image = [NSImage imageNamed:NSImageNamePreferencesGeneral];
        self.accountsToolbarItem.image = [NSImage imageNamed:NSImageNameUserAccounts];
        self.soundToolbarItem.image = [NSImage imageNamed:@"Sound"];
        self.networkToolbarItem.image = [NSImage imageNamed:NSImageNameNetwork];
    }
}

- (void)windowDidLoad {
    self.toolbar.selectedItemIdentifier = self.generalToolbarItem.itemIdentifier;
    [self.window ak_resizeForContentViewSize:self.generalPreferencesViewController.view.frame.size animate:NO];
    self.contentViewController = self.generalPreferencesViewController;
    self.window.title = self.generalPreferencesViewController.title;
}

- (IBAction)changeView:(id)sender {
    if ([self isNetworkPreferencesViewCurrent] &&
        ![sender isEqual:self.networkToolbarItem] &&
        [self.networkPreferencesViewController areNetworkSettingsChanged:sender]) {
        return;
    }
    
    NSViewController *controller;
    NSString *title;
    NSView *firstResponder;
    
    if ([sender isEqual:self.generalToolbarItem]) {
        controller = self.generalPreferencesViewController;
        title = self.generalPreferencesViewController.title;
        firstResponder = nil;
    } else if ([sender isEqual:self.accountsToolbarItem]) {
        controller = self.accountPreferencesViewController;
        title = self.accountPreferencesViewController.title;
        firstResponder = self.accountPreferencesViewController.accountsTable;
    } else if ([sender isEqual:self.soundToolbarItem]) {
        controller = self.soundPreferencesViewController;
        title = self.soundPreferencesViewController.title;
        firstResponder = nil;
    } else if ([sender isEqual:self.networkToolbarItem]) {
        controller = self.networkPreferencesViewController;
        title = self.networkPreferencesViewController.title;
        firstResponder = nil;
    } else {
        controller = nil;
        title = NSLocalizedString(@"Telephone Preferences", @"Preferences default window title.");
        firstResponder = nil;
    }

    [self.window ak_resizeForContentViewSize:controller.view.frame.size animate:YES];
    self.contentViewController = controller;
    self.window.title = controller.title;
    if ([firstResponder acceptsFirstResponder]) {
        [self.window makeFirstResponder:firstResponder];
    }
}

- (void)showWindowCentered {
    if (!self.window.isVisible) {
        [self.window center];
    }
    [self showWindow:self];
}

- (void)showAccounts {
    self.toolbar.selectedItemIdentifier = self.accountsToolbarItem.itemIdentifier;
    [self changeView:self.accountsToolbarItem];
}

- (BOOL)isNetworkPreferencesViewCurrent {
    return self.networkPreferencesViewController.isViewLoaded &&
    [self.window.contentView isEqual:self.networkPreferencesViewController.view];
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
    if ([self isNetworkPreferencesViewCurrent] &&
        [[self networkPreferencesViewController] areNetworkSettingsChanged:window]) {
        return NO;
    }
    return YES;
}

@end
