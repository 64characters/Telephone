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

#import <Cocoa/Cocoa.h>

#import "AKActiveCallView.h"


// Notifications.
//
// Sent when call window is about to be closed.
// |accountController| will be subscribed to this notification in its setter.
extern NSString * const AKCallWindowWillCloseNotification;

@class AccountController, AKSIPCall, AKResponsiveProgressIndicator, AKSIPURI;

// A call controller.
@interface CallController : NSWindowController <AKActiveCallViewDelegate> {
 @private
  NSString *identifier_;
  AKSIPCall *call_;
  AccountController *accountController_;
  NSString *displayedName_;
  NSString *status_;
  NSString *nameFromAddressBook_;
  NSString *phoneLabelFromAddressBook_;
  NSString *enteredCallDestination_;
  AKSIPURI *redialURI_;
  NSTimer *intermediateStatusTimer_;
  NSTimeInterval callStartTime_;
  NSTimer *callTimer_;
  BOOL callOnHold_;
  NSMutableString *enteredDTMF_;
  BOOL callActive_;
  BOOL callUnhandled_;
  NSTrackingArea *callProgressIndicatorTrackingArea_;
  
  NSView *incomingCallView_;
  NSView *activeCallView_;
  NSView *endedCallView_;
  NSButton *hangUpButton_;
  NSButton *acceptCallButton_;
  NSButton *declineCallButton_;
  NSButton *redialButton_;
  NSTextField *incomingCallDisplayedNameField_;
  NSTextField *activeCallDisplayedNameField_;
  NSTextField *endedCallDisplayedNameField_;
  NSTextField *incomingCallStatusField_;
  NSTextField *activeCallStatusField_;
  NSTextField *endedCallStatusField_;
  AKResponsiveProgressIndicator *callProgressIndicator_;
}

// The receiver's identifier.
@property(nonatomic, copy) NSString *identifier;

// Call controlled by the receiver.
@property(nonatomic, retain) AKSIPCall *call;

// Account controller the receiver belongs to.
@property(nonatomic, assign) AccountController *accountController;

// Remote party dislpay name.
@property(nonatomic, copy) NSString *displayedName;

// Call status.
@property(nonatomic, copy) NSString *status;

// Remote party name from the Address Book.
@property(nonatomic, copy) NSString *nameFromAddressBook;

// Remote party label from the Address Book.
@property(nonatomic, copy) NSString *phoneLabelFromAddressBook;

// Call destination entered by a user.
@property(nonatomic, copy) NSString *enteredCallDestination;

// SIP URI for the redial.
@property(nonatomic, copy) AKSIPURI *redialURI;

// Timer to display intermediate call status. This status appears for the short
// period of time and then is being replaced with the current call status.
@property(nonatomic, assign) NSTimer *intermediateStatusTimer;

// Call start time.
@property(nonatomic, assign) NSTimeInterval callStartTime;

// Timer to present a call duration time.
@property(nonatomic, assign) NSTimer *callTimer;

// A Boolean value indicating whether the receiver's call is on hold.
@property(nonatomic, assign, getter=isCallOnHold) BOOL callOnHold;

// DTMF digits entered by a user so far.
@property(nonatomic, retain) NSMutableString *enteredDTMF;

// A Boolean value indicating whether the receiver's call is active.
@property(nonatomic, assign, getter=isCallActive) BOOL callActive;

// A Boolean value indicating whether the receiver's call is unhandled.
@property(nonatomic, assign, getter=isCallUnhandled) BOOL callUnhandled;

// Tracking area to monitor a mouse hovering call progress indicator. When mouse
// enters that area, progress indicator is being replaced with hang-up button.
@property(nonatomic, retain) NSTrackingArea *callProgressIndicatorTrackingArea;

// Outlets.

// Incoming call view outlet.
@property(nonatomic, retain) IBOutlet NSView *incomingCallView;

// Active call view outlet.
@property(nonatomic, retain) IBOutlet NSView *activeCallView;

// Ended call view outlet.
@property(nonatomic, retain) IBOutlet NSView *endedCallView;

// Hang-up button outlet.
@property(nonatomic, retain) IBOutlet NSButton *hangUpButton;

// Accept Call button outlet.
@property(nonatomic, retain) IBOutlet NSButton *acceptCallButton;

// Decline Call button outlet.
@property(nonatomic, retain) IBOutlet NSButton *declineCallButton;

// Redial button outlet.
@property(nonatomic, retain) IBOutlet NSButton *redialButton;

// Display Name field outlet of the incoming call view.
@property(nonatomic, retain) IBOutlet NSTextField *incomingCallDisplayedNameField;

// Display Name field outlet of the active call view.
@property(nonatomic, retain) IBOutlet NSTextField *activeCallDisplayedNameField;

// Display Name field outlet of the ended call view.
@property(nonatomic, retain) IBOutlet NSTextField *endedCallDisplayedNameField;

// Status field outlet of the incoming call view.
@property(nonatomic, retain) IBOutlet NSTextField *incomingCallStatusField;

// Status field outlet of the active call view.
@property(nonatomic, retain) IBOutlet NSTextField *activeCallStatusField;

// Status field outlet of the ended call view.
@property(nonatomic, retain) IBOutlet NSTextField *endedCallStatusField;

// Call progress indicator outlet.
@property(nonatomic, retain) IBOutlet AKResponsiveProgressIndicator *callProgressIndicator;

// Designated initializer.
// Initializes a CallController object with a given account controller.
- (id)initWithAccountController:(AccountController *)anAccountController;

// Accepts an incoming call.
- (IBAction)acceptCall:(id)sender;

// Hangs up a call.
- (IBAction)hangUpCall:(id)sender;

// Redials a call.
- (IBAction)redial:(id)sender;

// Toggles call hold.
- (IBAction)toggleCallHold:(id)sender;

// Toggles microphone mute.
- (IBAction)toggleMicrophoneMute:(id)sender;

// Starts a call timer.
- (void)startCallTimer;

// Stops a call timer.
- (void)stopCallTimer;

// Method to be called when call timer fires.
- (void)callTimerTick:(NSTimer *)theTimer;

// Sets intermediate call status. This status appears for the short period of
// time and then is being replaced with the current call status.
- (void)setIntermediateStatus:(NSString *)newIntermediateStatus;

// Method to be called when intermediate call status timer fires.
- (void)intermediateStatusTimerTick:(NSTimer *)theTimer;

@end
