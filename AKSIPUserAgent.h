//
//  AKSIPUserAgent.h
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


enum {
  kAKSIPUserAgentStopped,
  kAKSIPUserAgentStarting,
  kAKSIPUserAgentStarted
};
typedef NSUInteger AKSIPUserAgentState;

enum {
  kAKNATTypeUnknown        = PJ_STUN_NAT_TYPE_UNKNOWN,
  kAKNATTypeErrorUnknown   = PJ_STUN_NAT_TYPE_ERR_UNKNOWN,
  kAKNATTypeOpen           = PJ_STUN_NAT_TYPE_OPEN,
  kAKNATTypeBlocked        = PJ_STUN_NAT_TYPE_BLOCKED,
  kAKNATTypeSymmetricUDP   = PJ_STUN_NAT_TYPE_SYMMETRIC_UDP,
  kAKNATTypeFullCone       = PJ_STUN_NAT_TYPE_FULL_CONE,
  kAKNATTypeSymmetric      = PJ_STUN_NAT_TYPE_SYMMETRIC,
  kAKNATTypeRestricted     = PJ_STUN_NAT_TYPE_RESTRICTED,
  kAKNATTypePortRestricted = PJ_STUN_NAT_TYPE_PORT_RESTRICTED
};
typedef NSUInteger AKNATType;

typedef struct _AKSIPUserAgentCallData {
  pj_timer_entry timer;
  pj_bool_t ringbackOn;
  pj_bool_t ringbackOff;
} AKSIPUserAgentCallData;

extern const NSInteger kAKSIPUserAgentInvalidIdentifier;
extern const NSInteger kAKSIPUserAgentNameserversMax;

// User agent defaults.
extern NSString * const kAKSIPUserAgentDefaultOutboundProxyHost;
extern const NSInteger kAKSIPUserAgentDefaultOutboundProxyPort;
extern NSString * const kAKSIPUserAgentDefaultSTUNServerHost;
extern const NSInteger kAKSIPUserAgentDefaultSTUNServerPort;
extern NSString * const kAKSIPUserAgentDefaultLogFileName;
extern const NSInteger kAKSIPUserAgentDefaultLogLevel;
extern const NSInteger kAKSIPUserAgentDefaultConsoleLogLevel;
extern const BOOL kAKSIPUserAgentDefaultDetectsVoiceActivity;
extern const BOOL kAKSIPUserAgentDefaultUsesICE;
extern const NSInteger kAKSIPUserAgentDefaultTransportPort;
extern NSString * const kAKSIPUserAgentDefaultTransportPublicHost;

// Notifications.
extern NSString * const AKSIPUserAgentDidFinishStartingNotification;
extern NSString * const AKSIPUserAgentDidFinishStoppingNotification;
extern NSString * const AKSIPUserAgentDidDetectNATNotification;

// Callback from PJSUA.
void AKSIPUserAgentDetectedNAT(const pj_stun_nat_detect_result *result);

@class AKSIPAccount;

@protocol AKSIPUserAgentDelegate <NSObject>
@optional
- (BOOL)SIPUserAgentShouldAddAccount:(AKSIPAccount *)anAccount;
@end

@class AKSIPCall;

@interface AKSIPUserAgent : NSObject {
 @private
  id <AKSIPUserAgentDelegate> delegate_;
  
  NSMutableArray *accounts_;
  AKSIPUserAgentState state_;
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
  NSString *transportPublicHost_;
  
  // PJSUA config
  AKSIPUserAgentCallData callData_[PJSUA_MAX_CALLS];
  pj_pool_t *pjPool_;
  NSInteger ringbackSlot_;
  NSInteger ringbackCount_;
  pjmedia_port *ringbackPort_;
}

@property(nonatomic, assign) id <AKSIPUserAgentDelegate> delegate;
@property(readonly, retain) NSMutableArray *accounts;
@property(nonatomic, readonly, assign, getter=isStarted) BOOL started;
@property(readonly, assign) AKSIPUserAgentState state;
@property(assign) AKNATType detectedNATType;
@property(retain) NSLock *pjsuaLock;
@property(nonatomic, readonly, assign) NSUInteger activeCallsCount;
@property(nonatomic, readonly, assign) AKSIPUserAgentCallData *callData;
@property(readonly, assign) pj_pool_t *pjPool;
@property(readonly, assign) NSInteger ringbackSlot;
@property(nonatomic, assign) NSInteger ringbackCount;
@property(readonly, assign) pjmedia_port *ringbackPort;

@property(nonatomic, copy) NSArray *nameservers;         // Default: nil. If set, DNS SRV will be enabled. Only first kAKSIPUserAgentNameserversMax are used.
@property(nonatomic, copy) NSString *outboundProxyHost;  // Default: @"".
@property(nonatomic, assign) NSUInteger outboundProxyPort;  // Default: 5060.
@property(nonatomic, copy) NSString *STUNServerHost;     // Default: @"".
@property(nonatomic, assign) NSUInteger STUNServerPort;  // Default: 3478.
@property(nonatomic, copy) NSString *userAgentString;    // Default: @"".
@property(nonatomic, copy) NSString *logFileName;        // Default: nil.
@property(nonatomic, assign) NSUInteger logLevel;        // Default: 3.
@property(nonatomic, assign) NSUInteger consoleLogLevel; // Default: 0.
@property(nonatomic, assign) BOOL detectsVoiceActivity;  // Default: YES.
@property(nonatomic, assign) BOOL usesICE;               // Default: NO.
@property(nonatomic, assign) NSUInteger transportPort;   // Default: 0 for any available port.
@property(nonatomic, copy) NSString *transportPublicHost;  // Default: nil.

+ (AKSIPUserAgent *)sharedUserAgent;

// Designated initializer
- (id)initWithDelegate:(id)aDelegate;

// Start SIP user agent.
- (void)start;

// Stop SIP user agent.
- (void)stop;

// Dealing with accounts
- (BOOL)addAccount:(AKSIPAccount *)anAccount withPassword:(NSString *)aPassword;
- (BOOL)removeAccount:(AKSIPAccount *)account;
- (AKSIPAccount *)accountByIdentifier:(NSInteger)anIdentifier;

// Dealing with calls
- (AKSIPCall *)SIPCallByIdentifier:(NSInteger)anIdentifier;
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
