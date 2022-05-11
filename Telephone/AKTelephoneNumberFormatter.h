//
//  AKTelephoneNumberFormatter.h
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


// Instances of AKTelephoneNumberFormatter create formatted telephone numbers from strings of contiguous digits, and
// convert strings with non-contiguous digits to strings that consist of contiguous digits only.
@interface AKTelephoneNumberFormatter : NSFormatter

// A Boolean value that determines whether the receiver should separate last two digits when formatting a telephone
// number. When YES, |+11234567890| becomes |+1 (123) 456-78-90|.
@property(nonatomic, assign) BOOL splitsLastFourDigits;

// Wrapper for |getObjectValue:forString:errorDescription:|. Scans |string| for numbers and returns them as a contiguous
// digits string.
- (NSString *)telephoneNumberFromString:(NSString *)string;

@end
