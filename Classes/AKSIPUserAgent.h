//
//  AKSIPUserAgent.h
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


// User agent states.
enum {
    kAKSIPUserAgentStopped,
    kAKSIPUserAgentStarting,
    kAKSIPUserAgentStarted
};
typedef NSUInteger AKSIPUserAgentState;

// NAT types, as specified by RFC 3489.
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

// An invalid identifier for all sorts of identifiers.
extern const NSInteger kAKSIPUserAgentInvalidIdentifier;

// Notifications.
//
// All AKSIPUserAgent notifications are posted by the user agent instance returned by |sharedUserAgent|.
//
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
//
// Posted when the user agent is about to remove an account.
extern NSString * const AKSIPUserAgentWillRemoveAccountNotification;

@class AKSIPAccount;

// Declares the interface that AKSIPUserAgent delegates must implement.
@protocol AKSIPUserAgentDelegate <NSObject>
@optional
// Sent when AKSIPUserAgent is about to add an account. It is a good moment to
// start user agent lazily, when the first account is added.
- (BOOL)SIPUserAgentShouldAddAccount:(AKSIPAccount *)anAccount;
@end

@class AKSIPCall;

// The AKSIPUserAgent class implements SIP User Agent functionality. You can use it to create, configure, and start user
// agent, add and remove accounts, and set sound devices for input and output. You need to restart the user agent after
// you change its properties when it is already running.
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
    
    AKSIPUserAgentCallData callData_[PJSUA_MAX_CALLS];
    pj_pool_t *pjPool_;
    NSInteger ringbackSlot_;
    NSInteger ringbackCount_;
    pjmedia_port *ringbackPort_;
}

// The receiver's delegate.
@property (nonatomic, assign) id <AKSIPUserAgentDelegate> delegate;

// Accounts added to the receiver.
@property (readonly, retain) NSMutableArray *accounts;

// A Boolean value indicating whether the receiver has been started.
@property (nonatomic, readonly, assign, getter=isStarted) BOOL started;

// Receiver's state.
@property (readonly, assign) AKSIPUserAgentState state;

// NAT type that has been detected by the receiver.
@property (assign) AKNATType detectedNATType;

// A lock that is used to start and stop the receiver.
@property (retain) NSLock *pjsuaLock;

// The number of acitve calls controlled by the receiver.
@property (nonatomic, readonly, assign) NSUInteger activeCallsCount;

// Receiver's call data.
@property (nonatomic, readonly, assign) AKSIPUserAgentCallData *callData;

// A pool used by the underlying PJSUA library of the receiver.
@property (readonly, assign) pj_pool_t *pjPool;

@property (readonly, assign) NSInteger ringbackSlot;
@property (nonatomic, assign) NSInteger ringbackCount;
@property (readonly, assign) pjmedia_port *ringbackPort;

// An array of DNS servers to use by the receiver. If set, DNS SRV will be
// enabled. Only first kAKSIPUserAgentNameserversMax are used.
@property (nonatomic, copy) NSArray *nameservers;

// SIP proxy host to visit for all outgoing requests. Will be used for all
// accounts. The final route set for outgoing requests consists of this proxy
// and proxy configured for the account.
@property (nonatomic, copy) NSString *outboundProxyHost;

// Network port to use with the outbound proxy.
// Default: 5060.
@property (nonatomic, assign) NSUInteger outboundProxyPort;

// STUN server host.
@property (nonatomic, copy) NSString *STUNServerHost;

// Network port to use with the STUN server.
// Default: 3478.
@property (nonatomic, assign) NSUInteger STUNServerPort;

// User agent string.
@property (nonatomic, copy) NSString *userAgentString;

// Path to the log file.
@property (nonatomic, copy) NSString *logFileName;

// Verbosity level.
// Default: 3.
@property (nonatomic, assign) NSUInteger logLevel;

// Verbosity leverl for console.
// Default: 0.
@property (nonatomic, assign) NSUInteger consoleLogLevel;

// A Boolean value indicating whether Voice Activity Detection is used.
// Default: YES.
@property (nonatomic, assign) BOOL detectsVoiceActivity;

// A Boolean value indicating whether Interactive Connectivity Establishment
// is used.
// Default: NO.
@property (nonatomic, assign) BOOL usesICE;

// Network port to use for SIP transport. Set 0 for any available port.
// Default: 0.
@property (nonatomic, assign) NSUInteger transportPort;

// Host name or IP address to advertise as the address of SIP transport.
@property (nonatomic, copy) NSString *transportPublicHost;


// Returns the shared SIP user agent object.
+ (AKSIPUserAgent *)sharedUserAgent;

// Designated initializer. Initializes a SIP user agent and sets its delegate.
- (id)initWithDelegate:(id)aDelegate;

// Starts user agent.
- (void)start;

// Stops user agent.
- (void)stop;

// Adds an account to the user agent.
- (BOOL)addAccount:(AKSIPAccount *)anAccount withPassword:(NSString *)aPassword;

// Removes an account from the user agent.
- (BOOL)removeAccount:(AKSIPAccount *)account;

// Returns a SIP account with a given identifier.
- (AKSIPAccount *)accountByIdentifier:(NSInteger)anIdentifier;

// Returns a SIP call with a given identifier.
- (AKSIPCall *)SIPCallByIdentifier:(NSInteger)anIdentifier;

// Hangs up all calls controlled by the receiver.
- (void)hangUpAllCalls;

// Sets sound input and output.
- (BOOL)setSoundInputDevice:(NSInteger)input
          soundOutputDevice:(NSInteger)output;

// Stops sound.
- (BOOL)stopSound;

// Updates list of audio devices.
// You might want to call this method when system audio devices are changed. After calling this method,
// |setSoundInputDevice:soundOutputDevice:| must be called to set appropriate sound IO.
- (void)updateAudioDevices;

// Returns a string that describes given SIP response code from RFC 3261.
- (NSString *)stringForSIPResponseCode:(NSInteger)responseCode;

@end
