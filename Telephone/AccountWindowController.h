//
//  AccountWindowController.h
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

@import Cocoa;

@class AccountViewController;
@protocol AccountWindowControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AccountWindowControllerAccountState) {
    AccountWindowControllerAccountStateOffline,
    AccountWindowControllerAccountStateAvailable,
    AccountWindowControllerAccountStateUnavailable
};

@interface AccountWindowController : NSWindowController

@property(nonatomic, readonly) BOOL allowsCallDestinationInput;

- (instancetype)initWithAccountDescription:(NSString *)accountDescription
                                SIPAddress:(NSString *)SIPAddress
                     accountViewController:(AccountViewController *)accountViewController
                                  delegate:(id<AccountWindowControllerDelegate>)delegate;

- (void)showAvailableState;
- (void)showUnavailableState;
- (void)showOfflineState;
- (void)showConnectingState;

- (void)makeCallToDestination:(NSString *)destination;

- (void)showAlert:(NSAlert *)alert;
- (void)beginSheet:(NSWindow *)sheet;

- (void)showWindowWithoutMakingKey;
- (void)hideWindow;
- (BOOL)isWindowKey;
- (void)orderWindow:(NSWindowOrderingMode)place relativeTo:(NSInteger)otherWindow;
- (NSInteger)windowNumber;

@end

@protocol AccountWindowControllerDelegate

- (void)accountWindowController:(AccountWindowController *)controller didChangeAccountState:(AccountWindowControllerAccountState)state;

@end

NS_ASSUME_NONNULL_END
