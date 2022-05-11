//
//  AKNSString+Escaping.h
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

#import <Foundation/Foundation.h>


// A category for escaping strings.
@interface NSString (AKStringEscapingAdditions)

// Returns a new string created from the receiver where every occurrence of the first character from a given string is
// escaped with a backslash.
- (NSString *)ak_escapeFirstCharacterFromString:(NSString *)string;

// Returns a new string created from the receiver where every quote character, i.e. |"|, is escaped with a backslash.
- (NSString *)ak_escapeQuotes;

// Returns a new string created from the receiver where every parenthesis, i.e. |(| or |)|, is escaped with a backslash.
- (NSString *)ak_escapeParentheses;

@end
