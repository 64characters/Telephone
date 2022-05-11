//
//  PJSUAOnCallState.m
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
#import "AKSIPAccount.h"
#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"
#import "PJSUACallInfo.h"

#define THIS_FILE "PJSUAOnCallState.m"

static void LogCallDump(int call_id);

void PJSUAOnCallState(pjsua_call_id callID, pjsip_event *event) {
    pjsua_call_info info;
    pjsua_call_get_info(callID, &info);

    BOOL mustStartRingback = NO;
    NSNumber *SIPEventCode = nil;
    NSString *SIPEventReason = nil;

    if (info.state == PJSIP_INV_STATE_DISCONNECTED) {
        PJ_LOG(3, (THIS_FILE, "Call %d is DISCONNECTED [reason = %d (%s)]",
                   callID,
                   info.last_status,
                   info.last_status_text.ptr));
        PJ_LOG(5, (THIS_FILE, "Dumping media stats for call %d", callID));
        LogCallDump(callID);

    } else if (info.state == PJSIP_INV_STATE_EARLY) {
        // pj_str_t is a struct with NOT null-terminated string.
        pj_str_t reason;
        pjsip_msg *msg;
        int code;

        // This can only occur because of TX or RX message.
        pj_assert(event->type == PJSIP_EVENT_TSX_STATE);

        if (event->body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
            msg = event->body.tsx_state.src.rdata->msg_info.msg;
        } else {
            msg = event->body.tsx_state.src.tdata->msg;
        }

        code = msg->line.status.code;
        reason = msg->line.status.reason;

        SIPEventCode = @(code);
        SIPEventReason = [NSString stringWithPJString:reason];

        // Start ringback for 180 for UAC unless there's SDP in 180.
        if (info.role == PJSIP_ROLE_UAC &&
            code == 180 &&
            msg->body == NULL &&
            info.media[0].status == PJSUA_CALL_MEDIA_NONE) {
            mustStartRingback = YES;
        }

        PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s (%d %.*s)",
                   callID, info.state_text.ptr,
                   code, (int)reason.slen, reason.ptr));
    } else {
        PJ_LOG(3, (THIS_FILE, "Call %d state changed to %s", callID, info.state_text.ptr));
    }

    AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
    PJSUACallInfo *infoWrapper = [[PJSUACallInfo alloc] initWithInfo:info parser:userAgent.parser];
    NSInteger duration = info.connect_duration.sec;

    dispatch_async(dispatch_get_main_queue(), ^{
        AKSIPCall *call = [userAgent callWithIdentifier:callID];
        if (call == nil) {
            if (infoWrapper.state == kAKSIPCallCallingState) {
                AKSIPAccount *account = [userAgent accountWithIdentifier:infoWrapper.accountIdentifier];
                if (account != nil) {
                    call = [account addCallWithInfo:infoWrapper];
                } else {
                    PJ_LOG(3, (THIS_FILE,
                               "Did not create AKSIPCall for call %d during call state change. Could not find account",
                               callID));
                    return;  // From block.
                }

            } else {
                PJ_LOG(3, (THIS_FILE, "Could not find AKSIPCall for call %d during call state change", callID));
                return;  // From block.
            }
        }

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        call.state = infoWrapper.state;
        call.stateText = infoWrapper.stateText;
        call.lastStatus = infoWrapper.lastStatus;
        call.lastStatusText = infoWrapper.lastStatusText;
        call.duration = duration;

        if (infoWrapper.state == kAKSIPCallDisconnectedState) {
            [userAgent stopRingbackForCall:call];
            [call.account removeCall:call];
            [nc postNotificationName:AKSIPCallDidDisconnectNotification object:call];

        } else if (infoWrapper.state == kAKSIPCallEarlyState) {
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
            switch (infoWrapper.state) {
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
