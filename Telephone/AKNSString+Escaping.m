//
//  AKNSString+Escaping.m
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

#import "AKNSString+Escaping.h"


@implementation NSString (AKStringEscapingAdditions)

- (NSString *)ak_escapeFirstCharacterFromString:(NSString *)string {
    NSMutableString *newString = [NSMutableString stringWithString:self];
    NSString *escapeCharacterString = [string substringWithRange:NSMakeRange(0, 1)];
    NSRange escapeCharacterRange = [newString rangeOfString:escapeCharacterString];
    while (escapeCharacterRange.location != NSNotFound) {
        [newString insertString:@"\\" atIndex:escapeCharacterRange.location];
        NSRange searchRange;
        searchRange.location = escapeCharacterRange.location + 2;
        searchRange.length = [newString length] - searchRange.location;
        escapeCharacterRange = [newString rangeOfString:escapeCharacterString options:0 range:searchRange];
    }
    
    return [newString copy];
}

- (NSString *)ak_escapeQuotes {
    return [self ak_escapeFirstCharacterFromString:@"\""];
}

- (NSString *)ak_escapeParentheses {
    NSString *returnString = [self ak_escapeFirstCharacterFromString:@")"];
    
    return [returnString ak_escapeFirstCharacterFromString:@"("];
}

@end
