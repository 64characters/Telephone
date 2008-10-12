//
//  NSNumber+PJSUA.m
//  Telephone
//
//  Created by Alexei Kuznetsov on 04.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+PJSUA.h"


@implementation NSNumber(PJSUA)

+ (NSNumber *)numberWithPJSUAAccountIdentifier:(pjsua_acc_id)identifier
{
	return [self numberWithInt:identifier];
}

+ (NSNumber *)numberWithPJSUACallIdentifier:(pjsua_call_id)identifier
{
	return [self numberWithInt:identifier];
}

- (pjsua_acc_id)pjsuaAccountIdentifierValue
{
	return [self intValue];
}

- (pjsua_call_id)pjsuaCallIdentifierValue
{
	return [self intValue];
}

@end
