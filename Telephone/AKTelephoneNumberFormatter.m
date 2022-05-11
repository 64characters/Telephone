//
//  AKTelephoneNumberFormatter.m
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

#import "AKTelephoneNumberFormatter.h"


@implementation AKTelephoneNumberFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *theString;
    NSUInteger length = [anObject length];
    
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\d{6,15}'"] evaluateWithObject:anObject]) {
        switch (length) {
            case 6:
                if ([self splitsLastFourDigits]) {  // ##-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 2)],
                                 [anObject substringWithRange:NSMakeRange(2, 2)],
                                 [anObject substringWithRange:NSMakeRange(4, 2)]];
                } else {                             // ###-###
                    theString = [NSString stringWithFormat:@"%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 3)]];
                }
                break;
                
            case 7:
                if ([self splitsLastFourDigits]) {  // ###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 2)],
                                 [anObject substringWithRange:NSMakeRange(5, 2)]];
                } else {                            // ###-####
                    theString = [NSString stringWithFormat:@"%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 4)]];
                }
                break;
                
            case 8:
                if ([self splitsLastFourDigits]) {  // #-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 1)],
                                 [anObject substringWithRange:NSMakeRange(1, 3)],
                                 [anObject substringWithRange:NSMakeRange(4, 2)],
                                 [anObject substringWithRange:NSMakeRange(6, 2)]];
                } else {                            // #-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 1)],
                                 [anObject substringWithRange:NSMakeRange(1, 3)],
                                 [anObject substringWithRange:NSMakeRange(4, 4)]];
                }
                break;
                
            case 9:
                if ([self splitsLastFourDigits]) {  // ##-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 2)],
                                 [anObject substringWithRange:NSMakeRange(2, 3)],
                                 [anObject substringWithRange:NSMakeRange(5, 2)],
                                 [anObject substringWithRange:NSMakeRange(7, 2)]];
                } else {                            // ##-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 2)],
                                 [anObject substringWithRange:NSMakeRange(2, 3)],
                                 [anObject substringWithRange:NSMakeRange(5, 4)]];
                }
                break;
                
            case 10:
                if ([self splitsLastFourDigits]) {  // ###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 3)],
                                 [anObject substringWithRange:NSMakeRange(6, 2)],
                                 [anObject substringWithRange:NSMakeRange(8, 2)]];
                } else {                            // ###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 3)],
                                 [anObject substringWithRange:NSMakeRange(6, 4)]];
                }
                break;
                
            case 11:
                if ([self splitsLastFourDigits]) {  // #-###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 1)],
                                 [anObject substringWithRange:NSMakeRange(1, 3)],
                                 [anObject substringWithRange:NSMakeRange(4, 3)],
                                 [anObject substringWithRange:NSMakeRange(7, 2)],
                                 [anObject substringWithRange:NSMakeRange(9, 2)]];
                } else {                            // #-###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 1)],
                                 [anObject substringWithRange:NSMakeRange(1, 3)],
                                 [anObject substringWithRange:NSMakeRange(4, 3)],
                                 [anObject substringWithRange:NSMakeRange(7, 4)]];
                }
                break;
                
            case 12:
                if ([self splitsLastFourDigits]) {  // ##-###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 2)],
                                 [anObject substringWithRange:NSMakeRange(2, 3)],
                                 [anObject substringWithRange:NSMakeRange(5, 3)],
                                 [anObject substringWithRange:NSMakeRange(8, 2)],
                                 [anObject substringWithRange:NSMakeRange(10, 2)]];
                } else {                            // ##-###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 2)],
                                 [anObject substringWithRange:NSMakeRange(2, 3)],
                                 [anObject substringWithRange:NSMakeRange(5, 3)],
                                 [anObject substringWithRange:NSMakeRange(8, 4)]];
                }
                break;
                
            case 13:
                if ([self splitsLastFourDigits]) {  // ###-###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 3)],
                                 [anObject substringWithRange:NSMakeRange(6, 3)],
                                 [anObject substringWithRange:NSMakeRange(9, 2)],
                                 [anObject substringWithRange:NSMakeRange(11, 2)]];
                } else {                            // ###-###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 3)],
                                 [anObject substringWithRange:NSMakeRange(3, 3)],
                                 [anObject substringWithRange:NSMakeRange(6, 3)],
                                 [anObject substringWithRange:NSMakeRange(9, 4)]];
                }
                break;
                
            case 14:
                if ([self splitsLastFourDigits]) {  // ####-###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 4)],
                                 [anObject substringWithRange:NSMakeRange(4, 3)],
                                 [anObject substringWithRange:NSMakeRange(7, 3)],
                                 [anObject substringWithRange:NSMakeRange(10, 2)],
                                 [anObject substringWithRange:NSMakeRange(12, 2)]];
                } else {                            // ####-###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 4)],
                                 [anObject substringWithRange:NSMakeRange(4, 3)],
                                 [anObject substringWithRange:NSMakeRange(7, 3)],
                                 [anObject substringWithRange:NSMakeRange(10, 4)]];
                }
                break;
                
            case 15:
                if ([self splitsLastFourDigits]) {  // #####-###-###-##-##
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 5)],
                                 [anObject substringWithRange:NSMakeRange(5, 3)],
                                 [anObject substringWithRange:NSMakeRange(8, 3)],
                                 [anObject substringWithRange:NSMakeRange(11, 2)],
                                 [anObject substringWithRange:NSMakeRange(13, 2)]];
                } else {                            // #####-###-###-####
                    theString = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                 [anObject substringWithRange:NSMakeRange(0, 5)],
                                 [anObject substringWithRange:NSMakeRange(5, 3)],
                                 [anObject substringWithRange:NSMakeRange(8, 3)],
                                 [anObject substringWithRange:NSMakeRange(11, 4)]];
                }
                break;
                
            default:
                theString = anObject;
                break;
        }
    } else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\+(1|7)\\\\d{10}'"] evaluateWithObject:anObject]) {
        if ([self splitsLastFourDigits]) {        // +# (###) ###-##-##
            theString = [NSString stringWithFormat:@"%@ (%@) %@-%@-%@",
                         [anObject substringWithRange:NSMakeRange(0, 2)],
                         [anObject substringWithRange:NSMakeRange(2, 3)],
                         [anObject substringWithRange:NSMakeRange(5, 3)],
                         [anObject substringWithRange:NSMakeRange(8, 2)],
                         [anObject substringWithRange:NSMakeRange(10, 2)]];
        } else {                                  // +# (###) ###-####
            theString = [NSString stringWithFormat:@"%@ (%@) %@-%@",
                         [anObject substringWithRange:NSMakeRange(0, 2)],
                         [anObject substringWithRange:NSMakeRange(2, 3)],
                         [anObject substringWithRange:NSMakeRange(5, 3)],
                         [anObject substringWithRange:NSMakeRange(8, 4)]];
        }
    } else {
        theString = anObject;
    }
    
    return theString;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    BOOL returnValue = NO;
    
    NSMutableCharacterSet *phoneNumberCharacterSet
        = [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSMutableString *telephoneNumber = [[NSMutableString alloc] init];
    
    if ([string hasPrefix:@"+"]) {
        [telephoneNumber appendString:@"+"];
        [scanner setScanLocation:1];
    } else {
        // If the number is not in the international format, allow asterisk and
        // number sign.
        [phoneNumberCharacterSet addCharactersInString:@"*#"];
    }
    
    NSString *aString;
    while (![scanner isAtEnd]) {
        [scanner scanUpToCharactersFromSet:phoneNumberCharacterSet intoString:NULL];
        BOOL scanned = [scanner scanCharactersFromSet:phoneNumberCharacterSet intoString:&aString];
        if (scanned) {
            [telephoneNumber appendString:aString];
        }
    }
    
    if ([telephoneNumber length] > 0) {
        returnValue = YES;
        if (anObject != NULL) {
            *anObject = [telephoneNumber copy];
        }
    } else if (error != NULL) {
        *error = [NSString stringWithFormat:@"Couldn't convert \"%@\" to telephone number", string];
    }
    
    return returnValue;
}

- (NSString *)telephoneNumberFromString:(NSString *)string {
    NSString *telephoneNumber, *error;
    BOOL converted = [self getObjectValue:&telephoneNumber forString:string errorDescription:&error];
    if (converted) {
        return telephoneNumber;
    } else {
        NSLog(@"%@", error);
        return nil;
    }
}

@end
