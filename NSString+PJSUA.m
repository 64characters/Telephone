//
//  NSString+PJSUA.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 29.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSString+PJSUA.h"


@implementation NSString(PJSUA)

+ (NSString *)stringWithPJString:(pj_str_t)pjString
{
	return [[[NSString alloc] initWithBytes:pjString.ptr
									 length:(NSUInteger)pjString.slen
								   encoding:NSASCIIStringEncoding]
			autorelease];
}

- (pj_str_t)pjString
{
	return pj_str((char *)[self cStringUsingEncoding:NSASCIIStringEncoding]);
}

@end
