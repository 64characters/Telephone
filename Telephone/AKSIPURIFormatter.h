//
//  AKSIPURIFormatter.h
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

#import <Cocoa/Cocoa.h>

@class AKSIPURI;

// Instances of AKSIPURIFormatter create string representations of AKSIPURI, and convert textual representations of SIP
// URIs into AKSIPURI objects.
@interface AKSIPURIFormatter : NSFormatter

// A Boolean value indicating whether the receiver formats telephone numbers.
@property(nonatomic, assign) BOOL formatsTelephoneNumbers;

// A Boolean value indicating whether the receiver's telephone number formatter splits last four digits.
@property(nonatomic, assign) BOOL telephoneNumberFormatterSplitsLastFourDigits;

// Wrapper for |getObjectValue:forString:errorDescription:|. Returns AKSIPURI object converted from a given string.
- (AKSIPURI *)SIPURIFromString:(NSString *)SIPURIString;

@end
