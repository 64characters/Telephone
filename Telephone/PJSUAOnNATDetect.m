//
//  PJSUAOnNATDetect.m
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

#import "AKSIPUserAgent.h"

#define THIS_FILE "PJSUAOnNATDetect.m"

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
