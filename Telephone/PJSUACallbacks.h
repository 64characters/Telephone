//
//  PJSUACallbacks.h
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

#import <pjsua-lib/pjsua.h>

void PJSUAOnIncomingCall(pjsua_acc_id accountID, pjsua_call_id callID, pjsip_rx_data *invite);
void PJSUAOnCallState(pjsua_call_id callID, pjsip_event *event);
void PJSUAOnCallMediaState(pjsua_call_id callID);
void PJSUAOnCallTransferStatus(pjsua_call_id callID,
                               int statusCode,
                               const pj_str_t *statusText,
                               pj_bool_t isFinal,
                               pj_bool_t *wantsFurtherNotifications);
void PJSUAOnCallReplaced(pjsua_call_id oldCallID, pjsua_call_id newCallID);
void PJSUAOnAccountRegistrationState(pjsua_acc_id accountID);
void PJSUAOnNATDetect(const pj_stun_nat_detect_result *result);
void PJSUAOnAccountFindForIncoming(const pjsip_rx_data *rdata, pjsua_acc_id *acc_id);
