//
//  AKABAddressBook+Localizing.m
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
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

#import "AKABAddressBook+Localizing.h"

#import <AddressBook/ABAddressBookC.h>


@implementation ABAddressBook (AKAddressBookLocalizingAdditions)

- (NSString *)ak_localizedLabel:(NSString *)label {
    NSString *theString;
    
    if ([label isEqualToString:kABPhoneWorkLabel]) {
        theString = NSLocalizedStringFromTable(@"work", @"AddressBookLabels", @"Work phone number.");
    } else if ([label isEqualToString:kABPhoneHomeLabel]) {
        theString = NSLocalizedStringFromTable(@"home", @"AddressBookLabels", @"Home phone number.");
    } else if ([label isEqualToString:kABPhoneMobileLabel]) {
        theString = NSLocalizedStringFromTable(@"mobile", @"AddressBookLabels", @"Mobile phone number.");
    } else if ([label isEqualToString:kABPhoneMainLabel]) {
        theString = NSLocalizedStringFromTable(@"main", @"AddressBookLabels", @"Main phone number.");
    } else if ([label isEqualToString:kABPhoneHomeFAXLabel]) {
        theString = NSLocalizedStringFromTable(@"home fax", @"AddressBookLabels", @"Home FAX number.");
    } else if ([label isEqualToString:kABPhoneWorkFAXLabel]) {
        theString = NSLocalizedStringFromTable(@"work fax", @"AddressBookLabels", @"Work FAX number.");
    } else if ([label isEqualToString:kABPhonePagerLabel]) {
        theString = NSLocalizedStringFromTable(@"pager", @"AddressBookLabels", @"Pager number.");
    } else if ([label isEqualToString:kABOtherLabel]) {
        theString = NSLocalizedStringFromTable(@"other", @"AddressBookLabels", @"Other number.");
    } else if ([label isEqualToString:@"sip"]) {
        theString = NSLocalizedStringFromTable(@"sip", @"AddressBookLabels", @"SIP address.");
    } else {
        CFStringRef localizedLabel = ABCopyLocalizedPropertyOrLabel((CFStringRef)label);
        theString = [(NSString *)localizedLabel autorelease];
    }
    
    return theString;
}

@end
