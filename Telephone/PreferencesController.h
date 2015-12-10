//
//  PreferencesController.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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
