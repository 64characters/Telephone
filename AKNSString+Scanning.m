//
//  AKNSString+Scanning.m
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

#import "AKNSString+Scanning.h"


@implementation NSString (AKStringScanningAdditions)

@dynamic ak_isTelephoneNumber;
@dynamic ak_hasLetters;
@dynamic ak_isIPAddress;

- (BOOL)ak_isTelephoneNumber {
  NSPredicate *telephoneNumberPredicate
    = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\+?\\\\d+'"];
  
  return ([telephoneNumberPredicate evaluateWithObject:self]) ? YES : NO;
}

- (BOOL)ak_hasLetters {
  NSPredicate *containsLettersPredicate
    = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*[a-zA-Z].*'"];
  
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
