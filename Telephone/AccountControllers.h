//
//  AccountControllers.h
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

@import Foundation;

@class AccountController, CallController;

NS_ASSUME_NONNULL_BEGIN

@interface AccountControllers : NSObject

@property(nonatomic, readonly) NSArray<AccountController *> *all;
@property(nonatomic, readonly) NSArray<AccountController *> *enabled;

- (AccountController *)objectAtIndexedSubscript:(NSInteger)index;
- (void)setObject:(AccountController *)object atIndexedSubscript:(NSInteger)index;

- (NSInteger)indexOfController:(AccountController *)controller;
- (void)addController:(AccountController *)controller;
- (void)removeControllerAtIndex:(NSInteger)index;
- (void)insertController:(AccountController *)controller atIndex:(NSInteger)index;

- (nullable CallController *)callControllerByIdentifier:(NSString *)identifier;
- (BOOL)haveActiveCallControllers;
- (NSInteger)unhandledIncomingCallsCount;
- (void)showIncomingCallWindows;

- (void)updateCallsShouldDisplayAccountInfo;

- (void)hangUpCallsAndRemoveAccountsFromUserAgent;

- (void)registerAllAccounts;
- (void)registerReachableAccounts;
- (void)registerAllAccountsWhereManualRegistrationRequired;
- (void)registerAccountIfManualRegistrationRequired:(AccountController *)controller;
- (void)unregisterAllAccounts;

@end

NS_ASSUME_NONNULL_END
