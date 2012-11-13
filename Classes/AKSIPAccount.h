//
//  AKSIPAccount.h
//  Telephone
//
//  Copyright (c) 2008-2012 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>


// SIP account defaults.
extern const NSInteger kAKSIPAccountDefaultSIPProxyPort;
extern const NSInteger kAKSIPAccountDefaultReregistrationTime;

// Notifications.
//
// Posted when account registration changes.
extern NSString * const AKSIPAccountRegistrationDidChangeNotification;
//
// Posted when account is about to make call.
extern NSString * const AKSIPAccountWillMakeCallNotification;

@class AKSIPCall;

// Declares interface that AKSIPAccount delegate must implement.
@protocol AKSIPAccountDelegate
@optional
// Sent when AKSIPAccount receives an incoming call.
- (void)SIPAccountDidReceiveCall:(AKSIPCall *)aCall;
@end

@class AKSIPURI;

// A class representing a SIP account. It contains a list of calls and maintains
// SIP registration. You can use this class to make and receive calls.
@interface AKSIPAccount : NSObject {
 @private
  NSObject <AKSIPAccountDelegate> *delegate_;
  
  AKSIPURI *registrationURI_;
  
  NSString *fullName_;
  NSString *SIPAddress_;
  NSString *registrar_;
  NSString *realm_;
  NSString *username_;
  NSString *proxyHost_;
  NSUInteger proxyPort_;
  BOOL inbandDTMF_;
  NSUInteger reregistrationTime_;
  
  NSInteger identifier_;
  
  NSMutableArray *calls_;
}

// The receiver's delegate.
@property (nonatomic, assign) NSObject <AKSIPAccountDelegate> *delegate;

// The URI for SIP registration.
// It is composed of |fullName| and |SIPAddress|,
// e.g. "John Smith" <john@company.com>
// TODO(eofster): strange property. Do we need this?
@property (nonatomic, copy) AKSIPURI *registrationURI;

// Full name of the registration URI.
@property (nonatomic, copy) NSString *fullName;

// SIP address of the registration URI.
@property (nonatomic, copy) NSString *SIPAddress;

// Registrar.
@property (nonatomic, copy) NSString *registrar;

// Realm. Pass nil to make a credential that can be used to authenticate against
// any challenges.
@property (nonatomic, copy) NSString *realm;

// Authentication user name.
@property (nonatomic, copy) NSString *username;

// SIP proxy host.
@property (nonatomic, copy) NSString *proxyHost;

// Network port to use with the SIP proxy.
// Default: 5060.
@property (nonatomic, assign) NSUInteger proxyPort;

// If YES: Send DTMF inband. If NO: send RFC2833 DTMF, and fallback INFO DTMF
// Default: NO
@property (nonatomic, assign) BOOL inbandDTMF;

// SIP re-registration time.
// Default: 300 (sec).
@property (nonatomic, assign) NSUInteger reregistrationTime;

// The receiver's identifier at the user agent.
@property (nonatomic, assign) NSInteger identifier;

// A Boolean value indicating whether the receiver is registered.
@property (nonatomic, assign, getter=isRegistered) BOOL registered;

// The receiver's SIP registration status code.
@property (nonatomic, readonly, assign) NSInteger registrationStatus;

// The receiver's SIP registration status text.
@property (nonatomic, readonly, copy) NSString *registrationStatusText;

// An up to date expiration interval for the receiver's registration session.
@property (nonatomic, readonly, assign) NSInteger registrationExpireTime;

// A Boolean value indicating whether the receiver is online in terms of SIP
// presence.
@property (nonatomic, assign, getter=isOnline) BOOL online;

// Presence online status text.
@property (nonatomic, readonly, copy) NSString *onlineStatusText;

// Calls that belong to the receiver.
@property (readonly, retain) NSMutableArray *calls;

// Creates and returns an AKSIPAccount object initialized with a given full
// name, SIP address, registrar, realm, and user name.
+ (id)SIPAccountWithFullName:(NSString *)aFullName
                  SIPAddress:(NSString *)aSIPAddress
                   registrar:(NSString *)aRegistrar
                       realm:(NSString *)aRealm
                    username:(NSString *)aUsername;

// Designated initializer.
// Initializes an AKSIPAccount object with a given full name, SIP address,
// registrar, realm, and user name.
- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername;

// Makes a call to a given destination URI.
- (AKSIPCall *)makeCallTo:(AKSIPURI *)destinationURI;

@end
