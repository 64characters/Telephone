//
//  PJSUAOnCallReplaced.m
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

#import "PJSUACallbacks.h"

#import "AKSIPAccount.h"
#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"
#import "PJSUACallInfo.h"

#define THIS_FILE "PJSUAOnCallReplaced.m"

void PJSUAOnCallReplaced(pjsua_call_id oldID, pjsua_call_id newID) {
    pjsua_call_info oldInfo, newInfo;
    pjsua_call_get_info(oldID, &oldInfo);
    pjsua_call_get_info(newID, &newInfo);

    PJ_LOG(3, (THIS_FILE, "Call %d with %.*s is being replaced by call %d with %.*s",
               oldID, (int)oldInfo.remote_info.slen, oldInfo.remote_info.ptr,
               newID, (int)newInfo.remote_info.slen, newInfo.remote_info.ptr));

    AKSIPUserAgent *agent = [AKSIPUserAgent sharedUserAgent];
    PJSUACallInfo *newInfoWrapper = [[PJSUACallInfo alloc] initWithInfo:newInfo parser:agent.parser];

    dispatch_async(dispatch_get_main_queue(), ^{
        PJ_LOG(3, (THIS_FILE, "Creating AKSIPCall for call %d from replaced callback", newID));
        AKSIPAccount *account = [agent accountWithIdentifier:newInfoWrapper.accountIdentifier];
        [account addCallWithInfo:newInfoWrapper];
    });
}
