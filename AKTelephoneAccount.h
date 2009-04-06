//
//  AKTelephoneAccount.h
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>


extern NSString * const kAKDefaultSIPProxyHost;
extern const NSInteger kAKDefaultSIPProxyPort;
extern const NSInteger kAKDefaultAccountReregistrationTime;

@class AKTelephoneCall, AKSIPURI;
@protocol AKTelephoneAccountDelegate;

@interface AKTelephoneAccount : NSObject {
 @private
  NSObject <AKTelephoneAccountDelegate> *delegate_;
  
  AKSIPURI *registrationURI_;
  
  NSString *fullName_;
  NSString *SIPAddress_;
  NSString *registrar_;
  NSString *realm_;
  NSString *username_;
  NSString *proxyHost_;
  NSUInteger proxyPort_;
  NSUInteger reregistrationTime_;
  
  NSInteger identifier_;
  
  NSMutableArray *calls_;
}

@property(nonatomic, assign) NSObject <AKTelephoneAccountDelegate> *delegate;
@property(nonatomic, copy) AKSIPURI *registrationURI;
@property(nonatomic, copy) NSString *fullName;
@property(nonatomic, copy) NSString *SIPAddress;
@property(nonatomic, copy) NSString *registrar;
@property(nonatomic, copy) NSString *realm;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *proxyHost;     // Default: @"".
@property(nonatomic, assign) NSUInteger proxyPort;  // Default: 5060.
@property(nonatomic, assign) NSUInteger reregistrationTime;  // Default: 300 (sec).
@property(nonatomic, assign) NSInteger identifier;
@property(nonatomic, assign, getter=isRegistered) BOOL registered;
@property(nonatomic, readonly, assign) NSInteger registrationStatus;
@property(nonatomic, readonly, copy) NSString *registrationStatusText;
@property(nonatomic, readonly, assign) NSInteger registrationExpireTime;
@property(nonatomic, assign, getter=isOnline) BOOL online;
@property(nonatomic, readonly, copy) NSString *onlineStatusText;
@property(readonly, retain) NSMutableArray *calls;

+ (id)telephoneAccountWithFullName:(NSString *)aFullName
                        SIPAddress:(NSString *)aSIPAddress
                         registrar:(NSString *)aRegistrar
                             realm:(NSString *)aRealm
                          username:(NSString *)aUsername;

- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername;

- (AKTelephoneCall *)makeCallTo:(AKSIPURI *)destinationURI;

@end


// Callback from PJSUA
void AKTelephoneAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier);


@protocol AKTelephoneAccountDelegate

@optional
- (void)telephoneAccountDidReceiveCall:(AKTelephoneCall *)aCall;

@end


// Notifications.
extern NSString * const AKTelephoneAccountRegistrationDidChangeNotification;
extern NSString * const AKTelephoneAccountWillRemoveNotification;
