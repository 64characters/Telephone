//
//  PJSUAOnIncomingCall.m
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

#define THIS_FILE "PJSUAOnIncomingCall.m"

void PJSUAOnIncomingCall(pjsua_acc_id accountID, pjsua_call_id callID, pjsip_rx_data *invite) {
    PJ_LOG(3, (THIS_FILE, "Incoming call for account %d", accountID));
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPAccount *account = [[AKSIPUserAgent sharedUserAgent] accountWithIdentifier:accountID];
        AKSIPCall *call = [account addIncomingCallWithIdentifier:callID];
        [account.delegate SIPAccount:account didReceiveCall:call];
        [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPCallIncomingNotification object:call];
    });
}
