//
//  AKABRecord+Querying.m
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

#import "AKABRecord+Querying.h"

@implementation ABRecord (AKRecordQueryingAdditions)

- (NSString *)ak_fullNameWithNameOrdering:(NSInteger)nameOrdering {
    NSInteger personFlags = [[self valueForProperty:kABPersonFlags] integerValue];
    BOOL isPerson = (personFlags & kABShowAsMask) == kABShowAsPerson;
    BOOL isCompany = (personFlags & kABShowAsMask) == kABShowAsCompany;
    
    NSString *result = @"";
    if (isPerson) {
        NSString *firstName = [self valueForProperty:kABFirstNameProperty];
        NSString *lastName = [self valueForProperty:kABLastNameProperty];
        if ([firstName length] > 0 && [lastName length] > 0) {
            if (nameOrdering == kABFirstNameFirst) {
                result = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            } else {
                result = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
            }
        } else if ([firstName length] > 0) {
            result = firstName;
        } else if ([lastName length] > 0) {
            result = lastName;
        }
        
    } else if (isCompany) {
        NSString *company = [self valueForProperty:kABOrganizationProperty];
        if ([company length] > 0) {
            result = company;
        }
    }
    
    return result;
}

- (NSString *)ak_fullName {
    return [self ak_fullNameWithNameOrdering:[ABAddressBook sharedAddressBook].defaultNameOrdering];
}

@end
