//
//  PJSUACallbacks.m
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

#import "PJSUACallbacks.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPAccount.h"
#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"

#define THIS_FILE "PJSUACallbacks.m"

static void LogCallDump(int call_id);

void PJSUAOnIncomingCall(pjsua_acc_id accountIdentifier,
                               pjsua_call_id callIdentifier,
                               pjsip_rx_data *messageData) {

    PJ_LOG(3, (THIS_FILE, "Incoming call for account %d", accountIdentifier));
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPAccount *theAccount = [[AKSIPUserAgent sharedUserAgent] accountByIdentifier:accountIdentifier];

        // AKSIPCall object is created here when the call is incoming.
        AKSIPCall *theCall = [[AKSIPCall alloc] initWithSIPAccount:theAccount identifier:callIdentifier];

        [[theAccount calls] addObject:theCall];

        [theAccount.delegate SIPAccount:theAccount didReceiveCall:theCall];

        [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPCallIncomingNotification
                                                            object:theCall];
    });
}

void PJSUAOnCallState(pjsua_call_id callIdentifier, pjsip_event *sipEvent) {
    pjsua_call_info callInfo;
    pjsua_call_get_info(callIdentifier, &callInfo);

    BOOL mustStartRingback = NO;
    NSNumber *SIPEventCode = nil;
    NSString *SIPEventReason = nil;

    if (callInfo.state == PJSIP_INV_STATE_DISCONNECTED) {
        PJ_LOG(3, (THIS_FILE, "Call %d is DISCONNECTED [reason = %d (%s)]",
                   callIdentifier,
                   callInfo.last_status,
                   callInfo.last_status_text.ptr));
        PJ_LOG(5, (THIS_FILE, "Dumping media stats for call %d", callIdentifier));
        LogCallDump(callIdentifier);

    } else if (callInfo.state == PJSIP_INV_STATE_EARLY) {
        // pj_str_t is a struct with NOT null-terminated string.
        pj_str_t reason;
        pjsip_msg *msg;
        int code;

        // This can only occur because of TX or RX message.
        pj_assert(sipEvent->type == PJSIP_EVENT_TSX_STATE);

        if (sipEvent->body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
            msg = sipEvent->body.tsx_state.src.rdata->msg_info.msg;
        } else {
            msg = sipEvent->body.tsx_state.src.tdata->msg;
        }

        code = msg->line.status.code;
        reason = msg->line.status.reason;

        SIPEventCode = @(code);
        SIPEventReason = [NSString stringWithPJString:reason];

        // Start ringback for 180 for UAC unless there's SDP in 180.
        if (callInfo.role == PJSIP_ROLE_UAC &&
            code == 180 &&
            msg->body == NULL &&
            callInfo.media_status == PJSUA_CALL_MEDIA_NONE) {
            mustStartRingback = YES;
        }

        PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s (%d %.*s)",
                   callIdentifier, callInfo.state_text.ptr,
                   code, (int)reason.slen, reason.ptr));
    } else {
        PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s", callIdentifier, callInfo.state_text.ptr));
    }

    AKSIPCallState state = (AKSIPCallState)callInfo.state;
    NSInteger accountIdentifier = callInfo.acc_id;
    NSString *stateText = [NSString stringWithPJString:callInfo.state_text];
    NSInteger lastStatus = callInfo.last_status;
    NSString *lastStatusText = [NSString stringWithPJString:callInfo.last_status_text];

    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
        AKSIPCall *call = [userAgent SIPCallByIdentifier:callIdentifier];
        if (call == nil) {
            if (state == kAKSIPCallCallingState) {
                // As a convenience, AKSIPCall objects for normal outgoing calls are created
                // in -[AKSIPAccount makeCallTo:]. Outgoing calls for other situations like call transfer are first
                // seen here, and created on the spot.
                PJ_LOG(3, (THIS_FILE, "Creating AKSIPCall for call %d when handling call state", callIdentifier));
                AKSIPAccount *account = [userAgent accountByIdentifier:accountIdentifier];
                if (account != nil) {
                    call = [[AKSIPCall alloc] initWithSIPAccount:account identifier:callIdentifier];
                    [account.calls addObject:call];
                } else {
                    PJ_LOG(3, (THIS_FILE,
                               "Did not create AKSIPCall for call %d during call state change. Could not find account",
                               callIdentifier));
                    return;  // From block.
                }

            } else {
                PJ_LOG(3, (THIS_FILE, "Could not find AKSIPCall for call %d during call state change", callIdentifier));
                return;  // From block.
            }
        }

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        call.state = state;
        call.stateText = stateText;
        call.lastStatus = lastStatus;
        call.lastStatusText = lastStatusText;

        if (state == kAKSIPCallDisconnectedState) {
            [userAgent stopRingbackForCall:call];
            [call.account.calls removeObject:call];
            [nc postNotificationName:AKSIPCallDidDisconnectNotification object:call];

        } else if (state == kAKSIPCallEarlyState) {
            if (mustStartRingback) {
                [userAgent startRingbackForCall:call];
            }
            NSDictionary *userInfo = nil;
            if (SIPEventCode != nil && SIPEventReason != nil) {
                userInfo = @{@"AKSIPEventCode": SIPEventCode, @"AKSIPEventReason": SIPEventReason};
            }
            [nc postNotificationName:AKSIPCallEarlyNotification object:call userInfo:userInfo];

        } else {
            // Incoming call notification is posted from AKIncomingCallReceived().
            NSString *notificationName = nil;
            switch ((AKSIPCallState)state) {
                case kAKSIPCallCallingState:
                    notificationName = AKSIPCallCallingNotification;
                    break;
                case kAKSIPCallConnectingState:
                    notificationName = AKSIPCallConnectingNotification;
                    break;
                case kAKSIPCallConfirmedState:
                    notificationName = AKSIPCallDidConfirmNotification;
                    break;
                default:
                    assert(NO);
                    break;
            }

            if (notificationName != nil) {
                [nc postNotificationName:notificationName object:call];
            }
        }
    });
}

void PJSUAOnCallMediaState(pjsua_call_id callIdentifier) {
    pjsua_call_info callInfo;
    pjsua_call_get_info(callIdentifier, &callInfo);

    const char *statusName[] = {
        "None",
        "Active",
        "Local hold",
        "Remote hold",
        "Error"
    };

    for (NSUInteger i = 0; i < callInfo.media_cnt; i++) {
        assert(callInfo.media[i].status <= PJ_ARRAY_SIZE(statusName));
        assert(PJSUA_CALL_MEDIA_ERROR == 4);
        PJ_LOG(4, (THIS_FILE, "Call %d media %d [type = %s], status is %s",
                   callInfo.id, i, pjmedia_type_name(callInfo.media[i].type), statusName[callInfo.media[i].status]));
    }

    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE ||
        callInfo.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
        pjsua_conf_connect(callInfo.conf_slot, 0);
        pjsua_conf_connect(0, callInfo.conf_slot);
    }

    pjsua_call_media_status mediaStatus = callInfo.media_status;
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
        AKSIPCall *call = [userAgent SIPCallByIdentifier:callIdentifier];
        if (call == nil) {
            PJ_LOG(3, (THIS_FILE, "Could not find AKSIPCall for call %d during media state change", callIdentifier));
            return;  // From block.
        }
        [userAgent stopRingbackForCall:call];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSString *notificationName = nil;
        switch (mediaStatus) {
            case PJSUA_CALL_MEDIA_ACTIVE:
                notificationName = AKSIPCallMediaDidBecomeActiveNotification;
                break;
            case PJSUA_CALL_MEDIA_LOCAL_HOLD:
                notificationName = AKSIPCallDidLocalHoldNotification;
                break;
            case PJSUA_CALL_MEDIA_REMOTE_HOLD:
                notificationName = AKSIPCallDidRemoteHoldNotification;
                break;
            default:
                break;

        }
        if (notificationName != nil) {
            [nc postNotificationName:notificationName object:call];
        }
    });
}

void PJSUAOnCallTransferStatus(pjsua_call_id callIdentifier,
                                    int statusCode,
                                    const pj_str_t *statusText,
                                    pj_bool_t isFinal,
                                    pj_bool_t *pCont) {

    PJ_LOG(3, (THIS_FILE, "Call %d: transfer status=%d (%.*s) %s",
               callIdentifier, statusCode,
               (int)statusText->slen, statusText->ptr,
               (isFinal ? "[final]" : "")));

    if (statusCode / 100 == 2) {
        PJ_LOG(3, (THIS_FILE, "Call %d: call transfered successfully, disconnecting call", callIdentifier));
        pjsua_call_hangup(callIdentifier, PJSIP_SC_GONE, NULL, NULL);
        *pCont = PJ_FALSE;
    }

    NSString *statusTextString = [NSString stringWithPJString:*statusText];
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPCall *theCall = [[AKSIPUserAgent sharedUserAgent] SIPCallByIdentifier:callIdentifier];

        [theCall setTransferStatus:statusCode];
        [theCall setTransferStatusText:statusTextString];

        NSDictionary *userInfo = @{@"AKFinalTransferNotification": @((BOOL)isFinal)};

        [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPCallTransferStatusDidChangeNotification
                                                            object:theCall
                                                          userInfo:userInfo];
    });
}

void PJSUAOnCallReplaced(pjsua_call_id oldCallIdentifier, pjsua_call_id newCallIdentifier) {
    pjsua_call_info oldCallInfo, newCallInfo;
    pjsua_call_get_info(oldCallIdentifier, &oldCallInfo);
    pjsua_call_get_info(newCallIdentifier, &newCallInfo);

    PJ_LOG(3, (THIS_FILE, "Call %d with %.*s is being replaced by call %d with %.*s",
               oldCallIdentifier,
               (int)oldCallInfo.remote_info.slen, oldCallInfo.remote_info.ptr,
               newCallIdentifier,
               (int)newCallInfo.remote_info.slen, newCallInfo.remote_info.ptr));

    NSInteger accountIdentifier = newCallInfo.acc_id;
    dispatch_async(dispatch_get_main_queue(), ^{
        PJ_LOG(3, (THIS_FILE, "Creating AKSIPCall for call %d from replaced callback", newCallIdentifier));
        AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
        AKSIPAccount *account = [userAgent accountByIdentifier:accountIdentifier];
        AKSIPCall *call = [[AKSIPCall alloc] initWithSIPAccount:account identifier:newCallIdentifier];
        [account.calls addObject:call];
    });
}

void PJSUAOnCallRegistrationState(pjsua_acc_id accountIdentifier) {
    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPAccount *account = [[AKSIPUserAgent sharedUserAgent] accountByIdentifier:accountIdentifier];
        [account.delegate SIPAccountRegistrationDidChange:account];
    });
}

void PJSUAOnNATDetect(const pj_stun_nat_detect_result *result) {
    if (result->status != PJ_SUCCESS) {
        pjsua_perror(THIS_FILE, "NAT detection failed", result->status);

    } else {
        PJ_LOG(3, (THIS_FILE, "NAT detected as %s", result->nat_type_name));

        AKNATType NATType = (AKNATType)result->nat_type;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AKSIPUserAgent sharedUserAgent] setDetectedNATType:NATType];

            [[NSNotificationCenter defaultCenter] postNotificationName:AKSIPUserAgentDidDetectNATNotification
                                                                object:[AKSIPUserAgent sharedUserAgent]];
        });
    }
}

/*
 * Print log of call states. Since call states may be too long for logger,
 * printing it is a bit tricky, it should be printed part by part as long
 * as the logger can accept.
 */
static void LogCallDump(int call_id) {
    size_t call_dump_len;
    size_t part_len;
    unsigned part_idx;
    unsigned log_decor;
    static char some_buf[1024 * 3];

    pjsua_call_dump(call_id, PJ_TRUE, some_buf,
                    sizeof(some_buf), "  ");
    call_dump_len = strlen(some_buf);

    log_decor = pj_log_get_decor();
    pj_log_set_decor(log_decor & ~(PJ_LOG_HAS_NEWLINE | PJ_LOG_HAS_CR));
    PJ_LOG(4,(THIS_FILE, "\n"));
    pj_log_set_decor(0);

    part_idx = 0;
    part_len = PJ_LOG_MAX_SIZE-80;
    while (part_idx < call_dump_len) {
        char p_orig, *p;

        p = &some_buf[part_idx];
        if (part_idx + part_len > call_dump_len)
            part_len = call_dump_len - part_idx;
        p_orig = p[part_len];
        p[part_len] = '\0';
        PJ_LOG(4,(THIS_FILE, "%s", p));
        p[part_len] = p_orig;
        part_idx += part_len;
    }
    pj_log_set_decor(log_decor);
}

