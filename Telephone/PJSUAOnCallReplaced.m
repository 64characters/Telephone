//
//  PJSUAOnCallReplaced.m
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#define THIS_FILE "PJSUAOnCallReplaced.m"

void PJSUAOnCallReplaced(pjsua_call_id oldCallID, pjsua_call_id newCallID) {
    pjsua_call_info oldCallInfo, newCallInfo;
    pjsua_call_get_info(oldCallID, &oldCallInfo);
    pjsua_call_get_info(newCallID, &newCallInfo);

    PJ_LOG(3, (THIS_FILE, "Call %d with %.*s is being replaced by call %d with %.*s",
               oldCallID,
               (int)oldCallInfo.remote_info.slen, oldCallInfo.remote_info.ptr,
               newCallID,
               (int)newCallInfo.remote_info.slen, newCallInfo.remote_info.ptr));

    NSInteger accountIdentifier = newCallInfo.acc_id;
    dispatch_async(dispatch_get_main_queue(), ^{
        PJ_LOG(3, (THIS_FILE, "Creating AKSIPCall for call %d from replaced callback", newCallID));
        AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
        AKSIPAccount *account = [userAgent accountByIdentifier:accountIdentifier];
        AKSIPCall *call = [[AKSIPCall alloc] initWithSIPAccount:account identifier:newCallID];
        [account.calls addObject:call];
    });
}
