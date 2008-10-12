//
//  NSNumber+PJSUA.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 04.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <pjsua-lib/pjsua.h>


@interface NSNumber(PJSUA)

+ (NSNumber *)numberWithPJSUAAccountIdentifier:(pjsua_acc_id)identifier;
+ (NSNumber *)numberWithPJSUACallIdentifier:(pjsua_call_id)identifier;

- (pjsua_acc_id)pjsuaAccountIdentifierValue;
- (pjsua_call_id)pjsuaCallIdentifierValue;

@end
