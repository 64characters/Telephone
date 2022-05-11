//
//  AKSIPUserAgentDelegate.h
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

@class AKSIPAccount;

/// Protocol that must be adopted by objects that want to act as delegates of AKSIPUserAgent objects.
@protocol AKSIPUserAgentDelegate <NSObject>

@optional

/// Called when AKSIPUserAgent is about to add an account.
- (BOOL)SIPUserAgentShouldAddAccount:(AKSIPAccount *)anAccount;

// Methods to handle AKSIPUserAgent notifications to which delegate is automatically subscribed.
- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification;
- (void)SIPUserAgentDidFinishStopping:(NSNotification *)notification;
- (void)SIPUserAgentDidDetectNAT:(NSNotification *)notification;

@end
