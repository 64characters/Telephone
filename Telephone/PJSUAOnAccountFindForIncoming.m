//
//  PJSUAOnAccountFindForIncoming.m
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

void PJSUAOnAccountFindForIncoming(const pjsip_rx_data *rdata, pjsua_acc_id *acc_id) {
    pjsua_acc_info accounts[PJSUA_MAX_ACC];
    unsigned count = PJSUA_MAX_ACC;
    pj_status_t status = pjsua_acc_enum_info(accounts, &count);
    if (status != PJ_SUCCESS) {
        return;
    }
    pj_pool_t *pool = pjsua_pool_create("AKSIPUserAgent-uri-parsing-tmp", 512, 512);
    if (!pool) {
        return;
    }
    pjsip_sip_uri *to_uri = pjsip_uri_get_uri(rdata->msg_info.to->uri);
    pjsip_sip_uri *req_uri = pjsip_uri_get_uri(rdata->msg_info.msg->line.req.uri);
    int max_score = 0;
    pjsua_acc_id result = PJSUA_INVALID_ID;
    for (int i = 0; i < count; i++) {
        pjsua_acc_info acc = accounts[i];
        if (acc.id == PJSUA_INVALID_ID) {
            continue;
        }
        pjsip_name_addr *name_addr = (pjsip_name_addr *)pjsip_parse_uri(pool, acc.acc_uri.ptr, acc.acc_uri.slen, PJSIP_PARSE_URI_AS_NAMEADDR);
        if (!name_addr) {
            continue;
        }
        pjsip_sip_uri *acc_uri = pjsip_uri_get_uri(name_addr);
        int score = 0;
        // Match host.
        if (pj_stricmp(&acc_uri->host, &to_uri->host) == 0) {
            score += 10;
        }
        if (pj_stricmp(&acc_uri->host, &req_uri->host) == 0) {
            score += 10;
        }
        // Match username.
        if (pj_stricmp(&acc_uri->user, &to_uri->user) == 0) {
            score += 1;
        }
        if (pj_stricmp(&acc_uri->user, &req_uri->user) == 0) {
            score += 1;
        }
        if (score > max_score) {
            result = acc.id;
            max_score = score;
        }
    }
    if (result != PJSUA_INVALID_ID) {
        *acc_id = result;
    }
    pj_pool_release(pool);
}
