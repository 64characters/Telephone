//
//  PJSUACallInfo.m
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
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

#import "PJSUACallInfo.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKSIPURIParser.h"

@implementation PJSUACallInfo

- (instancetype)initWithInfo:(pjsua_call_info)info parser:(AKSIPURIParser *)parser {
    if ((self = [super init])) {
        _identifier = info.id;
        _accountIdentifier = info.acc_id;
        _state = (AKSIPCallState)info.state;
        _stateText = [NSString stringWithPJString:info.state_text];
        _lastStatus = info.last_status;
        _lastStatusText = [NSString stringWithPJString:info.last_status_text];
        _localURI = [parser SIPURIFromString:[NSString stringWithPJString:info.local_info]];
        _remoteURI = [parser SIPURIFromString:[NSString stringWithPJString:info.remote_info]];
        _incoming = info.role == PJSIP_ROLE_UAS;
    }
    return self;
}

@end
