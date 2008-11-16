//
//  AKCallController.h
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

#import <Cocoa/Cocoa.h>


@class AKAccountController, AKTelephoneCall;

@interface AKCallController : NSWindowController {
@private
	AKTelephoneCall *call;
	AKAccountController *accountController;
	NSString *status;
	NSTimeInterval callStartTime;
	NSTimer *callTimer;
	
	IBOutlet NSView *activeCallView;
	IBOutlet NSView *incomingCallView;
	IBOutlet NSView *endedCallView;
	IBOutlet NSButton *hangUpButton;
	IBOutlet NSButton *acceptCallButton;
	IBOutlet NSButton *declineCallButton;
	IBOutlet NSTextField *statusField;
	IBOutlet NSProgressIndicator *callProgressIndicator;
}

@property(nonatomic, readwrite, retain) AKTelephoneCall *call;
@property(nonatomic, readwrite, assign) AKAccountController *accountController;
@property(nonatomic, readwrite, copy) NSString *status;
@property(nonatomic, readwrite, assign) NSTimeInterval callStartTime;
@property(nonatomic, readwrite, retain) NSTimer *callTimer;

@property(nonatomic, readonly, retain) NSView *incomingCallView;
@property(nonatomic, readonly, retain) NSView *activeCallView;
@property(nonatomic, readonly, retain) NSView *endedCallView;
@property(nonatomic, readonly, retain) NSProgressIndicator *callProgressIndicator;

// Designated initializer
- (id)initWithTelephoneCall:(AKTelephoneCall *)aCall
		  accountController:(AKAccountController *)anAccountController;

- (IBAction)acceptCall:(id)sender;
- (IBAction)hangUp:(id)sender;

// Dealing with the timer of active call.
- (void)startCallTimer;
- (void)stopCallTimer;
- (void)callTimerTick:(NSTimer *)theTimer;

@end


@interface NSObject(AKCallControllerNotifications)
- (void)telephoneCallWindowWillClose:(NSNotification *)notification;
@end

// Notifications
// accountController will be subscribed to this notification in its setter
extern NSString *AKTelephoneCallWindowWillCloseNotification;
