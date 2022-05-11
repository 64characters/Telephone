//
//  AccountControllers.m
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

#import "AccountControllers.h"

#import "AKNetworkReachability.h"
#import "AKSIPUserAgent.h"

#import "AccountController.h"

#import "Telephone-Swift.h"

@import UseCases;

@interface AccountControllers ()

@property(nonatomic, readonly) NSMutableArray<AccountController *> *controllers;

@end

@implementation AccountControllers

- (instancetype)init {
    if ((self = [super init])) {
        _controllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<AccountController *> *)all {
    return [self.controllers copy];
}

- (NSArray<AccountController *> *)enabled {
    return [self.controllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled == YES"]];
}

- (AccountController *)objectAtIndexedSubscript:(NSInteger)index {
    return self.controllers[index];
}

- (void)setObject:(AccountController *)object atIndexedSubscript:(NSInteger)index {
    self.controllers[index] = object;
}

- (NSInteger)indexOfController:(AccountController *)controller {
    return [self.controllers indexOfObject:controller];
}

- (void)addController:(AccountController *)controller {
    [self.controllers addObject:controller];
}

- (void)removeControllerAtIndex:(NSInteger)index {
    [self.controllers removeObjectAtIndex:index];
}

- (void)insertController:(AccountController *)controller atIndex:(NSInteger)index {
    [self.controllers insertObject:controller atIndex:index];
}

- (nullable CallController *)callControllerByIdentifier:(NSString *)identifier {
    for (AccountController *accountController in self.enabled) {
        for (CallController *callController in accountController.callControllers) {
            if ([callController.identifier isEqualToString:identifier]) {
                return callController;
            }
        }
    }
    return nil;
}

- (BOOL)haveActiveCallControllers {
    for (AccountController *accountController in self.enabled) {
        for (CallController *callController in accountController.callControllers) {
            if (callController.isCallActive) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSInteger)unhandledIncomingCallsCount {
    NSInteger count = 0;
    for (AccountController *accountController in self.enabled) {
        for (CallController *callController in accountController.callControllers) {
            if (callController.call.isIncoming && callController.isCallUnhandled) {
                count++;
            }
        }
    }
    return count;
}

- (void)showIncomingCallWindows {
    for (AccountController *accountController in self.enabled) {
        for (CallController *callController in accountController.callControllers) {
            if (callController.call.identifier != kAKSIPUserAgentInvalidIdentifier &&
                callController.call.state == kAKSIPCallIncomingState) {
                [callController showWindow:nil];
            }
        }
    }
}

- (void)updateCallsShouldDisplayAccountInfo {
    BOOL shouldDisplay = self.enabled.count > 1;
    for (AccountController *controller in self.controllers) {
        controller.callsShouldDisplayAccountInfo = shouldDisplay;
    }
}

- (void)hangUpCallsAndRemoveAccountsFromUserAgent {
    for (AccountController *accountController in self.enabled) {
        for (CallController *callController in accountController.callControllers) {
            [callController hangUpCall];
        }
        [accountController removeAccountFromUserAgent];
    }
}

- (void)registerAllAccounts {
    for (AccountController *controller in self.enabled) {
        [controller registerAccount];
    }
}

- (void)registerReachableAccounts {
    for (AccountController *controller in self.enabled) {
        if ([controller.registrarReachability isReachable]) {
            [controller registerAccount];
        }
    }
}

- (void)registerAllAccountsWhereManualRegistrationRequired {
    for (AccountController *controller in self.enabled) {
        [self registerAccountIfManualRegistrationRequired:controller];
    }
}

- (void)registerAccountIfManualRegistrationRequired:(AccountController *)controller {
    if (controller.account.registrar.host.ak_isIPAddress && controller.registrarReachability.isReachable) {
        [controller registerAccount];
    }
}

- (void)unregisterAllAccounts {
    for (AccountController *controller in self.enabled) {
        if (controller.isAccountRegistered) {
            [controller unregisterAccount];
        }
    }
}

@end
