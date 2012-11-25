//
//  AKAddressBookSIPAddressPlugIn.h
//  AKAddressBookSIPAddressPlugIn
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

#import <AddressBook/AddressBook.h>


// Object: @"AddressBook".
// Keys: @"AKSIPAddress", @"AKFullName".
NSString * const AKAddressBookDidDialSIPAddressNotification = @"AKAddressBookDidDialSIPAddress";

// An address book plug-in to dial SIP addresses with Telephone. SIP addresses are emails with a custom label |sip|.
@interface AKAddressBookSIPAddressPlugIn : NSObject {
    NSString *lastSIPAddress_;
    NSString *lastFullName_;
    BOOL shouldDial_;
}

// SIP address that has been dialed last. While Telephone is being launched, several phone numbers can be dialed. We
// handle only the last one.
@property (nonatomic, copy) NSString *lastSIPAddress;

// Full name of the contact that has been dialed last. While Telephone is being launched, several phone numbers can be
// dialed. We handle only the last one.
@property (nonatomic, copy) NSString *lastFullName;

// A Boolean value that determines whether a call should be made after Telephone starts up.
@property (nonatomic, assign) BOOL shouldDial;

- (NSString *)actionProperty;

- (NSString *)titleForPerson:(ABPerson *)person identifier:(NSString *)identifier;

- (void)performActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;

- (BOOL)shouldEnableActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;

@end
