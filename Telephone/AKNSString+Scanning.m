//
//  AKNSString+Scanning.m
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

#import "AKNSString+Scanning.h"


@implementation NSString (AKStringScanningAdditions)

- (BOOL)ak_isTelephoneNumber {
    NSPredicate *telephoneNumberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\+?\\\\d+'"];
    
    return ([telephoneNumberPredicate evaluateWithObject:self]) ? YES : NO;
}

- (BOOL)ak_hasLetters {
    NSPredicate *containsLettersPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*[a-zA-Z].*'"];
    
    return ([containsLettersPredicate evaluateWithObject:self]) ? YES : NO;
}

- (BOOL)ak_isIPAddress {
    NSPredicate *IPAddressPredicate
        = [NSPredicate predicateWithFormat:@"SELF MATCHES "
           "'\\\\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
           "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
           "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
           "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\b'"];
    
    return ([IPAddressPredicate evaluateWithObject:self]) ? YES : NO;
}

@end
