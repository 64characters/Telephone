//
//  AKSIPURIFormatter.m
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

#import "AKSIPURIFormatter.h"

@import UseCases;

#import "AKSIPURI.h"
#import "AKTelephoneNumberFormatter.h"

@implementation AKSIPURIFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[AKSIPURI class]]) {
        return nil;
    }
    
    NSString *returnValue = nil;
    
    if ([[anObject displayName] length] > 0) {
        returnValue = [anObject displayName];
        
    } else if ([[anObject user] length] > 0) {
        if ([[anObject user] ak_isTelephoneNumber]) {
            if ([self formatsTelephoneNumbers]) {
                AKTelephoneNumberFormatter *telephoneNumberFormatter
                    = [[AKTelephoneNumberFormatter alloc] init];
                
                [telephoneNumberFormatter setSplitsLastFourDigits:[self telephoneNumberFormatterSplitsLastFourDigits]];
                
                returnValue = [telephoneNumberFormatter stringForObjectValue:[anObject user]];
            } else {
                returnValue = [anObject user];
            }
        } else {
            returnValue = [anObject SIPAddress];
        }
    } else {
        returnValue = [anObject host];
    }
    
    return returnValue;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    AKSIPURI *theURI = [AKSIPURI SIPURIWithString:string];
    
    if (theURI == nil) {
        NSString *name, *destination, *user, *host;
        if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s\\\\(.+\\\\)'"] evaluateWithObject:string]) {
            // The string is in format |Destination (Display Name)|.
            
            NSRange delimiterRange = [string rangeOfString:@" (" options:NSBackwardsSearch];
            
            destination = [string substringToIndex:delimiterRange.location];
            NSRange atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
            if (atSignRange.location == NSNotFound) {
                user = destination;
                host = @"";
            } else {
                user = [destination substringToIndex:atSignRange.location];
                host = [destination substringFromIndex:(atSignRange.location + 1)];
            }
            
            NSRange nameRange = NSMakeRange(delimiterRange.location + 2,
                                            [string length] - (delimiterRange.location + 2) - 1);
            name = [string substringWithRange:nameRange];
            
            theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:name];
            
        } else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s<.+>'"] evaluateWithObject:string]) {
            // The string is in format |Display Name <Destination>|.
            
            NSRange delimiterRange = [string rangeOfString:@" <" options:NSBackwardsSearch];
            
            NSMutableCharacterSet *trimmingCharacterSet = [NSMutableCharacterSet whitespaceCharacterSet];
            [trimmingCharacterSet addCharactersInString:@"\""];
            name = [[string substringToIndex:delimiterRange.location]
                    stringByTrimmingCharactersInSet:trimmingCharacterSet];
            
            NSRange destinationRange = NSMakeRange(delimiterRange.location + 2,
                                                   [string length] - (delimiterRange.location + 2) - 1);
            destination = [string substringWithRange:destinationRange];
            
            NSRange atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
            if (atSignRange.location == NSNotFound) {
                user = destination;
                host = @"";
            } else {
                user = [destination substringToIndex:atSignRange.location];
                host = [destination substringFromIndex:(atSignRange.location + 1)];
            }
            
            theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:name];
            
        } else {
            destination = string;
            NSRange atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
            if (atSignRange.location == NSNotFound) {
                user = destination;
                host = @"";
            } else {
                user = [destination substringToIndex:atSignRange.location];
                host = [destination substringFromIndex:(atSignRange.location + 1)];
            }
            
            theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:@""];
        }
    }

    assert(theURI);
    
    if (anObject != NULL) {
        *anObject = theURI;
    }

    return YES;
}

- (AKSIPURI *)SIPURIFromString:(NSString *)SIPURIString {
    AKSIPURI *uri;
    NSString *error;
    
    BOOL converted = [self getObjectValue:&uri forString:SIPURIString errorDescription:&error];
    
    if (converted) {
        return uri;
    } else {
        NSLog(@"%@", error);
        return nil;
    }
}

@end
