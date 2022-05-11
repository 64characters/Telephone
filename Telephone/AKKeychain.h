//
//  AKKeychain.h
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

NS_ASSUME_NONNULL_BEGIN

// A Keychain Services wrapper.
@interface AKKeychain : NSObject

// Returns password for the first Keychain item with a specified service and account.
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account;

// Adds an item to the Keychain with a specified service, account, and password. If the same item already
// exists, its password will be replaced with the new one.
+ (BOOL)addItemWithService:(NSString *)service account:(NSString *)account password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
