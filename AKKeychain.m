//
//  AKKeychain.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 29.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKKeychain.h"


@implementation AKKeychain

+ (NSString *)passwordForServiceName:(NSString *)serviceName
						 accountName:(NSString *)accountName
{
	void *passwordData = nil;
	UInt32 passwordLength;
	OSStatus findStatus;
	
	findStatus = SecKeychainFindGenericPassword(
												NULL,	// Default keychain
												[serviceName length],
												[serviceName UTF8String],
												[accountName length],
												[accountName UTF8String],
												&passwordLength,
												&passwordData,
												NULL	// Keychain item reference
	);
	if (findStatus != noErr)
		return nil;
	
	NSString *password = [[NSString alloc] initWithBytes:passwordData
												  length:passwordLength
												encoding:NSUTF8StringEncoding];
	SecKeychainItemFreeContent(NULL, passwordData);
	
	return [password autorelease];
}

// Try to add item to keychain.
// If there is a duplicate, update its password with new one
+ (BOOL)addItemWithServiceName:(NSString *)serviceName
				  accountName:(NSString *)accountName
					 password:(NSString *)password
{
	SecKeychainItemRef keychainItemRef = nil;
	OSStatus addStatus, findStatus, modifyStatus;
	BOOL success = NO;
	
	// Add item to keychain
	addStatus = SecKeychainAddGenericPassword(
										   NULL,		// NULL for default keychain
										   [serviceName length],
										   [serviceName UTF8String],
										   [accountName length],
										   [accountName UTF8String],
										   [password length],
										   [password UTF8String],
										   NULL			// Don't need keychain item reference
	);
	
	if (addStatus == noErr) {
		NSLog(@"Added keychain item for %@", serviceName);
		success = YES;
	} else if (addStatus == errSecDuplicateItem) {
		// Get the pointer to the duplicate item
		findStatus = SecKeychainFindGenericPassword(
												NULL,	// Default keychain
												[serviceName length],
												[serviceName UTF8String],
												[accountName length],
												[accountName UTF8String],
												NULL,
												NULL,
												&keychainItemRef	// Pointer to the duplicate item
		);
		
		if (findStatus == noErr) {
			// Modify password in the duplicate item
			modifyStatus = SecKeychainItemModifyAttributesAndData(
															keychainItemRef,
															NULL,	// No changes in attributes
															[password length],
															[password UTF8String]
			);
			
			if (modifyStatus == noErr) {
				NSLog(@"Modified keychain password for %@", serviceName);
				success = YES;
			}
		}
	}
	
	if (keychainItemRef != nil)
		CFRelease(keychainItemRef);
	
	return success;
}

@end
