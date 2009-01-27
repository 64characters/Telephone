//
//  NSStringAdditions.m
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
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSStringAdditions.h"


@implementation NSString(UUID)

+ (NSString *)AK_uuidString
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	
	return [(NSString *)string autorelease];
}

@end

@implementation NSString(PJSUA)

+ (NSString *)stringWithPJString:(pj_str_t)pjString
{
	return [[[NSString alloc] initWithBytes:pjString.ptr
									 length:(NSUInteger)pjString.slen
								   encoding:NSUTF8StringEncoding]
			autorelease];
}

- (pj_str_t)pjString
{
	return pj_str((char *)[self cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end

@implementation NSString(Additions)

@dynamic AK_isTelephoneNumber;
@dynamic AK_hasLetters;

- (BOOL)AK_isTelephoneNumber
{
	NSPredicate *telephoneNumberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\+?\\\\d+'"];
	if ([telephoneNumberPredicate evaluateWithObject:self])
		return YES;
	
	return NO;
}

- (BOOL)AK_hasLetters
{
	NSPredicate *containsLettersPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*[a-zA-Z].*'"];
	
	return ([containsLettersPredicate evaluateWithObject:self])	? YES : NO;
}

- (NSString *)AK_escapeFirstCharacterFromString:(NSString *)string
{
	NSMutableString *newString = [NSMutableString stringWithString:self];
	NSString *escapeCharacterString = [string substringWithRange:NSMakeRange(0, 1)];
	NSRange escapeCharacterRange = [newString rangeOfString:escapeCharacterString];
	while (escapeCharacterRange.location != NSNotFound) {
		[newString insertString:@"\\" atIndex:escapeCharacterRange.location];
		NSRange searchRange;
		searchRange.location = escapeCharacterRange.location + 2;
		searchRange.length = [newString length] - searchRange.location;
		escapeCharacterRange = [newString rangeOfString:escapeCharacterString options:0 range:searchRange];
	}
	
	return [[newString copy] autorelease];
}

- (NSString *)AK_escapeQuotes
{
	return [self AK_escapeFirstCharacterFromString:@"\""];
}

- (NSString *)AK_escapeParentheses
{
	NSString *returnString = [self AK_escapeFirstCharacterFromString:@")"];
	
	return [returnString AK_escapeFirstCharacterFromString:@"("];
}

@end
