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

extern NSInteger AKTelephoneInvalidIdentifier;

extern NSString *AKSoundDeviceName;
extern NSString *AKSoundDeviceInputCount;
extern NSString *AKSoundDeviceOutputCount;
extern NSString *AKSoundDeviceDefaultSamplesPerSecond;

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

	// PJSUA config
	pjsua_config userAgentConfig;
	pjsua_logging_config loggingConfig;
	pjsua_media_config mediaConfig;
	pjsua_transport_config transportConfig;
	AKTelephoneCallData callData[PJSUA_MAX_CALLS];
	pj_pool_t *pjPool;
	NSInteger ringbackSlot;
	NSInteger ringbackCount;
	pjmedia_port *ringbackPort;
}

@property(nonatomic, readwrite, assign) id delegate;
@property(nonatomic, readonly, retain) NSMutableArray *accounts;
@property(nonatomic, readonly, assign) BOOL started;
@property(nonatomic, readonly, retain) NSArray *soundDevices;
@property(nonatomic, readonly, assign) AKTelephoneCallData *callData;
@property(nonatomic, readonly, assign) pj_pool_t *pjPool;
@property(nonatomic, readonly, assign) NSInteger ringbackSlot;
@property(nonatomic, readwrite, assign) NSInteger ringbackCount;
@property(nonatomic, readonly, assign) pjmedia_port *ringbackPort;

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

// Set new input and output sound devices.
// If NSNotFound or -1 is passed as either parameter, first matched device will be used.
- (BOOL)setSoundInputDevice:(NSInteger)input soundOutputDevice:(NSInteger)output;

// Update list of sound devices. Posts AKTelephoneDidUpdateSoundDevicesNotification.
// After calling this method, setSoundInputDevice:soundOutputDevice: must be called to set appropriate IO.
- (void)updateSoundDevices;

@end


// Callback from PJSUA
void AKTelephoneDetectedNAT(const pj_stun_nat_detect_result *result);


@interface NSObject(AKTelephoneDelegate)
- (BOOL)telephoneShouldAddAccount:(AKTelephoneAccount *)anAccount;
@end

@interface NSObject(AKTelephoneNotifications)
- (void)telephoneDidDetectNAT:(NSNotification *)notification;
- (void)telephoneDidUpdateSoundDevices:(NSNotification *)notification;
@end

// Notifications
extern NSString *AKTelephoneDidDetectNATNotification;
extern NSString *AKTelephoneDidUpdateSoundDevicesNotification;
