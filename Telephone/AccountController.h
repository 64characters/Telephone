//
//  AccountController.h
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

#import "AKSIPAccount.h"

#import "CallController.h"

// Address Book label for SIP address in the email field.
extern NSString * const kEmailSIPLabel;

@class AKSIPURI, AKNetworkReachability;
@class AsyncCallHistoryPurchaseCheckUseCaseFactory, AsyncCallHistoryViewEventTargetFactory;
@class CallTransferController, SanitizedCallDestination, StoreWindowPresenter, WorkspaceSleepStatus;
@protocol RingtonePlaybackUseCase;

@interface AccountController : NSObject <AKSIPAccountDelegate, CallControllerDelegate>

@property(nonatomic, readonly) AKSIPAccount *account;
@property(nonatomic, readonly) id<RingtonePlaybackUseCase> ringtonePlayback;

@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, readonly, getter=isAccountRegistered) BOOL accountRegistered;
@property(nonatomic, readonly) NSMutableArray *callControllers;
@property(nonatomic, readonly) NSString *accountDescription;
@property(nonatomic) BOOL attemptingToRegisterAccount;
@property(nonatomic) BOOL attemptingToUnregisterAccount;
@property(nonatomic) BOOL shouldPresentRegistrationError;
@property(nonatomic, getter=isAccountUnavailable) BOOL accountUnavailable;
@property(nonatomic, readonly) AKNetworkReachability *registrarReachability;
@property(nonatomic) BOOL substitutesPlusCharacter;
@property(nonatomic, copy) NSString *plusCharacterSubstitution;
@property(nonatomic) BOOL callsShouldDisplayAccountInfo;
@property(nonatomic, readonly) BOOL canMakeCalls;


- (instancetype)initWithSIPAccount:(AKSIPAccount *)account
                accountDescription:(NSString *)accountDescription
                         userAgent:(AKSIPUserAgent *)userAgent
                  ringtonePlayback:(id<RingtonePlaybackUseCase>)ringtonePlayback
                       sleepStatus:(WorkspaceSleepStatus *)sleepStatus
 callHistoryViewEventTargetFactory:(AsyncCallHistoryViewEventTargetFactory *)callHistoryViewEventTargetFactory
       purchaseCheckUseCaseFactory:(AsyncCallHistoryPurchaseCheckUseCaseFactory *)purchaseCheckUseCaseFactory
              storeWindowPresenter:(StoreWindowPresenter *)storeWindowPresenter;

- (void)registerAccount;
- (void)unregisterAccount;

- (void)removeAccountFromUserAgent;

// Makes a call to a given destination URI with a given phone label.
// When |callTransferController| is not nil, no new window will be created, existing |callTransferController| will be
// used instead. Host part of the |destinationURI| can be empty, in which case host part from the account's
// |uri| will be taken.
- (void)makeCallToURI:(AKSIPURI *)destinationURI
        phoneLabel:(NSString *)phoneLabel
        callTransferController:(CallTransferController *)callTransferController;

- (void)makeCallToURI:(AKSIPURI *)destinationURI phoneLabel:(NSString *)phoneLabel;

- (void)makeCallToDestinationRegisteringAccountIfNeeded:(SanitizedCallDestination *)destination;

- (void)showWindow;
- (void)showWindowWithoutMakingKey;
- (void)hideWindow;
- (BOOL)isWindowKey;
- (void)orderWindow:(NSWindowOrderingMode)place relativeTo:(NSInteger)otherWindow;
- (NSInteger)windowNumber;

- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error;

- (void)showUnavailableState;
- (void)showConnectingState;

@end
