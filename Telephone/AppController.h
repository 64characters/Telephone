//
//  AppController.h
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

#import <Cocoa/Cocoa.h>

#import "AKSIPUserAgent.h"


/// NSUserNotification user info dictionary key containing call controller identifier.
extern NSString * const kUserNotificationCallControllerIdentifierKey;

// Application controller and NSApplication delegate.
@interface AppController : NSObject <AKSIPUserAgentDelegate>

- (BOOL)canStopPlayingRingtone;

// Updates Dock tile badge label.
- (void)updateDockTileBadgeLabel;

// Returns a localized string describing a given SIP response code.
- (NSString *)localizedStringForSIPResponseCode:(NSInteger)responseCode;

@end
