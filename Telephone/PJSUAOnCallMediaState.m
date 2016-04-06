//
//  PJSUAOnCallMediaState.m
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

#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"

#define THIS_FILE "PJSUAOnCallMediaState.m"

static void LogCallMedia(const pjsua_call_info *callInfo);
static void CallMediaStateChanged(pjsua_call_info callInfo);
static const char *MediaStatusTextWithStatus(pjsua_call_media_status status);
static void ConnectCallToSoundDevice(AKSIPCall *call, const pjsua_call_info *callInfo);
static void PostMediaStateChangeNotification(AKSIPCall *call, pjsua_call_media_status status);

void PJSUAOnCallMediaState(pjsua_call_id callID) {
    pjsua_call_info callInfo;
    pjsua_call_get_info(callID, &callInfo);
    LogCallMedia(&callInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        CallMediaStateChanged(callInfo);
    });
}

static void LogCallMedia(const pjsua_call_info *callInfo) {
    for (NSUInteger i = 0; i < callInfo->media_cnt; i++) {
        PJ_LOG(4, (THIS_FILE, "Call %d media %d [type = %s], status is %s",
                   callInfo->id, i, pjmedia_type_name(callInfo->media[i].type),
                   MediaStatusTextWithStatus(callInfo->media[i].status)));
    }
}

static void CallMediaStateChanged(pjsua_call_info callInfo) {
    AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
    AKSIPCall *call = [userAgent SIPCallByIdentifier:callInfo.id];
    if (call == nil) {
        PJ_LOG(3, (THIS_FILE, "Could not find AKSIPCall for call %d during media state change", callInfo.id));
        return;
    }
    ConnectCallToSoundDevice(call, &callInfo);
    [userAgent stopRingbackForCall:call];
    PostMediaStateChangeNotification(call, callInfo.media_status);
}

static const char *MediaStatusTextWithStatus(pjsua_call_media_status status) {
    const char *texts[] = { "None", "Active", "Local hold", "Remote hold", "Error" };
    return texts[status];
}

static void ConnectCallToSoundDevice(AKSIPCall *call, const pjsua_call_info *callInfo) {
    if (callInfo->media_status == PJSUA_CALL_MEDIA_ACTIVE ||
        callInfo->media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
        pjsua_conf_connect(callInfo->conf_slot, 0);
        if (!call.isMicrophoneMuted) {
            pjsua_conf_connect(0, callInfo->conf_slot);
        }
    }
}

static void PostMediaStateChangeNotification(AKSIPCall *call, pjsua_call_media_status status) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *notificationName = nil;
    switch (status) {
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
}
