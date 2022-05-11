//
//  AKAddressBookPhonePlugIn.h
//  AKAddressBookPhonePlugIn
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

#import <AddressBook/AddressBook.h>


// Object: @"AddressBook".
// Keys: @"AKPhoneNumber", @"AKFullName".
NSString * const AKAddressBookDidDialPhoneNumberNotification = @"AKAddressBookDidDialPhoneNumber";

// An Address Book plug-in to dial phone numbers with Telephone.
@interface AKAddressBookPhonePlugIn : NSObject

// Phone number that has been dialed last. While Telephone is being launched, several phone numbers can be dialed. We
// handle only the last one.
@property(nonatomic, copy) NSString *lastPhoneNumber;

// Full name of the contact that has been dialed last. While Telephone is being launched, several phone numbers can be
// dialed. We handle only the last one.
@property(nonatomic, copy) NSString *lastFullName;

// A Boolean value that determines whether a call should be made after Telephone starts up.
@property(nonatomic, assign) BOOL shouldDial;

- (NSString *)actionProperty;

- (NSString *)titleForPerson:(ABPerson *)person identifier:(NSString *)identifier;

- (void)performActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;

- (BOOL)shouldEnableActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;

@end
