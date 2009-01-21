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
	// NAT type is unknown because the detection has not been performed.
	AKNATTypeUnknown		= PJ_STUN_NAT_TYPE_UNKNOWN,
	
	// NAT type is unknown because there is failure in the detection
	// process, possibly because server does not support RFC 3489.
	AKNATTypeErrorUnknown	= PJ_STUN_NAT_TYPE_ERR_UNKNOWN,
	
	// This specifies that the client has open access to Internet (or
	// at least, its behind a firewall that behaves like a full-cone NAT,
	// but without the translation)
	AKNATTypeOpen			= PJ_STUN_NAT_TYPE_OPEN,
	
    // This specifies that communication with server has failed, probably
    // because UDP packets are blocked.
	AKNATTypeBlocked		= PJ_STUN_NAT_TYPE_BLOCKED,
	
    // Firewall that allows UDP out, and responses have to come back to
    // the source of the request (like a symmetric NAT, but no translation.
	AKNATTypeSymmetricUDP	= PJ_STUN_NAT_TYPE_SYMMETRIC_UDP,
	
	// A full cone NAT is one where all requests from the same internal 
	// IP address and port are mapped to the same external IP address and
	// port.  Furthermore, any external host can send a packet to the 
	// internal host, by sending a packet to the mapped external address.
	AKNATTypeFullCone		= PJ_STUN_NAT_TYPE_FULL_CONE,
	
	// A symmetric NAT is one where all requests from the same internal 
	// IP address and port, to a specific destination IP address and port,
	// are mapped to the same external IP address and port.  If the same 
	// host sends a packet with the same source address and port, but to 
	// a different destination, a different mapping is used.  Furthermore,
	// only the external host that receives a packet can send a UDP packet
	// back to the internal host.
	AKNATTypeSymmetric		= PJ_STUN_NAT_TYPE_SYMMETRIC,
	
	// A restricted cone NAT is one where all requests from the same 
	// internal IP address and port are mapped to the same external IP 
	// address and port.  Unlike a full cone NAT, an external host (with 
	// IP address X) can send a packet to the internal host only if the 
	// internal host had previously sent a packet to IP address X.
	AKNATTypeRestricted		= PJ_STUN_NAT_TYPE_RESTRICTED,
	
	// A port restricted cone NAT is like a restricted cone NAT, but the 
	// restriction includes port numbers. Specifically, an external host 
	// can send a packet, with source IP address X and source port P, 
	// to the internal host only if the internal host had previously sent
	// a packet to IP address X and port P.
	AKNATTypePortRestricted	= PJ_STUN_NAT_TYPE_PORT_RESTRICTED
} AKNATType;

@class AKTelephoneAccount, AKTelephoneCall;
@protocol AKTelephoneDelegate;

@interface AKTelephone : NSObject {
@private
	id <AKTelephoneDelegate> delegate;
	
	NSMutableArray *accounts;
	BOOL started;
	BOOL soundStopped;
	AKNATType detectedNATType;
	
	NSString *outboundProxyHost;
	NSUInteger outboundProxyPort;
	NSString *STUNServerHost;
	NSUInteger STUNServerPort;
	NSString *userAgentString;
	NSString *logFileName;
	NSUInteger logLevel;
	NSUInteger consoleLogLevel;
	BOOL detectsVoiceActivity;
	NSUInteger transportPort;

	// PJSUA config
	AKTelephoneCallData callData[PJSUA_MAX_CALLS];
	pj_pool_t *pjPool;
	NSInteger ringbackSlot;
	NSInteger ringbackCount;
	pjmedia_port *ringbackPort;
}

@property(nonatomic, readwrite, assign) id <AKTelephoneDelegate> delegate;
@property(readonly, retain) NSMutableArray *accounts;
@property(readonly, assign) BOOL started;
@property(readonly, assign) BOOL soundStopped;
@property(readwrite, assign) AKNATType detectedNATType;
@property(nonatomic, readonly, assign) NSUInteger activeCallsCount;
@property(nonatomic, readonly, assign) AKTelephoneCallData *callData;
@property(readonly, assign) pj_pool_t *pjPool;
@property(readonly, assign) NSInteger ringbackSlot;
@property(readwrite, assign) NSInteger ringbackCount;
@property(readonly, assign) pjmedia_port *ringbackPort;

@property(readwrite, copy) NSString *outboundProxyHost;				// Default: @"".
@property(nonatomic, readwrite, assign) NSUInteger outboundProxyPort;	// Default: 5060.
@property(readwrite, copy) NSString *STUNServerHost;				// Default: @"".
@property(nonatomic, readwrite, assign) NSUInteger STUNServerPort;	// Default: 3478.
@property(readwrite, copy) NSString *userAgentString;				// Default: @"".
@property(nonatomic, readwrite, copy) NSString *logFileName;		// Default: @"~/Library/Logs/Telephone.log".
@property(readwrite, assign) NSUInteger logLevel;					// Default: 3.
@property(readwrite, assign) NSUInteger consoleLogLevel;			// Default: 0.
@property(readwrite, assign) BOOL detectsVoiceActivity;				// Default: YES.
@property(nonatomic, readwrite, assign) NSUInteger transportPort;	// Default: 0 for any available port.

+ (id)telephoneWithDelegate:(id)aDelegate;
+ (id)telephone;
+ (AKTelephone *)sharedTelephone;

// Designated initializer
- (id)initWithDelegate:(id)aDelegate;

// Start user agent.
- (BOOL)startUserAgent;

// Destroy undelying sip user agent correctly
- (BOOL)destroyUserAgent;

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
// After calling this method, setSoundInputDevice:soundOutputDevice: must be called to set appropriate IO.
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
extern NSString * const AKTelephoneDidDetectNATNotification;
