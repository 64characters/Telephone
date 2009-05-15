//
//  CallController.h
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

#import <Cocoa/Cocoa.h>

#import "AKActiveCallView.h"


@class AccountController, AKTelephoneCall;

@interface CallController : NSWindowController <AKActiveCallViewDelegate> {
 @private
  NSString *identifier_;
  AKTelephoneCall *call_;
  AccountController *accountController_;
  NSString *displayedName_;
  NSString *status_;
  NSString *nameFromAddressBook_;
  NSString *phoneLabelFromAddressBook_;
  NSString *enteredCallDestination_;
  NSTimer *intermediateStatusTimer_;
  NSTimeInterval callStartTime_;
  NSTimer *callTimer_;
  BOOL callOnHold_;
  NSMutableString *enteredDTMF_;
  BOOL callActive_;
  BOOL callUnhandled_;
  
  NSView *incomingCallView_;
  NSView *activeCallView_;
  NSView *endedCallView_;
  NSButton *hangUpButton_;
  NSButton *acceptCallButton_;
  NSButton *declineCallButton_;
  NSTextField *incomingCallDisplayedNameField_;
  NSTextField *activeCallDisplayedNameField_;
  NSTextField *endedCallDisplayedNameField_;
  NSTextField *incomingCallStatusField_;
  NSTextField *activeCallStatusField_;
  NSTextField *endedCallStatusField_;
  NSProgressIndicator *callProgressIndicator_;
}

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, retain) AKTelephoneCall *call;
@property(nonatomic, assign) AccountController *accountController;
@property(nonatomic, copy) NSString *displayedName;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *nameFromAddressBook;
@property(nonatomic, copy) NSString *phoneLabelFromAddressBook;
@property(nonatomic, copy) NSString *enteredCallDestination;
@property(nonatomic, retain) NSTimer *intermediateStatusTimer;
@property(nonatomic, assign) NSTimeInterval callStartTime;
@property(nonatomic, retain) NSTimer *callTimer;
@property(nonatomic, assign, getter=isCallOnHold) BOOL callOnHold;
@property(nonatomic, retain) NSMutableString *enteredDTMF;
@property(nonatomic, assign, getter=isCallActive) BOOL callActive;
@property(nonatomic, assign, getter=isCallUnhandled) BOOL callUnhandled;

@property(nonatomic, retain) IBOutlet NSView *incomingCallView;
@property(nonatomic, retain) IBOutlet NSView *activeCallView;
@property(nonatomic, retain) IBOutlet NSView *endedCallView;
@property(nonatomic, retain) IBOutlet NSButton *hangUpButton;
@property(nonatomic, retain) IBOutlet NSButton *acceptCallButton;
@property(nonatomic, retain) IBOutlet NSButton *declineCallButton;
@property(nonatomic, retain) IBOutlet NSTextField *incomingCallDisplayedNameField;
@property(nonatomic, retain) IBOutlet NSTextField *activeCallDisplayedNameField;
@property(nonatomic, retain) IBOutlet NSTextField *endedCallDisplayedNameField;
@property(nonatomic, retain) IBOutlet NSTextField *incomingCallStatusField;
@property(nonatomic, retain) IBOutlet NSTextField *activeCallStatusField;
@property(nonatomic, retain) IBOutlet NSTextField *endedCallStatusField;
@property(nonatomic, retain) IBOutlet NSProgressIndicator *callProgressIndicator;

// Designated initializer
- (id)initWithAccountController:(AccountController *)anAccountController;

- (IBAction)acceptCall:(id)sender;
- (IBAction)hangUpCall:(id)sender;

- (IBAction)toggleCallHold:(id)sender;
- (IBAction)toggleMicrophoneMute:(id)sender;

// Dealing with the timer of active call.
- (void)startCallTimer;
- (void)stopCallTimer;
- (void)callTimerTick:(NSTimer *)theTimer;

- (void)setIntermediateStatus:(NSString *)newIntermediateStatus;
- (void)intermediateStatusTimerTick:(NSTimer *)theTimer;

@end


// Notifications.
// accountController will be subscribed to this notification in its setter.
extern NSString * const AKTelephoneCallWindowWillCloseNotification;
