//
//  AKNSString+Scanning.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2020 64 Characters
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

#import "AKNSString+Scanning.h"

static NSString * const kIP4Regex = @"((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])";

@implementation NSString (AKStringScanningAdditions)

- (BOOL)ak_hasLetters {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES '.*[a-zA-Z].*'"] evaluateWithObject:self];
}

- (BOOL)ak_isIPAddress {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES "
             "'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
             "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
             "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\\\."
             "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'"] evaluateWithObject:self];
}

- (BOOL)ak_isIP6Address {
    NSArray *components = @[
        @"SELF MATCHES ",
        @"'",
        @"(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|",         // 1:2:3:4:5:6:7:8
        @"([0-9a-fA-F]{1,4}:){1,7}:|",                         // 1::, 1:2:3:4:5:6:7::
        @"([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|",         // 1::8, 1:2:3:4:5:6::8
        @"([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|",  // 1::7:8, 1:2:3:4:5::7:8, 1:2:3:4:5::8
        @"([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|",  // 1::6:7:8, 1:2:3:4::6:7:8, 1:2:3:4::8
        @"([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|",  // 1::5:6:7:8, 1:2:3::5:6:7:8, 1:2:3::8
        @"([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|",  // 1::4:5:6:7:8, 1:2::4:5:6:7:8, 1:2::8
        @"[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|",       // 1::3:4:5:6:7:8, 1::3:4:5:6:7:8, 1::8
        @":((:[0-9a-fA-F]{1,4}){1,7}|:)|",                     // ::2:3:4:5:6:7:8, ::2:3:4:5:6:7:8, ::8, ::
        @"fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|",     // fe80::7:8%eth0, fe80::7:8%1
        @"::(ffff(:0{1,4}){0,1}:){0,1}", kIP4Regex, @"|",      // ::255.255.255.255, ::ffff:255.255.255.255, ::ffff:0:255.255.255.255
        @"([0-9a-fA-F]{1,4}:){1,4}:", kIP4Regex, @")",         // 2001:db8:3:4::192.0.2.33, 64:ff9b::192.0.2.33
        @"'"
    ];
    return [[NSPredicate predicateWithFormat:[components componentsJoinedByString:@""]] evaluateWithObject:self];
}

@end
