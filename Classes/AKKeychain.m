//
//  AKKeychain.m
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

#import "AKKeychain.h"


@implementation AKKeychain

+ (NSString *)passwordForServiceName:(NSString *)serviceName accountName:(NSString *)accountName {
    void *passwordData = nil;
    UInt32 passwordLength;
    OSStatus findStatus;
    
    findStatus = SecKeychainFindGenericPassword(NULL,   // Default keychain.
                                                [serviceName length],
                                                [serviceName UTF8String],
                                                [accountName length],
                                                [accountName UTF8String],
                                                &passwordLength,
                                                &passwordData,
                                                NULL);  // Keychain item reference.
    
    if (findStatus != noErr) {
        return nil;
    }
    
    NSString *password = [[[NSString alloc] initWithBytes:passwordData
                                                   length:passwordLength
                                                 encoding:NSUTF8StringEncoding]
                          autorelease];
    
    SecKeychainItemFreeContent(NULL, passwordData);
    
    return password;
}

+ (BOOL)addItemWithServiceName:(NSString *)serviceName
                   accountName:(NSString *)accountName
                      password:(NSString *)password {
    
    SecKeychainItemRef keychainItemRef = nil;
    OSStatus addStatus, findStatus, modifyStatus;
    BOOL success = NO;
    
    // Add item to keychain.
    addStatus = SecKeychainAddGenericPassword(NULL,   // NULL for default keychain.
                                              [serviceName length],
                                              [serviceName UTF8String],
                                              [accountName length],
                                              [accountName UTF8String],
                                              [password length],
                                              [password UTF8String],
                                              NULL);  // Don't need keychain item reference.
    
    if (addStatus == noErr) {
        success = YES;
        
    } else if (addStatus == errSecDuplicateItem) {
        // Get the pointer to the duplicate item.
        findStatus = SecKeychainFindGenericPassword(NULL,               // Default keychain.
                                                    [serviceName length],
                                                    [serviceName UTF8String],
                                                    [accountName length],
                                                    [accountName UTF8String],
                                                    NULL,
                                                    NULL,
                                                    &keychainItemRef);  // Pointer to the duplicate item.
        
        if (findStatus == noErr) {
            // Modify password in the duplicate item.
            modifyStatus = SecKeychainItemModifyAttributesAndData(keychainItemRef,
                                                                  NULL,  // No changes in attributes.
                                                                  [password length],
                                                                  [password UTF8String]);
            
            if (modifyStatus == noErr) {
                success = YES;
            }
        }
    }
    
    if (keychainItemRef != nil) {
        CFRelease(keychainItemRef);
    }
    
    return success;
}

@end
