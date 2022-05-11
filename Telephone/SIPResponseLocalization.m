//
//  SIPResponseLocalization.m
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

#import "SIPResponseLocalization.h"

#import <pjsua-lib/pjsua.h>

NSString *LocalizedStringForSIPResponseCode(NSInteger code) {
    NSString *result = nil;

    switch (code) {
            // Provisional 1xx.
        case PJSIP_SC_TRYING:
            result = NSLocalizedStringFromTable(@"Trying", @"SIPResponses", @"100 Trying.");
            break;
        case PJSIP_SC_RINGING:
            result = NSLocalizedStringFromTable(@"Ringing", @"SIPResponses", @"180 Ringing.");
            break;
        case PJSIP_SC_CALL_BEING_FORWARDED:
            result = NSLocalizedStringFromTable(@"Call Is Being Forwarded",
                                                @"SIPResponses",
                                                @"181 Call Is Being Forwarded.");
            break;
        case PJSIP_SC_QUEUED:
            result = NSLocalizedStringFromTable(@"Queued", @"SIPResponses", @"182 Queued.");
            break;
        case PJSIP_SC_PROGRESS:
            result
            = NSLocalizedStringFromTable(@"Session Progress", @"SIPResponses", @"183 Session Progress.");
            break;

            // Successful 2xx.
        case PJSIP_SC_OK:
            result = NSLocalizedStringFromTable(@"OK", @"SIPResponses", @"200 OK.");
            break;
        case PJSIP_SC_ACCEPTED:
            result = NSLocalizedStringFromTable(@"Accepted", @"SIPResponses", @"202 Accepted.");
            break;

            // Redirection 3xx.
        case PJSIP_SC_MULTIPLE_CHOICES:
            result
            = NSLocalizedStringFromTable(@"Multiple Choices", @"SIPResponses", @"300 Multiple Choices.");
            break;
        case PJSIP_SC_MOVED_PERMANENTLY:
            result
            = NSLocalizedStringFromTable(@"Moved Permanently", @"SIPResponses", @"301 Moved Permanently.");
            break;
        case PJSIP_SC_MOVED_TEMPORARILY:
            result
            = NSLocalizedStringFromTable(@"Moved Temporarily", @"SIPResponses", @"302 Moved Temporarily.");
            break;
        case PJSIP_SC_USE_PROXY:
            result = NSLocalizedStringFromTable(@"Use Proxy", @"SIPResponses", @"305 Use Proxy.");
            break;
        case PJSIP_SC_ALTERNATIVE_SERVICE:
            result
            = NSLocalizedStringFromTable(@"Alternative Service", @"SIPResponses", @"380 Alternative Service.");
            break;

            // Request Failure 4xx.
        case PJSIP_SC_BAD_REQUEST:
            result = NSLocalizedStringFromTable(@"Bad Request", @"SIPResponses", @"400 Bad Request.");
            break;
        case PJSIP_SC_UNAUTHORIZED:
            result = NSLocalizedStringFromTable(@"Unauthorized", @"SIPResponses", @"401 Unauthorized.");
            break;
        case PJSIP_SC_PAYMENT_REQUIRED:
            result
            = NSLocalizedStringFromTable(@"Payment Required", @"SIPResponses", @"402 Payment Required.");
            break;
        case PJSIP_SC_FORBIDDEN:
            result = NSLocalizedStringFromTable(@"Forbidden", @"SIPResponses", @"403 Forbidden.");
            break;
        case PJSIP_SC_NOT_FOUND:
            result = NSLocalizedStringFromTable(@"Not Found", @"SIPResponses", @"404 Not Found.");
            break;
        case PJSIP_SC_METHOD_NOT_ALLOWED:
            result
            = NSLocalizedStringFromTable(@"Method Not Allowed", @"SIPResponses", @"405 Method Not Allowed.");
            break;
        case PJSIP_SC_NOT_ACCEPTABLE:
            result = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses", @"406 Not Acceptable.");
            break;
        case PJSIP_SC_PROXY_AUTHENTICATION_REQUIRED:
            result = NSLocalizedStringFromTable(@"Proxy Authentication Required",
                                                @"SIPResponses",
                                                @"407 Proxy Authentication Required.");
            break;
        case PJSIP_SC_REQUEST_TIMEOUT:
            result = NSLocalizedStringFromTable(@"Request Timeout", @"SIPResponses", @"408 Request Timeout.");
            break;
        case PJSIP_SC_GONE:
            result = NSLocalizedStringFromTable(@"Gone", @"SIPResponses", @"410 Gone.");
            break;
        case PJSIP_SC_REQUEST_ENTITY_TOO_LARGE:
            result = NSLocalizedStringFromTable(@"Request Entity Too Large",
                                                @"SIPResponses",
                                                @"413 Request Entity Too Large.");
            break;
        case PJSIP_SC_REQUEST_URI_TOO_LONG:
            result
            = NSLocalizedStringFromTable(@"Request-URI Too Long", @"SIPResponses", @"414 Request-URI Too Long.");
            break;
        case PJSIP_SC_UNSUPPORTED_MEDIA_TYPE:
            result = NSLocalizedStringFromTable(@"Unsupported Media Type",
                                                @"SIPResponses",
                                                @"415 Unsupported Media Type.");
            break;
        case PJSIP_SC_UNSUPPORTED_URI_SCHEME:
            result = NSLocalizedStringFromTable(@"Unsupported URI Scheme",
                                                @"SIPResponses",
                                                @"416 Unsupported URI Scheme.");
            break;
        case PJSIP_SC_BAD_EXTENSION:
            result = NSLocalizedStringFromTable(@"Bad Extension", @"SIPResponses", @"420 Bad Extension.");
            break;
        case PJSIP_SC_EXTENSION_REQUIRED:
            result
            = NSLocalizedStringFromTable(@"Extension Required", @"SIPResponses", @"421 Extension Required.");
            break;
        case PJSIP_SC_SESSION_TIMER_TOO_SMALL:
            result = NSLocalizedStringFromTable(@"Session Timer Too Small",
                                                @"SIPResponses",
                                                @"422 Session Timer Too Small.");
            break;
        case PJSIP_SC_INTERVAL_TOO_BRIEF:
            result
            = NSLocalizedStringFromTable(@"Interval Too Brief", @"SIPResponses", @"423 Interval Too Brief.");
            break;
        case PJSIP_SC_TEMPORARILY_UNAVAILABLE:
            result = NSLocalizedStringFromTable(@"Temporarily Unavailable",
                                                @"SIPResponses",
                                                @"480 Temporarily Unavailable.");
            break;
        case PJSIP_SC_CALL_TSX_DOES_NOT_EXIST:
            result = NSLocalizedStringFromTable(@"Call/Transaction Does Not Exist",
                                                @"SIPResponses",
                                                @"481 Call/Transaction Does Not Exist.");
            break;
        case PJSIP_SC_LOOP_DETECTED:
            result = NSLocalizedStringFromTable(@"Loop Detected", @"SIPResponses", @"482 Loop Detected.");
            break;
        case PJSIP_SC_TOO_MANY_HOPS:
            result = NSLocalizedStringFromTable(@"Too Many Hops", @"SIPResponses", @"483 Too Many Hops.");
            break;
        case PJSIP_SC_ADDRESS_INCOMPLETE:
            result
            = NSLocalizedStringFromTable(@"Address Incomplete", @"SIPResponses", @"484 Address Incomplete.");
            break;
        case PJSIP_AC_AMBIGUOUS:
            result = NSLocalizedStringFromTable(@"Ambiguous", @"SIPResponses", @"485 Ambiguous.");
            break;
        case PJSIP_SC_BUSY_HERE:
            result = NSLocalizedStringFromTable(@"Busy Here", @"SIPResponses", @"486 Busy Here.");
            break;
        case PJSIP_SC_REQUEST_TERMINATED:
            result
            = NSLocalizedStringFromTable(@"Request Terminated", @"SIPResponses", @"487 Request Terminated.");
            break;
        case PJSIP_SC_NOT_ACCEPTABLE_HERE:
            result
            = NSLocalizedStringFromTable(@"Not Acceptable Here", @"SIPResponses", @"488 Not Acceptable Here.");
            break;
        case PJSIP_SC_BAD_EVENT:
            result = NSLocalizedStringFromTable(@"Bad Event", @"SIPResponses", @"489 Bad Event.");
            break;
        case PJSIP_SC_REQUEST_UPDATED:
            result = NSLocalizedStringFromTable(@"Request Updated", @"SIPResponses", @"490 Request Updated.");
            break;
        case PJSIP_SC_REQUEST_PENDING:
            result = NSLocalizedStringFromTable(@"Request Pending", @"SIPResponses", @"491 Request Pending.");
            break;
        case PJSIP_SC_UNDECIPHERABLE:
            result = NSLocalizedStringFromTable(@"Undecipherable", @"SIPResponses", @"493 Undecipherable.");
            break;

            // Server Failure 5xx.
        case PJSIP_SC_INTERNAL_SERVER_ERROR:
            result
            = NSLocalizedStringFromTable(@"Server Internal Error", @"SIPResponses", @"500 Server Internal Error.");
            break;
        case PJSIP_SC_NOT_IMPLEMENTED:
            result = NSLocalizedStringFromTable(@"Not Implemented", @"SIPResponses", @"501 Not Implemented.");
            break;
        case PJSIP_SC_BAD_GATEWAY:
            result = NSLocalizedStringFromTable(@"Bad Gateway", @"SIPResponses", @"502 Bad Gateway.");
            break;
        case PJSIP_SC_SERVICE_UNAVAILABLE:
            result
            = NSLocalizedStringFromTable(@"Service Unavailable", @"SIPResponses", @"503 Service Unavailable.");
            break;
        case PJSIP_SC_SERVER_TIMEOUT:
            result = NSLocalizedStringFromTable(@"Server Time-out", @"SIPResponses", @"504 Server Time-out.");
            break;
        case PJSIP_SC_VERSION_NOT_SUPPORTED:
            result
            = NSLocalizedStringFromTable(@"Version Not Supported", @"SIPResponses", @"505 Version Not Supported.");
            break;
        case PJSIP_SC_MESSAGE_TOO_LARGE:
            result
            = NSLocalizedStringFromTable(@"Message Too Large", @"SIPResponses", @"513 Message Too Large.");
            break;
        case PJSIP_SC_PRECONDITION_FAILURE:
            result
            = NSLocalizedStringFromTable(@"Precondition Failure", @"SIPResponses", @"580 Precondition Failure.");
            break;

            // Global Failures 6xx.
        case PJSIP_SC_BUSY_EVERYWHERE:
            result = NSLocalizedStringFromTable(@"Busy Everywhere", @"SIPResponses", @"600 Busy Everywhere.");
            break;
        case PJSIP_SC_DECLINE:
            result = NSLocalizedStringFromTable(@"Decline", @"SIPResponses", @"603 Decline.");
            break;
        case PJSIP_SC_DOES_NOT_EXIST_ANYWHERE:
            result = NSLocalizedStringFromTable(@"Does Not Exist Anywhere",
                                                @"SIPResponses",
                                                @"604 Does Not Exist Anywhere.");
            break;
        case PJSIP_SC_NOT_ACCEPTABLE_ANYWHERE:
            result = NSLocalizedStringFromTable(@"Not Acceptable", @"SIPResponses", @"606 Not Acceptable.");
            break;
        default:
            result = nil;
            break;
    }

    return result;
}
