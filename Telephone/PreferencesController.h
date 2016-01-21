//
//  PreferencesController.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

#import <Cocoa/Cocoa.h>

#import "PreferencesControllerDelegate.h"

@protocol SoundPreferencesViewObserver;

NS_ASSUME_NONNULL_BEGIN

// Preferences window toolbar items tags.
enum {
    kGeneralPreferencesTag  = 0,
    kAccountsPreferencesTag = 1,
    kSoundPreferencesTag    = 2,
    kNetworkPreferencesTag  = 3
};

extern NSString * const kSourceIndex;
extern NSString * const kDestinationIndex;

// Notifications.
//
// Sent when preferences controller removes an accont.
// |userInfo| dictionary key: AKAccountIndex.
extern NSString * const AKPreferencesControllerDidRemoveAccountNotification;
//
// Sent when preferences controller enables or disables an account.
// |userInfo| dictionary key: AKAccountIndex.
extern NSString * const AKPreferencesControllerDidChangeAccountEnabledNotification;
//
// Sent when preferences controller changes account order.
// |userInfo| dictionary keys: AKSourceIndex, AKDestinationIndex.
extern NSString * const AKPreferencesControllerDidSwapAccountsNotification;
//
// Sent when preferences controller changes network settings.
extern NSString * const AKPreferencesControllerDidChangeNetworkSettingsNotification;

@class GeneralPreferencesViewController, AccountPreferencesViewController;
@class SoundPreferencesViewController, NetworkPreferencesViewController;

// A preferences controller.
@interface PreferencesController : NSWindowController

@property(nonatomic, readonly, weak) id<PreferencesControllerDelegate> delegate;
@property(nonatomic, readonly) id<SoundPreferencesViewObserver> soundPreferencesViewObserver;

// General preferences view controller.
@property(nonatomic, readonly) GeneralPreferencesViewController *generalPreferencesViewController;

// Account preferences view controller.
@property(nonatomic, readonly) AccountPreferencesViewController *accountPreferencesViewController;

// Sound preferences view controller.
@property(nonatomic, readonly) SoundPreferencesViewController *soundPreferencesViewController;

// Network preferences view controller.
@property(nonatomic, readonly) NetworkPreferencesViewController *networkPreferencesViewController;

// Outlets.
//
@property(nonatomic, weak) IBOutlet NSToolbar *toolbar;
@property(nonatomic, weak) IBOutlet NSToolbarItem *generalToolbarItem;
@property(nonatomic, weak) IBOutlet NSToolbarItem *accountsToolbarItem;
@property(nonatomic, weak) IBOutlet NSToolbarItem *soundToolbarItem;
@property(nonatomic, weak) IBOutlet NSToolbarItem *networkToolbarItem;

- (instancetype)initWithDelegate:(id<PreferencesControllerDelegate>)delegate
    soundPreferencesViewObserver:(id<SoundPreferencesViewObserver>)soundPreferencesViewObserver;

// Changes window's content view.
- (IBAction)changeView:(id)sender;

@end

NS_ASSUME_NONNULL_END
