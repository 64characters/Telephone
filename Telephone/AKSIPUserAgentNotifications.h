//
//  AKSIPUserAgentNotifications.h
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

// All AKSIPUserAgent notifications are posted by the user agent instance returned by |sharedUserAgent|.

// Posted when the user agent finishes starting. However, it may not be started if an error occurred during user agent
// start-up. You can check user agent state via the |state| property.
extern NSString * const AKSIPUserAgentDidFinishStartingNotification;
//
// Posted when the user agent finishes stopping.
extern NSString * const AKSIPUserAgentDidFinishStoppingNotification;
//
// Posted when the user agent detects NAT type, which can be accessed via
// the |detectedNATType| property.
extern NSString * const AKSIPUserAgentDidDetectNATNotification;
