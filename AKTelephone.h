//
//  AKTelephone.h
//  Telephone
//
//  Copyright (c) 2008 Alexei Kuznetsov. All rights reserved.
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


@class AKTelephoneAccount, AKTelephoneCall;

extern const NSInteger AKTelephoneInvalidIdentifier;

typedef struct _AKTelephoneCallData {
	pj_timer_entry timer;
	pj_bool_t ringbackOn;
	pj_bool_t ringbackOff;
} AKTelephoneCallData;

@interface AKTelephone : NSObject {
@private
	id delegate;
	
	NSMutableArray *accounts;
	BOOL started;
	
	NSString *STUNServerHost;
	NSUInteger STUNServerPort;
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

@property(readwrite, assign) id delegate;
@property(readonly, retain) NSMutableArray *accounts;
@property(readonly, assign) BOOL started;
@property(readonly, assign) NSUInteger activeCallsCount;
@property(readonly, assign) AKTelephoneCallData *callData;
@property(readonly, assign) pj_pool_t *pjPool;
@property(readonly, assign) NSInteger ringbackSlot;
@property(readwrite, assign) NSInteger ringbackCount;
@property(readonly, assign) pjmedia_port *ringbackPort;

@property(readwrite, copy) NSString *STUNServerHost;		// Default: @"".
@property(readwrite, assign) NSUInteger STUNServerPort;		// Default: 3478.
@property(readwrite, copy) NSString *logFileName;			// Default: @"~/Library/Logs/Telephone.log".
@property(readwrite, assign) NSUInteger logLevel;			// Default: 3.
@property(readwrite, assign) NSUInteger consoleLogLevel;	// Default: 0.
@property(readwrite, assign) BOOL detectsVoiceActivity;		// Default: YES.
@property(readwrite, assign) NSUInteger transportPort;		// Default: 0 for any available port.


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

// Update list of audio devices.
// After calling this method, setSoundInputDevice:soundOutputDevice: must be called to set appropriate IO.
- (void)updateAudioDevices;

@end


// Callback from PJSUA
void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result);


@interface NSObject(AKTelephoneDelegate)
- (BOOL)telephoneShouldAddAccount:(AKTelephoneAccount *)anAccount;
@end

// Notifications.
extern NSString * const AKTelephoneDidDetectNATNotification;
