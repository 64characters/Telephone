//
//  PreferencesControllerNotifications.h
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

// Sent when preferences controller removes an accont.
// |userInfo| dictionary keys: kAccountIndex, AKSIPAccountKeys.uuid.
extern NSString * const AKPreferencesControllerDidRemoveAccountNotification;

// Sent when preferences controller enables or disables an account.
// |userInfo| dictionary key: kAccountIndex.
extern NSString * const AKPreferencesControllerDidChangeAccountEnabledNotification;

// Sent when preferences controller changes account order.
// |userInfo| dictionary keys: kSourceIndex, kDestinationIndex.
extern NSString * const AKPreferencesControllerDidSwapAccountsNotification;

// Sent when preferences controller changes network settings.
extern NSString * const AKPreferencesControllerDidChangeNetworkSettingsNotification;

extern NSString * const kAccountIndex;
extern NSString * const kSourceIndex;
extern NSString * const kDestinationIndex;
