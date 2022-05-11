//
//  PJSUAOnCallTransferStatus.m
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

#import "AKNSString+PJSUA.h"
#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"

#define THIS_FILE "PJSUAOnCallTransferStatus.m"

void PJSUAOnCallTransferStatus(pjsua_call_id callID,
                               int statusCode,
                               const pj_str_t *statusText,
                               pj_bool_t isFinal,
                               pj_bool_t *wantsFurtherNotifications) {

    PJ_LOG(3, (THIS_FILE, "Call %d: transfer status=%d (%.*s) %s",
               callID, statusCode,
               (int)statusText->slen, statusText->ptr,
               (isFinal ? "[final]" : "")));

    if (statusCode / 100 == 2) {
        PJ_LOG(3, (THIS_FILE, "Call %d: call transfered successfully, disconnecting call", callID));
        pjsua_call_hangup(callID, PJSIP_SC_GONE, NULL, NULL);
        *wantsFurtherNotifications = PJ_FALSE;
    }

    NSString *statusTextString = [NSString stringWithPJString:*statusText];
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPCall *call = [[AKSIPUserAgent sharedUserAgent] callWithIdentifier:callID];

        [call setTransferStatus:statusCode];
        [call setTransferStatusText:statusTextString];

        NSDictionary *userInfo = @{@"AKFinalTransferNotification": @((BOOL)isFinal)};

        [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPCallTransferStatusDidChangeNotification
                                                            object:call
                                                          userInfo:userInfo];
    });
}
