//
//  AKKeychain.h
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

// Returns password for the first Keychain item with a specified service name and account name.
+ (NSString *)passwordForServiceName:(NSString *)serviceName accountName:(NSString *)accountName;

// Adds an item to the Keychain with a specified service name, account name, and password. If the same item already
// exists, its password will be replaced with the new one.
+ (BOOL)addItemWithServiceName:(NSString *)serviceName accountName:(NSString *)accountName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
