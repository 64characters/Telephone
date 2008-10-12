//
//  NSString+PJSUA.h
//  Telephone
//
//  Created by Alexei Kuznetsov on 29.09.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <pjsua-lib/pjsua.h>


@interface NSString(PJSUA)

+ (NSString *)stringWithPJString:(pj_str_t)pjString;
- (pj_str_t)pjString;

@end
