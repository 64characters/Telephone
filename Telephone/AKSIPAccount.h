//
//  AKSIPAccount.h
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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

@import UseCases;

#import "AKSIPAccountDelegate.h"

@class PJSUACallInfo;

NS_ASSUME_NONNULL_BEGIN

// SIP account defaults.
extern const NSInteger kAKSIPAccountDefaultSIPProxyPort;
extern const NSInteger kAKSIPAccountDefaultReregistrationTime;

@class AKSIPCall, AKSIPURI;

// A class representing a SIP account. It contains a list of calls and maintains SIP registration. You can use this
// class to make and receive calls.
@interface AKSIPAccount : NSObject <Account>

// The receiver's delegate.
@property(nonatomic, weak) id <AKSIPAccountDelegate> delegate;

// The URI for SIP registration.
// It is composed of |fullName| and |SIPAddress|, e.g. "John Smith" <john@company.com>
// TODO(eofster): strange property. Do we need this?
@property(nonatomic, readonly) AKSIPURI *registrationURI;

// Full name of the registration URI.
@property(nonatomic, readonly) NSString *fullName;

// SIP address of the registration URI.
@property(nonatomic, readonly) NSString *SIPAddress;

// Registrar.
@property(nonatomic, readonly) NSString *registrar;

// Realm. Pass empty string to make a credential that can be used to authenticate against any challenges.
@property(nonatomic, readonly) NSString *realm;

// Authentication user name.
@property(nonatomic, readonly) NSString *username;

@property(nonatomic, readonly, copy) NSString *domain;

// SIP proxy host.
@property(nonatomic, copy) NSString *proxyHost;

// Network port to use with the SIP proxy.
// Default: 5060.
@property(nonatomic) NSUInteger proxyPort;

// SIP re-registration time.
// Default: 300 (sec).
@property(nonatomic) NSUInteger reregistrationTime;

/// A Boolean value indicating if Contact header should be automatically updated.
///
/// When YES, the library will keep track of the public IP address from the response of the REGISTER request.
@property(nonatomic) BOOL updatesContactHeader;

/// A Boolean value indicating if Via header should be automatically updated.
///
/// When YES, the "sent-by" field of the Via header will be overwritten for outgoing messages with the same interface
/// address as the one in the REGISTER request.
@property(nonatomic) BOOL updatesViaHeader;

// The receiver's identifier at the user agent.
@property(nonatomic, readonly) NSInteger identifier;

// A Boolean value indicating whether the receiver is registered.
@property(nonatomic, getter=isRegistered) BOOL registered;

// The receiver's SIP registration status code.
@property(nonatomic, readonly) NSInteger registrationStatus;

// The receiver's SIP registration error code.
@property(nonatomic, readonly) NSInteger registrationErrorCode;

// The receiver's SIP registration status text.
@property(nonatomic, readonly) NSString *registrationStatusText;

// An up to date expiration interval for the receiver's registration session.
@property(nonatomic, readonly) NSInteger registrationExpireTime;

// A Boolean value indicating whether the receiver is online in terms of SIP
// presence.
@property(nonatomic, getter=isOnline) BOOL online;

// Presence online status text.
@property(nonatomic, readonly) NSString *onlineStatusText;

@property(nonatomic, readonly) BOOL hasUnansweredIncomingCalls;

@property(nonatomic) NSThread *thread;

- (instancetype)initWithUUID:(NSString *)uuid
                    fullName:(NSString *)fullName
                  SIPAddress:(nullable NSString *)SIPAddress
                   registrar:(nullable NSString *)registrar
                       realm:(NSString *)realm
                    username:(NSString *)username
                      domain:(NSString *)domain;

- (void)updateUsername:(NSString *)username;
- (void)updateIdentifier:(NSInteger)identifier;

// Makes a call to a given destination URI.
- (void)makeCallTo:(AKSIPURI *)destination completion:(void (^)(AKSIPCall *))completion;

- (AKSIPCall *)addCallWithInfo:(PJSUACallInfo *)info;
- (nullable AKSIPCall *)callWithIdentifier:(NSInteger)identifier;
- (void)removeCall:(AKSIPCall *)call;
- (void)removeAllCalls;
- (NSInteger)activeCallsCount;

@end

NS_ASSUME_NONNULL_END
