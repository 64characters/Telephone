//
//  AKTelephoneAccount.m
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

#import "AKTelephoneAccount.h"

#import "AKNSString+PJSUA.h"
#import "AKSIPURI.h"
#import "AKTelephone.h"
#import "AKTelephoneCall.h"


NSString * const AKTelephoneAccountRegistrationDidChangeNotification
  = @"AKTelephoneAccountRegistrationDidChange";
NSString * const AKTelephoneAccountWillRemoveNotification
  = @"AKTelephoneAccountWillRemove";

NSString * const kAKDefaultSIPProxyHost = @"";
const NSInteger kAKDefaultSIPProxyPort = 5060;
const NSInteger kAKDefaultAccountReregistrationTime = 300;

@implementation AKTelephoneAccount

@dynamic delegate;
@synthesize registrationURI = registrationURI_;
@synthesize fullName = fullName_;
@synthesize SIPAddress = SIPAddress_;
@synthesize registrar = registrar_;
@synthesize realm = realm_;
@synthesize username = username_;
@synthesize proxyHost = proxyHost_;
@dynamic proxyPort;
@dynamic reregistrationTime;
@synthesize identifier = identifier_;
@dynamic registered;
@dynamic registrationStatus;
@dynamic registrationStatusText;
@dynamic registrationExpireTime;
@dynamic online;
@dynamic onlineStatusText;
@synthesize calls = calls_;

- (NSObject <AKTelephoneAccountDelegate> *)delegate
{
  return delegate_;
}

- (void)setDelegate:(NSObject <AKTelephoneAccountDelegate> *)aDelegate
{
  if (delegate_ == aDelegate)
    return;
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  if (delegate_ != nil)
    [notificationCenter removeObserver:delegate_ name:nil object:self];
  
  if (aDelegate != nil) {
    if ([aDelegate respondsToSelector:@selector(telephoneAccountRegistrationDidChange:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(telephoneAccountRegistrationDidChange:)
                                 name:AKTelephoneAccountRegistrationDidChangeNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(telephoneAccountWillRemove:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(telephoneAccountWillRemove:)
                                 name:AKTelephoneAccountWillRemoveNotification
                               object:self];
  }
  
  delegate_ = aDelegate;
}

- (NSUInteger)proxyPort
{
  return proxyPort_;
}

- (void)setProxyPort:(NSUInteger)port
{
  if (port > 0 && port < 65535)
    proxyPort_ = port;
  else
    proxyPort_ = kAKDefaultSIPProxyPort;
}

- (NSUInteger)reregistrationTime
{
  return reregistrationTime_;
}

- (void)setReregistrationTime:(NSUInteger)seconds
{
  if (seconds == 0)
    reregistrationTime_ = kAKDefaultAccountReregistrationTime;
  else if (seconds < 60)
    reregistrationTime_ = 60;
  else if (seconds > 3600)
    reregistrationTime_ = 3600;
  else
    reregistrationTime_ = seconds;
}

- (BOOL)isRegistered
{
  return ([self registrationStatus] / 100 == 2) && ([self registrationExpireTime] > 0);
}

- (void)setRegistered:(BOOL)value
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return;
  
  if (value) {
    pjsua_acc_set_registration([self identifier], PJ_TRUE);
    [self setOnline:YES];
  } else {
    [self setOnline:NO];
    pjsua_acc_set_registration([self identifier], PJ_FALSE);
  }
}

- (NSInteger)registrationStatus
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return 0;
  
  pjsua_acc_info accountInfo;
  pj_status_t status;
  
  status = pjsua_acc_get_info([self identifier], &accountInfo);
  if (status != PJ_SUCCESS)
    return 0;
  
  return accountInfo.status;
}

- (NSString *)registrationStatusText
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return nil;
  
  pjsua_acc_info accountInfo;
  pj_status_t status;
  
  status = pjsua_acc_get_info([self identifier], &accountInfo);
  if (status != PJ_SUCCESS)
    return nil;
  
  return [NSString stringWithPJString:accountInfo.status_text];
}

- (NSInteger)registrationExpireTime
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return -1;
  
  pjsua_acc_info accountInfo;
  pj_status_t status;
  
  status = pjsua_acc_get_info([self identifier], &accountInfo);
  if (status != PJ_SUCCESS)
    return -1;
  
  return accountInfo.expires;
}

- (BOOL)isOnline
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return NO;
  
  pjsua_acc_info accountInfo;
  pj_status_t status;
  
  status = pjsua_acc_get_info([self identifier], &accountInfo);
  if (status != PJ_SUCCESS)
    return NO;
  
  return (accountInfo.online_status == PJ_TRUE) ? YES : NO;
}

- (void)setOnline:(BOOL)value
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return;
  
  if (value)
    pjsua_acc_set_online_status([self identifier], PJ_TRUE);
  else
    pjsua_acc_set_online_status([self identifier], PJ_FALSE);
}

- (NSString *)onlineStatusText
{
  if ([self identifier] == kAKTelephoneInvalidIdentifier)
    return nil;
  
  pjsua_acc_info accountInfo;
  pj_status_t status;
  
  status = pjsua_acc_get_info([self identifier], &accountInfo);
  if (status != PJ_SUCCESS)
    return nil;
  
  return [NSString stringWithPJString:accountInfo.online_status_text];
}

+ (id)telephoneAccountWithFullName:(NSString *)aFullName
                        SIPAddress:(NSString *)aSIPAddress
                         registrar:(NSString *)aRegistrar
                             realm:(NSString *)aRealm
                          username:(NSString *)aUsername
{
  return [[[AKTelephoneAccount alloc] initWithFullName:aFullName
                                            SIPAddress:aSIPAddress
                                             registrar:aRegistrar
                                                 realm:aRealm
                                              username:aUsername]
          autorelease];
}

- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername
{
  self = [super init];
  if (self == nil)
    return nil;
  
  [self setRegistrationURI:[AKSIPURI SIPURIWithString:
                            [NSString stringWithFormat:@"\"%@\" <sip:%@>",
                             aFullName, aSIPAddress]]];
  
  [self setFullName:aFullName];
  [self setSIPAddress:aSIPAddress];
  [self setRegistrar:aRegistrar];
  [self setRealm:aRealm];
  [self setUsername:aUsername];
  [self setProxyHost:kAKDefaultSIPProxyHost];
  [self setProxyPort:kAKDefaultSIPProxyPort];
  [self setReregistrationTime:kAKDefaultAccountReregistrationTime];
  [self setIdentifier:kAKTelephoneInvalidIdentifier];
  
  calls_ = [[NSMutableArray alloc] init];
  
  return self;
}

- (id)init
{
  return [self initWithFullName:nil
                     SIPAddress:nil
                      registrar:nil
                          realm:nil
                       username:nil];
}

- (void)dealloc
{
  [self setDelegate:nil];
  
  [registrationURI_ release];
  
  [fullName_ release];
  [SIPAddress_ release];
  [registrar_ release];
  [realm_ release];
  [username_ release];
  [proxyHost_ release];
  
  [calls_ release];
  
  [super dealloc];
}

- (NSString *)description
{
  return [self SIPAddress];
}

// Make outgoing call, create call object, set its info, add to the array
- (AKTelephoneCall *)makeCallTo:(AKSIPURI *)destinationURI
{
  pjsua_call_id callIdentifier;
  pj_str_t uri = [[destinationURI description] pjString];
  
  pj_status_t status = pjsua_call_make_call([self identifier], &uri, 0, NULL,
                                            NULL, &callIdentifier);
  if (status != PJ_SUCCESS) {
    NSLog(@"Error making call to %@ via account %@", destinationURI, self);
    return nil;
  }
  
  // AKTelephoneCall object is created here when the call is outgoing
  AKTelephoneCall *theCall
    = [[AKTelephoneCall alloc] initWithTelephoneAccount:self
                                             identifier:callIdentifier];
  
  // Keep this call in the calls array for this account
  [[self calls] addObject:theCall];
  
  return [theCall autorelease];
}

@end


#pragma mark -
#pragma mark Callbacks

void AKTelephoneAccountRegistrationStateChanged(pjsua_acc_id accountIdentifier)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  AKTelephoneAccount *anAccount = [[AKTelephone sharedTelephone]
                                   accountByIdentifier:accountIdentifier];
  
  NSNotification *notification
    = [NSNotification
       notificationWithName:AKTelephoneAccountRegistrationDidChangeNotification
                     object:anAccount];
  
  [[NSNotificationCenter defaultCenter]
   performSelectorOnMainThread:@selector(postNotification:)
                    withObject:notification
                 waitUntilDone:NO];
  [pool release];
}
