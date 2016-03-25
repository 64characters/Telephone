//
//  PJSUACallbacks.h
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
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

// Callbacks from PJSUA.
//
// Sent when incoming call is received.
void AKSIPCallIncomingReceived(pjsua_acc_id, pjsua_call_id, pjsip_rx_data *);
//
// Sent when call state changes.
void AKSIPCallStateChanged(pjsua_call_id, pjsip_event *);
//
// Sent when media state of the call changes.
void AKSIPCallMediaStateChanged(pjsua_call_id);
//
// Sent when call transfer status changes.
void AKSIPCallTransferStatusChanged(pjsua_call_id callIdentifier,
                                    int statusCode,
                                    const pj_str_t *statusText,
                                    pj_bool_t isFinal,
                                    pj_bool_t *pCont);
//
// Sent when existing call has been replaced with a new call.
void AKSIPCallReplaced(pjsua_call_id oldCallIdentifier, pjsua_call_id newCallIdentifier);
//
// Sent when account registration state changes.
void AKSIPAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier);
//
// Sent when NAT type is detected.
void AKSIPUserAgentDetectedNAT(const pj_stun_nat_detect_result *result);
