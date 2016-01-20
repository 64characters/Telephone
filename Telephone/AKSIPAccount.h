//
//  AKSIPAccount.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

#import "AKSIPAccountDelegate.h"


// SIP account defaults.
extern const NSInteger kAKSIPAccountDefaultSIPProxyPort;
extern const NSInteger kAKSIPAccountDefaultReregistrationTime;

// Notifications.
//
// Posted when account is about to make call.
extern NSString * const AKSIPAccountWillMakeCallNotification;

@class AKSIPCall, AKSIPURI;

// A class representing a SIP account. It contains a list of calls and maintains SIP registration. You can use this
// class to make and receive calls.
@interface AKSIPAccount : NSObject

// The receiver's delegate.
@property(nonatomic, weak) id <AKSIPAccountDelegate> delegate;

// The URI for SIP registration.
// It is composed of |fullName| and |SIPAddress|, e.g. "John Smith" <john@company.com>
// TODO(eofster): strange property. Do we need this?
@property(nonatomic, copy) AKSIPURI *registrationURI;

// Full name of the registration URI.
@property(nonatomic, copy) NSString *fullName;

// SIP address of the registration URI.
@property(nonatomic, copy) NSString *SIPAddress;

// Registrar.
@property(nonatomic, copy) NSString *registrar;

// Realm. Pass nil to make a credential that can be used to authenticate against any challenges.
@property(nonatomic, copy) NSString *realm;

// Authentication user name.
@property(nonatomic, copy) NSString *username;

// SIP proxy host.
@property(nonatomic, copy) NSString *proxyHost;

// Network port to use with the SIP proxy.
// Default: 5060.
@property(nonatomic, assign) NSUInteger proxyPort;

// SIP re-registration time.
// Default: 300 (sec).
@property(nonatomic, assign) NSUInteger reregistrationTime;

/// A Boolean value indicating if Contact header should be automatically updated.
///
/// When YES, the library will keep track of the public IP address from the response of the REGISTER request.
@property(nonatomic, assign) BOOL updatesContactHeader;

/// A Boolean value indicating if Via header should be automatically updated.
///
/// When YES, the "sent-by" field of the Via header will be overwritten for outgoing messages with the same interface
/// address as the one in the REGISTER request.
@property(nonatomic, assign) BOOL updatesViaHeader;

// The receiver's identifier at the user agent.
@property(nonatomic, assign) NSInteger identifier;

// A Boolean value indicating whether the receiver is registered.
@property(nonatomic, assign, getter=isRegistered) BOOL registered;

// The receiver's SIP registration status code.
@property(nonatomic, readonly, assign) NSInteger registrationStatus;

// The receiver's SIP registration status text.
@property(nonatomic, readonly, copy) NSString *registrationStatusText;

// An up to date expiration interval for the receiver's registration session.
@property(nonatomic, readonly, assign) NSInteger registrationExpireTime;

// A Boolean value indicating whether the receiver is online in terms of SIP
// presence.
@property(nonatomic, assign, getter=isOnline) BOOL online;

// Presence online status text.
@property(nonatomic, readonly, copy) NSString *onlineStatusText;

// Calls that belong to the receiver.
@property(nonatomic, readonly, strong) NSMutableArray *calls;

// Creates and returns an AKSIPAccount object initialized with a given full name, SIP address, registrar, realm, and
// user name.
+ (instancetype)SIPAccountWithFullName:(NSString *)aFullName
                            SIPAddress:(NSString *)aSIPAddress
                             registrar:(NSString *)aRegistrar
                                 realm:(NSString *)aRealm
                              username:(NSString *)aUsername;

// Designated initializer.
// Initializes an AKSIPAccount object with a given full name, SIP address, registrar, realm, and user name.
- (instancetype)initWithFullName:(NSString *)aFullName
                      SIPAddress:(NSString *)aSIPAddress
                       registrar:(NSString *)aRegistrar
                           realm:(NSString *)aRealm
                        username:(NSString *)aUsername;

// Makes a call to a given destination URI.
- (AKSIPCall *)makeCallTo:(AKSIPURI *)destinationURI;

@end
