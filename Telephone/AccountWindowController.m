//
//  AccountWindowController.m
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

#import "AccountWindowController.h"

#import "AccountViewController.h"

#import "Telephone-Swift.h"

// Account state toolbar item widths.
//
// English.
static const CGFloat kOfflineEnglishWidth = 73.0;
static const CGFloat kAvailableEnglishWidth = 84.0;
static const CGFloat kUnavailableEnglishWidth = 97.0;
static const CGFloat kConnectingEnglishWidth = 108.0;
//
// Russian.
static const CGFloat kOfflineRussianWidth = 81.0;
static const CGFloat kAvailableRussianWidth = 90.0;
static const CGFloat kUnavailableRussianWidth = 103.0;
static const CGFloat kConnectingRussianWidth = 115.0;
//
// German.
static const CGFloat kOfflineGermanWidth = 73.0;
static const CGFloat kAvailableGermanWidth = 90.0;
static const CGFloat kUnavailableGermanWidth = 120.0;
static const CGFloat kConnectingGermanWidth = 104.0;

static NSString * const kEnglish = @"en";
static NSString * const kRussian = @"ru";
static NSString * const kGerman = @"de";

@interface AccountWindowController ()

@property(nonatomic, readonly) NSString *accountDescription;
@property(nonatomic, readonly) NSString *SIPAddress;
@property(nonatomic, readonly) AccountViewController *accountViewController;
@property(nonatomic, readonly, weak) id<AccountWindowControllerDelegate> delegate;

@property(nonatomic, weak) IBOutlet NSToolbarItem *accountStateToolbarItem;
@property(nonatomic, weak) IBOutlet NSImageView *accountStateImageView;
@property(nonatomic, weak) IBOutlet NSPopUpButton *accountStatePopUp;
@property(nonatomic, weak) IBOutlet NSMenuItem *availableStateItem;
@property(nonatomic, weak) IBOutlet NSMenuItem *unavailableStateItem;
@property(nonatomic, weak) IBOutlet NSMenuItem *offlineStateItem;

@end

@implementation AccountWindowController

- (BOOL)allowsCallDestinationInput {
    return self.accountViewController.allowsCallDestinationInput;
}

- (instancetype)initWithAccountDescription:(NSString *)accountDescription
                                SIPAddress:(NSString *)SIPAddress
                     accountViewController:(AccountViewController *)accountViewController
                                  delegate:(id<AccountWindowControllerDelegate>)delegate {

    NSParameterAssert(accountDescription);
    NSParameterAssert(SIPAddress);
    NSParameterAssert(accountViewController);
    NSParameterAssert(delegate);
    if ((self = [super initWithWindowNibName:@"Account"])) {
        _accountDescription = [accountDescription copy];
        _SIPAddress = [SIPAddress copy];
        _accountViewController = accountViewController;
        _delegate = delegate;
    }
    return self;
}

- (void)awakeFromNib {
    self.shouldCascadeWindows = NO;
}

- (void)windowDidLoad {
    self.window.title = self.accountDescription;
    self.window.frameAutosaveName = self.SIPAddress;
    self.window.excludedFromWindowsMenu = YES;

    [self.window.contentView addSubview:self.accountViewController.view];
    self.accountViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"view": self.accountViewController.view};
    [self.window.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
    [self.window.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];

    [self showOfflineStateAnimated:NO];
}

#pragma mark -

- (void)showAvailableState {
    NSSize size = self.accountStateToolbarItem.maxSize;
    NSString *localization = [NSBundle mainBundle].preferredLocalizations[0];
    if ([localization isEqualToString:kEnglish]) {
        size.width = kAvailableEnglishWidth;
    } else if ([localization isEqualToString:kRussian]) {
        size.width = kAvailableRussianWidth;
    } else if ([localization isEqualToString:kGerman]) {
        size.width = kAvailableGermanWidth;
    }
    self.accountStateToolbarItem.maxSize = size;

    self.accountStatePopUp.title = NSLocalizedString(@"Available", @"Account registration Available menu item.");
    self.accountStateImageView.image = [NSImage imageNamed:@"available-state"];

    self.availableStateItem.state = NSOnState;
    self.unavailableStateItem.state = NSOffState;

    [self.accountViewController showActiveState];
}

- (void)showUnavailableState {
    NSSize size = self.accountStateToolbarItem.maxSize;
    NSString *localization = [NSBundle mainBundle].preferredLocalizations[0];
    if ([localization isEqualToString:kEnglish]) {
        size.width = kUnavailableEnglishWidth;
    } else if ([localization isEqualToString:kRussian]) {
        size.width = kUnavailableRussianWidth;
    } else if ([localization isEqualToString:kGerman]) {
        size.width = kUnavailableGermanWidth;
    }
    self.accountStateToolbarItem.maxSize = size;

    self.accountStatePopUp.title = NSLocalizedString(@"Unavailable", @"Account registration Unavailable menu item.");
    self.accountStateImageView.image = [NSImage imageNamed:@"unavailable-state"];

    self.availableStateItem.state = NSOffState;
    self.unavailableStateItem.state = NSOnState;

    [self.accountViewController showActiveState];
}

- (void)showOfflineStateAnimated:(BOOL)animated {
    NSSize size = self.accountStateToolbarItem.maxSize;
    NSString *localization = [NSBundle mainBundle].preferredLocalizations[0];
    if ([localization isEqualToString:kEnglish]) {
        size.width = kOfflineEnglishWidth;
    } else if ([localization isEqualToString:kRussian]) {
        size.width = kOfflineRussianWidth;
    } else if ([localization isEqualToString:kGerman]) {
        size.width = kOfflineGermanWidth;
    }
    self.accountStateToolbarItem.maxSize = size;

    self.accountStatePopUp.title = NSLocalizedString(@"Offline", @"Account registration Offline menu item.");
    self.accountStateImageView.image = [NSImage imageNamed:@"offline-state"];

    self.availableStateItem.state = NSOffState;
    self.unavailableStateItem.state = NSOffState;

    [self.accountViewController showInactiveStateAnimated:animated];
}

- (void)showOfflineState {
    [self showOfflineStateAnimated:YES];
}

- (void)showConnectingState {
    NSSize size = [[self accountStateToolbarItem] maxSize];
    NSString *localization = [[NSBundle mainBundle] preferredLocalizations][0];
    if ([localization isEqualToString:kEnglish]) {
        size.width = kConnectingEnglishWidth;
    } else if ([localization isEqualToString:kRussian]) {
        size.width = kConnectingRussianWidth;
    } else if ([localization isEqualToString:kGerman]) {
        size.width = kConnectingGermanWidth;
    }
    [[self accountStateToolbarItem] setMaxSize:size];

    [[self accountStatePopUp] setTitle:
     NSLocalizedString(@"Connecting...", @"Account registration Connecting... menu item.")];
}

- (void)makeCallToDestination:(NSString *)destination {
    [self.accountViewController makeCallToDestination:destination];
}

- (IBAction)changeAccountState:(NSPopUpButton *)sender {
    if ([sender.selectedItem isEqual:self.offlineStateItem]) {
        [self.delegate accountWindowController:self didChangeAccountState:AccountWindowControllerAccountStateOffline];
    } else if ([sender.selectedItem isEqual:self.availableStateItem]) {
        [self.delegate accountWindowController:self didChangeAccountState:AccountWindowControllerAccountStateAvailable];
    } else if ([sender.selectedItem isEqual:self.unavailableStateItem]) {
        [self.delegate accountWindowController:self didChangeAccountState:AccountWindowControllerAccountStateUnavailable];
    }
}

- (void)showAlert:(NSAlert *)alert {
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

- (void)beginSheet:(NSWindow *)sheet {
    [self.window beginSheet:sheet completionHandler:nil];
}

- (void)showWindowWithoutMakingKey {
    [self.window orderFront:self];
}

- (void)hideWindow {
    [self.window orderOut:self];
}

- (BOOL)isWindowKey {
    return self.window.isKeyWindow;
}

- (void)orderWindow:(NSWindowOrderingMode)place relativeTo:(NSInteger)otherWindow {
    [self.window orderWindow:place relativeTo:otherWindow];
}

- (NSInteger)windowNumber {
    return self.window.windowNumber;
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(id)sender {
    [self.window orderOut:self];
    return NO;
}

@end
