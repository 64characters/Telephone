//
//  AKSIPCallNotifications.h
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

@import Foundation;

// Calling. After INVITE is sent.
extern NSString * const AKSIPCallCallingNotification;
//
// Incoming. After INVITE is received.
extern NSString * const AKSIPCallIncomingNotification;
//
// Early. After response with To tag.
// Keys: @"AKSIPEventCode", @"AKSIPEventReason".
extern NSString * const AKSIPCallEarlyNotification;
//
// Connecting. After 2xx is sent/received.
extern NSString * const AKSIPCallConnectingNotification;
//
// Confirmed. After ACK is sent/received.
extern NSString * const AKSIPCallDidConfirmNotification;
//
// Disconnected. Session is terminated.
extern NSString * const AKSIPCallDidDisconnectNotification;
//
// Call media is active.
extern NSString * const AKSIPCallMediaDidBecomeActiveNotification;
//
// Call media is put on hold by local endpoint.
extern NSString * const AKSIPCallDidLocalHoldNotification;
//
// Call media is put on hold by remote endpoint.
extern NSString * const AKSIPCallDidRemoteHoldNotification;
//
// Call transfer status changed.
// Key: @"AKFinalTransferNotification".
extern NSString * const AKSIPCallTransferStatusDidChangeNotification;
