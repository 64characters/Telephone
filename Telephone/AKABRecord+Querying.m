//
//  AKABRecord+Querying.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

- (NSString *)ak_fullName {
    NSString *firstName = [self valueForProperty:kABFirstNameProperty];
    NSString *lastName = [self valueForProperty:kABLastNameProperty];
    NSString *company = [self valueForProperty:kABOrganizationProperty];
    NSInteger personFlags = [[self valueForProperty:kABPersonFlags] integerValue];
    BOOL isPerson = (personFlags & kABShowAsMask) == kABShowAsPerson;
    BOOL isCompany = (personFlags & kABShowAsMask) == kABShowAsCompany;
    
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    NSString *theString = nil;
    if (isPerson) {
        if ([firstName length] > 0 && [lastName length] > 0) {
            if ([AB defaultNameOrdering] == kABFirstNameFirst) {
                theString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            } else {
                theString = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
            }
        } else if ([firstName length] > 0) {
            theString = firstName;
        } else if ([lastName length] > 0) {
            theString = lastName;
        }
        
    } else if (isCompany) {
        if ([company length] > 0) {
            theString = company;
        }
    }
    
    return theString;
}

@end
