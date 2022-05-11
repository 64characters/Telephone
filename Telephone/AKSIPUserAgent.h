//
//  AKSIPUserAgent.h
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

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

#import "AKSIPUserAgentDelegate.h"
#import "AKSIPUserAgentNotifications.h"


// User agent states.
typedef NS_ENUM(NSInteger, AKSIPUserAgentState) {
    AKSIPUserAgentStateStopped,
    AKSIPUserAgentStateStarting,
    AKSIPUserAgentStateStarted,
    AKSIPUserAgentStateStopping
};

// NAT types, as specified by RFC 3489.
typedef NS_ENUM(NSUInteger, AKNATType) {
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

typedef struct _AKSIPUserAgentCallData {
    pj_timer_entry timer;
    pj_bool_t ringbackOn;
    pj_bool_t ringbackOff;
} AKSIPUserAgentCallData;

// An invalid identifier for all sorts of identifiers.
extern const NSInteger kAKSIPUserAgentInvalidIdentifier;

@class AKSIPAccount, AKSIPCall, AKSIPURIParser;

// The AKSIPUserAgent class implements SIP User Agent functionality. You can use it to create, configure, and start user
// agent, add and remove accounts, and set sound devices for input and output. You need to restart the user agent after
// you change its properties when it is already running.
@interface AKSIPUserAgent : NSObject {
  @private
    AKSIPUserAgentCallData _callData[PJSUA_MAX_CALLS];
    pj_thread_desc _descriptor;
}

// The receiver's delegate.
@property(nonatomic, weak) id <AKSIPUserAgentDelegate> delegate;

// A Boolean value indicating whether the receiver has been started.
@property(nonatomic, readonly, assign, getter=isStarted) BOOL started;

// Receiver's state.
@property(readonly, assign) AKSIPUserAgentState state;

// NAT type that has been detected by the receiver.
@property(nonatomic, assign) AKNATType detectedNATType;

// The number of acitve calls controlled by the receiver.
@property(nonatomic, readonly, assign) NSInteger activeCallsCount;

@property(nonatomic, readonly) BOOL hasUnansweredIncomingCalls;

// Receiver's call data.
@property(nonatomic, readonly, assign) AKSIPUserAgentCallData *callData;

@property(nonatomic, assign) NSInteger maxCalls;

// An array of DNS servers to use by the receiver. If set, DNS SRV will be
// enabled. Only first kAKSIPUserAgentNameServersMax are used.
@property(nonatomic, copy) NSArray *nameServers;

// SIP proxy host to visit for all outgoing requests. Will be used for all
// accounts. The final route set for outgoing requests consists of this proxy
// and proxy configured for the account.
@property(nonatomic, copy) NSString *outboundProxyHost;

// Network port to use with the outbound proxy.
// Default: 5060.
@property(nonatomic, assign) NSUInteger outboundProxyPort;

// STUN server host.
@property(nonatomic, copy) NSString *STUNServerHost;

// Network port to use with the STUN server.
// Default: 3478.
@property(nonatomic, assign) NSUInteger STUNServerPort;

// User agent string.
@property(nonatomic, copy) NSString *userAgentString;

// Path to the log file.
@property(nonatomic, copy) NSString *logFileName;

// Verbosity level.
// Default: 3.
@property(nonatomic, assign) NSUInteger logLevel;

// Verbosity leverl for console.
// Default: 0.
@property(nonatomic, assign) NSUInteger consoleLogLevel;

// A Boolean value indicating whether Voice Activity Detection is used.
// Default: YES.
@property(nonatomic, assign) BOOL detectsVoiceActivity;

// A Boolean value indicating whether Interactive Connectivity Establishment
// is used.
// Default: NO.
@property(nonatomic, assign) BOOL usesICE;

/// A Boolean value indicating if QoS is used.
/// Default: YES.
@property(nonatomic, assign) BOOL usesQoS;

// Network port to use for SIP transport. Set 0 for any available port.
// Default: 0.
@property(nonatomic, assign) NSUInteger transportPort;


/// A Boolean value indicating if only G.711 codec is used.
@property(nonatomic, assign) BOOL usesG711Only;

/// A Boolean value indicating if a codec should be locked.
///
/// If remote sends SDP answer containing more than one format or codec in
/// the media line, send re-INVITE or UPDATE with just one codec to lock
/// which codec to use.
///
/// Default: YES.
@property(nonatomic, assign) BOOL locksCodec;

@property(nonatomic, readonly) AKSIPURIParser *parser;

// Returns the shared SIP user agent object.
+ (AKSIPUserAgent *)sharedUserAgent;

// Designated initializer. Initializes a SIP user agent and sets its delegate.
- (instancetype)initWithDelegate:(id<AKSIPUserAgentDelegate>)aDelegate;

// Starts user agent.
- (void)start;

// Stops user agent.
- (void)stop;
- (void)stopAndWait;

// Adds an account to the user agent.
- (BOOL)addAccount:(AKSIPAccount *)anAccount withPassword:(NSString *)aPassword;

// Removes an account from the user agent.
- (BOOL)removeAccount:(AKSIPAccount *)account;

// Returns a SIP account with a given identifier.
- (AKSIPAccount *)accountWithIdentifier:(NSInteger)identifier;

// Returns a SIP call with a given identifier.
- (AKSIPCall *)callWithIdentifier:(NSInteger)identifier;

// Hangs up all calls controlled by the receiver.
- (void)hangUpAllCalls;

// Starts local ringback sound for the specified call.
- (void)startRingbackForCall:(AKSIPCall *)call;

// Stops local ringback sound for the specified call.
- (void)stopRingbackForCall:(AKSIPCall *)call;

// Sets sound input and output.
- (BOOL)setSoundInputDevice:(NSInteger)input soundOutputDevice:(NSInteger)output;

// Stops sound.
- (BOOL)stopSound;

// Updates list of audio devices.
// You might want to call this method when system audio devices are changed. After calling this method,
// |setSoundInputDevice:soundOutputDevice:| must be called to set appropriate sound IO.
- (void)updateAudioDevices;

// Returns a string that describes given SIP response code from RFC 3261.
- (NSString *)stringForSIPResponseCode:(NSInteger)responseCode;

@end
