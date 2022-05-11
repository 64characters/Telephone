//
//  AKSIPAccountDelegate.h
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

@class AKSIPAccount, AKSIPCall;

/// Protocol that must be adopted by objects that want to act as deleages of AKSIPAccount objects.
@protocol AKSIPAccountDelegate <NSObject>

/// Called when account registration changes.
- (void)SIPAccountRegistrationDidChange:(AKSIPAccount *)account;

/// Called when account is about to be removed.
- (void)SIPAccountWillRemove:(AKSIPAccount *)account;

/// Sent when AKSIPAccount receives an incoming call.
- (void)SIPAccount:(AKSIPAccount *)account didReceiveCall:(AKSIPCall *)aCall;

@end
