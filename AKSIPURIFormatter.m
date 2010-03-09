//
//  AKSIPURIFormatter.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AKSIPURIFormatter.h"

#import "AKNSString+Scanning.h"
#import "AKSIPURI.h"
#import "AKTelephoneNumberFormatter.h"


@implementation AKSIPURIFormatter

@synthesize formatsTelephoneNumbers = formatsTelephoneNumbers_;
@synthesize telephoneNumberFormatterSplitsLastFourDigits = telephoneNumberFormatterSplitsLastFourDigits_;

- (NSString *)stringForObjectValue:(id)anObject {
  if (![anObject isKindOfClass:[AKSIPURI class]])
    return nil;
  
  NSString *returnValue = nil;
  
  if ([[anObject displayName] length] > 0) {
    returnValue = [anObject displayName];
    
  } else if ([[anObject user] length] > 0) {
    if ([[anObject user] ak_isTelephoneNumber]) {
      if ([self formatsTelephoneNumbers]) {
        AKTelephoneNumberFormatter *telephoneNumberFormatter
          = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
        
        [telephoneNumberFormatter setSplitsLastFourDigits:
         [self telephoneNumberFormatterSplitsLastFourDigits]];
        
        returnValue = [telephoneNumberFormatter stringForObjectValue:
                       [anObject user]];
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

- (BOOL)getObjectValue:(id *)anObject
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  
  BOOL returnValue = NO;
  AKSIPURI *theURI;
  NSString *name, *destination, *user, *host;
  NSRange delimiterRange, atSignRange;
  
  theURI = [AKSIPURI SIPURIWithString:string];
  
  if (theURI == nil) {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s\\\\(.+\\\\)'"]
                       evaluateWithObject:string]) {
      // The string is in format |Destination (Display Name)|.
      
      delimiterRange = [string rangeOfString:@" (" options:NSBackwardsSearch];
      
      destination = [string substringToIndex:delimiterRange.location];
      atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
      if (atSignRange.location == NSNotFound) {
        user = destination;
        host = nil;
      } else {
        user = [destination substringToIndex:atSignRange.location];
        host = [destination substringFromIndex:(atSignRange.location + 1)];
      }
      
      NSRange nameRange
        = NSMakeRange(delimiterRange.location + 2,
                      [string length] - (delimiterRange.location + 2) - 1);
      name = [string substringWithRange:nameRange];
      
      theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:name];
      
    } else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES '.+\\\\s<.+>'"]
                              evaluateWithObject:string]) {
      // The string is in format |Display Name <Destination>|.
      
      delimiterRange = [string rangeOfString:@" <" options:NSBackwardsSearch];
      
      NSMutableCharacterSet *trimmingCharacterSet
        = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
      [trimmingCharacterSet addCharactersInString:@"\""];
      name = [[string substringToIndex:delimiterRange.location]
              stringByTrimmingCharactersInSet:trimmingCharacterSet];
      [trimmingCharacterSet release];
      
      NSRange destinationRange
        = NSMakeRange(delimiterRange.location + 2,
                      [string length] - (delimiterRange.location + 2) - 1);
      destination = [string substringWithRange:destinationRange];
      
      atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
      if (atSignRange.location == NSNotFound) {
        user = destination;
        host = nil;
      } else {
        user = [destination substringToIndex:atSignRange.location];
        host = [destination substringFromIndex:(atSignRange.location + 1)];
      }
      
      theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:name];
      
    } else {
      destination = string;
      atSignRange = [destination rangeOfString:@"@" options:NSBackwardsSearch];
      if (atSignRange.location == NSNotFound) {
        user = destination;
        host = nil;
      } else {
        user = [destination substringToIndex:atSignRange.location];
        host = [destination substringFromIndex:(atSignRange.location + 1)];
      }
      
      theURI = [AKSIPURI SIPURIWithUser:user host:host displayName:nil];
    }
  }
  
  if (theURI != nil) {
    returnValue = YES;
    if (anObject != NULL) {
      *anObject = theURI;
    }
  } else {
    if (error != NULL) {
      *error = [NSString stringWithFormat:@"Couldn't convert \"%@\" to SIP URI",
                string];
    }
  }
  
  return returnValue;
}

- (AKSIPURI *)SIPURIFromString:(NSString *)SIPURIString {
  AKSIPURI *uri;
  NSString *error;
  
  BOOL converted
    = [self getObjectValue:&uri forString:SIPURIString errorDescription:&error];
  
  if (converted) {
    return uri;
  } else {
    NSLog(@"%@", error);
    return nil;
  }
}

@end
