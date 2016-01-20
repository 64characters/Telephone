//
//  AKKeychain.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

#import "AKKeychain.h"


@implementation AKKeychain

+ (NSString *)passwordForServiceName:(NSString *)serviceName accountName:(NSString *)accountName {
    void *passwordData = nil;
    UInt32 passwordLength;
    OSStatus findStatus;
    
    findStatus = SecKeychainFindGenericPassword(NULL,   // Default keychain.
                                                (UInt32)[serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                [serviceName UTF8String],
                                                (UInt32)[accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                [accountName UTF8String],
                                                &passwordLength,
                                                &passwordData,
                                                NULL);  // Keychain item reference.
    
    if (findStatus != noErr) {
        return nil;
    }
    
    NSString *password = [[NSString alloc] initWithBytes:passwordData
                                                   length:passwordLength
                                                 encoding:NSUTF8StringEncoding];
    
    SecKeychainItemFreeContent(NULL, passwordData);
    
    return password;
}

+ (BOOL)addItemWithServiceName:(NSString *)serviceName
                   accountName:(NSString *)accountName
                      password:(NSString *)password {
    
    SecKeychainItemRef keychainItemRef = nil;
    OSStatus addStatus, findStatus, modifyStatus;
    BOOL success = NO;
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    // Add item to keychain.
    addStatus = SecKeychainAddGenericPassword(NULL,   // NULL for default keychain.
                                              (UInt32)[serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                              [serviceName UTF8String],
                                              (UInt32)[accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                              [accountName UTF8String],
                                              (UInt32)passwordData.length,
                                              passwordData.bytes,
                                              NULL);  // Don't need keychain item reference.
    
    if (addStatus == noErr) {
        success = YES;
        
    } else if (addStatus == errSecDuplicateItem) {
        // Get the pointer to the duplicate item.
        findStatus = SecKeychainFindGenericPassword(NULL,               // Default keychain.
                                                    (UInt32)[serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                    [serviceName UTF8String],
                                                    (UInt32)[accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                    [accountName UTF8String],
                                                    NULL,
                                                    NULL,
                                                    &keychainItemRef);  // Pointer to the duplicate item.
        
        if (findStatus == noErr) {
            // Modify password in the duplicate item.
            modifyStatus = SecKeychainItemModifyAttributesAndData(keychainItemRef,
                                                                  NULL,  // No changes in attributes.
                                                                  (UInt32)passwordData.length,
                                                                  passwordData.bytes);
            
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
