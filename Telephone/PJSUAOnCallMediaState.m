//
//  PJSUAOnCallMediaState.m
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

#import "AKSIPCall.h"
#import "AKSIPUserAgent.h"

#define THIS_FILE "PJSUAOnCallMediaState.m"

static void LogCallMedia(const pjsua_call_info *callInfo);
static void CallMediaStateChanged(pjsua_call_id identifier, pjsua_call_media_status status, pjsua_conf_port_id port);
static const char *MediaStatusTextWithStatus(pjsua_call_media_status status);
static void ConnectCallToSoundDevice(AKSIPCall *call, pjsua_call_media_status status, pjsua_conf_port_id port);
static void PostMediaStateChangeNotification(AKSIPCall *call, pjsua_call_media_status status);

void PJSUAOnCallMediaState(pjsua_call_id callID) {
    pjsua_call_info info;
    pjsua_call_get_info(callID, &info);
    LogCallMedia(&info);
    pjsua_call_id identifier = info.id;
    pjsua_call_media_status status = info.media[0].status;
    pjsua_conf_port_id port = info.media[0].stream.aud.conf_slot;
    dispatch_async(dispatch_get_main_queue(), ^{
        CallMediaStateChanged(identifier, status, port);
    });
}

static void LogCallMedia(const pjsua_call_info *callInfo) {
    for (NSUInteger i = 0; i < callInfo->media_cnt; i++) {
        PJ_LOG(4, (THIS_FILE, "Call %d media %d [type = %s], status is %s",
                   callInfo->id, i, pjmedia_type_name(callInfo->media[i].type),
                   MediaStatusTextWithStatus(callInfo->media[i].status)));
    }
}

static void CallMediaStateChanged(pjsua_call_id identifier, pjsua_call_media_status status, pjsua_conf_port_id port) {
    AKSIPUserAgent *userAgent = [AKSIPUserAgent sharedUserAgent];
    AKSIPCall *call = [userAgent callWithIdentifier:identifier];
    if (call == nil) {
        PJ_LOG(3, (THIS_FILE, "Could not find AKSIPCall for call %d during media state change", identifier));
        return;
    }
    ConnectCallToSoundDevice(call, status, port);
    [userAgent stopRingbackForCall:call];
    PostMediaStateChangeNotification(call, status);
}

static const char *MediaStatusTextWithStatus(pjsua_call_media_status status) {
    const char *texts[] = { "None", "Active", "Local hold", "Remote hold", "Error" };
    return texts[status];
}

static void ConnectCallToSoundDevice(AKSIPCall *call, pjsua_call_media_status status, pjsua_conf_port_id port) {
    if (status == PJSUA_CALL_MEDIA_ACTIVE || status == PJSUA_CALL_MEDIA_REMOTE_HOLD) {
        pjsua_conf_connect(port, 0);
        if (!call.isMicrophoneMuted) {
            pjsua_conf_connect(0, port);
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
