//
//  AKSIPCallDelegate.h
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

/// Protocol that must be adopted by objects that want to act as delegates of AKSIPCall objects.
@protocol AKSIPCallDelegate <NSObject>

@optional

// Methods to handle AKSIPCall notifications to which the delegate is automatically subscribed.
- (void)SIPCallCalling:(NSNotification *)notification;
- (void)SIPCallIncoming:(NSNotification *)notification;
- (void)SIPCallEarly:(NSNotification *)notification;
- (void)SIPCallConnecting:(NSNotification *)notification;
- (void)SIPCallDidConfirm:(NSNotification *)notification;
- (void)SIPCallDidDisconnect:(NSNotification *)notification;
- (void)SIPCallMediaDidBecomeActive:(NSNotification *)notification;
- (void)SIPCallDidLocalHold:(NSNotification *)notification;
- (void)SIPCallDidRemoteHold:(NSNotification *)notification;
- (void)SIPCallTransferStatusDidChange:(NSNotification *)notification;

@end
