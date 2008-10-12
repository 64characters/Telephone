//
//  NSString+UUID.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 04.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"


@implementation NSString(UUID)

+ (NSString *)uuidString
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
	return [(NSString *)string autorelease];
}

@end
