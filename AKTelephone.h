//
//  AKTelephone.h
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


extern const NSInteger AKTelephoneInvalidIdentifier;
extern const NSInteger AKTelephoneNameserversMax;

// Generic config defaults.
extern NSString * const AKTelephoneOutboundProxyHostDefault;
extern const NSInteger AKTelephoneOutboundProxyPortDefault;
extern NSString * const AKTelephoneSTUNServerHostDefault;
extern const NSInteger AKTelephoneSTUNServerPortDefault;
extern NSString * const AKTelephoneLogFileNameDefault;
extern const NSInteger AKTelephoneLogLevelDefault;
extern const NSInteger AKTelephoneConsoleLogLevelDefault;
extern const BOOL AKTelephoneDetectsVoiceActivityDefault;
extern const NSInteger AKTelephoneTransportPortDefault;

typedef struct _AKTelephoneCallData {
  pj_timer_entry timer;
  pj_bool_t ringbackOn;
  pj_bool_t ringbackOff;
} AKTelephoneCallData;

typedef enum _AKNATType {
  AKNATTypeUnknown        = PJ_STUN_NAT_TYPE_UNKNOWN,
  AKNATTypeErrorUnknown   = PJ_STUN_NAT_TYPE_ERR_UNKNOWN,
  AKNATTypeOpen           = PJ_STUN_NAT_TYPE_OPEN,
  AKNATTypeBlocked        = PJ_STUN_NAT_TYPE_BLOCKED,
  AKNATTypeSymmetricUDP   = PJ_STUN_NAT_TYPE_SYMMETRIC_UDP,
  AKNATTypeFullCone       = PJ_STUN_NAT_TYPE_FULL_CONE,
  AKNATTypeSymmetric      = PJ_STUN_NAT_TYPE_SYMMETRIC,
  AKNATTypeRestricted     = PJ_STUN_NAT_TYPE_RESTRICTED,
  AKNATTypePortRestricted = PJ_STUN_NAT_TYPE_PORT_RESTRICTED
} AKNATType;

typedef enum _AKTelephoneUserAgentState {
  AKTelephoneUserAgentStopped,
  AKTelephoneUserAgentStarting,
  AKTelephoneUserAgentStarted
} AKTelephoneUserAgentState;

@class AKTelephoneAccount, AKTelephoneCall;
@protocol AKTelephoneDelegate;

@interface AKTelephone : NSObject {
 @private
  id <AKTelephoneDelegate> delegate_;
  
  NSMutableArray *accounts_;
  AKTelephoneUserAgentState userAgentState_;
  BOOL soundStopped_;
  AKNATType detectedNATType_;
  NSLock *pjsuaLock_;
  
  NSArray *nameservers_;
  NSString *outboundProxyHost_;
  NSUInteger outboundProxyPort_;
  NSString *STUNServerHost_;
  NSUInteger STUNServerPort_;
  NSString *userAgentString_;
  NSString *logFileName_;
  NSUInteger logLevel_;
  NSUInteger consoleLogLevel_;
  BOOL detectsVoiceActivity_;
  BOOL usesICE_;
  NSUInteger transportPort_;
  
  // PJSUA config
  AKTelephoneCallData callData_[PJSUA_MAX_CALLS];
  pj_pool_t *pjPool_;
  NSInteger ringbackSlot_;
  NSInteger ringbackCount_;
  pjmedia_port *ringbackPort_;
}

@property(nonatomic, assign) id <AKTelephoneDelegate> delegate;
@property(readonly, retain) NSMutableArray *accounts;
@property(nonatomic, readonly, assign) BOOL userAgentStarted;
@property(readonly, assign) AKTelephoneUserAgentState userAgentState;
@property(nonatomic, readonly, assign) BOOL soundStopped;
@property(assign) AKNATType detectedNATType;
@property(retain) NSLock *pjsuaLock;
@property(nonatomic, readonly, assign) NSUInteger activeCallsCount;
@property(nonatomic, readonly, assign) AKTelephoneCallData *callData;
@property(readonly, assign) pj_pool_t *pjPool;
@property(readonly, assign) NSInteger ringbackSlot;
@property(nonatomic, assign) NSInteger ringbackCount;
@property(readonly, assign) pjmedia_port *ringbackPort;

@property(nonatomic, copy) NSArray *nameservers;         // Default: nil. If set, DNS SRV will be enabled. Only first AKTelephoneNameserversMax are used.
@property(nonatomic, copy) NSString *outboundProxyHost;  // Default: @"".
@property(nonatomic, assign) NSUInteger outboundProxyPort;  // Default: 5060.
@property(nonatomic, copy) NSString *STUNServerHost;     // Default: @"".
@property(nonatomic, assign) NSUInteger STUNServerPort;  // Default: 3478.
@property(nonatomic, copy) NSString *userAgentString;    // Default: @"".
@property(nonatomic, copy) NSString *logFileName;        // Default: @"~/Library/Logs/Telephone.log".
@property(nonatomic, assign) NSUInteger logLevel;        // Default: 3.
@property(nonatomic, assign) NSUInteger consoleLogLevel; // Default: 0.
@property(nonatomic, assign) BOOL detectsVoiceActivity;  // Default: YES.
@property(nonatomic, assign) BOOL usesICE;               // Default: NO.
@property(nonatomic, assign) NSUInteger transportPort;   // Default: 0 for any available port.

+ (AKTelephone *)sharedTelephone;

// Designated initializer
- (id)initWithDelegate:(id)aDelegate;

// Start SIP user agent.
- (void)startUserAgent;

// Stop SIP user agent.
- (void)stopUserAgent;

// Dealing with accounts
- (BOOL)addAccount:(AKTelephoneAccount *)anAccount withPassword:(NSString *)aPassword;
- (BOOL)removeAccount:(AKTelephoneAccount *)account;
- (AKTelephoneAccount *)accountByIdentifier:(NSInteger)anIdentifier;

// Dealing with calls
- (AKTelephoneCall *)telephoneCallByIdentifier:(NSInteger)anIdentifier;
- (void)hangUpAllCalls;

// Set new sound IO.
- (BOOL)setSoundInputDevice:(NSInteger)input soundOutputDevice:(NSInteger)output;
- (BOOL)stopSound;

// Update list of audio devices.
// After calling this method, setSoundInputDevice:soundOutputDevice: must be called
// to set appropriate IO.
- (void)updateAudioDevices;

- (NSString *)stringForSIPResponseCode:(NSInteger)responseCode;

@end


// Callback from PJSUA
void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result);


@protocol AKTelephoneDelegate <NSObject>

@optional
- (BOOL)telephoneShouldAddAccount:(AKTelephoneAccount *)anAccount;

@end


// Notifications.
extern NSString * const AKTelephoneUserAgentDidFinishStartingNotification;
extern NSString * const AKTelephoneUserAgentDidFinishStoppingNotification;
extern NSString * const AKTelephoneDidDetectNATNotification;
