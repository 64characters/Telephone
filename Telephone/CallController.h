//
//  CallController.h
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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

#import <Cocoa/Cocoa.h>

#import "AKSIPCall.h"
#import "XSWindowController.h"

#import "CallControllerDelegate.h"


@class AccountController, AKSIPCall, AKResponsiveProgressIndicator, AKSIPURI;
@class IncomingCallViewController, ActiveCallViewController;
@class EndedCallViewController, CallTransferController;
@protocol RingtonePlaybackInteractor;

// A call controller.
@interface CallController : XSWindowController <AKSIPCallDelegate> {
  @protected
    ActiveCallViewController *_activeCallViewController;
    EndedCallViewController *_endedCallViewController;
}

@property(nonatomic, readonly, weak) id<CallControllerDelegate> delegate;

// The receiver's identifier.
@property(nonatomic, copy) NSString *identifier;

// Call controlled by the receiver.
@property(nonatomic, strong) AKSIPCall *call;

// Account controller the receiver belongs to.
@property(nonatomic, weak) AccountController *accountController;

@property(nonatomic, readonly, strong) id<RingtonePlaybackInteractor> ringtonePlaybackInteractor;

// Call transfer controller.
@property(nonatomic, readonly) CallTransferController *callTransferController;


// Incoming call view controller.
@property(nonatomic, readonly) IncomingCallViewController *incomingCallViewController;

// Active call view controller.
@property(nonatomic, readonly, strong) ActiveCallViewController *activeCallViewController;

// Ended call view controller.
@property(nonatomic, readonly, strong) EndedCallViewController *endedCallViewController;


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

// Timer to display intermediate call status. This status appears for the short period of time and then is being
// replaced with the current call status.
@property(nonatomic, strong) NSTimer *intermediateStatusTimer;

// Call start time.
@property(nonatomic, assign) NSTimeInterval callStartTime;

// A Boolean value indicating whether the receiver's call is on hold.
@property(nonatomic, assign, getter=isCallOnHold) BOOL callOnHold;

// A Boolean value indicating whether the receiver's call is active.
@property(nonatomic, assign, getter=isCallActive) BOOL callActive;

// A Boolean value indicating whether the receiver's call is unhandled.
@property(nonatomic, assign, getter=isCallUnhandled) BOOL callUnhandled;


- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                    accountController:(AccountController *)accountController
           ringtonePlaybackInteractor:(id<RingtonePlaybackInteractor>)ringtonePlaybackInteractor
                             delegate:(id<CallControllerDelegate>)delegate;

// Accepts an incoming call.
- (void)acceptCall;

// Hangs up a call.
- (void)hangUpCall;

// Redials a call.
- (void)redial;

// Toggles call hold.
- (void)toggleCallHold;

// Toggles microphone mute.
- (void)toggleMicrophoneMute;

// Sets intermediate call status. This status appears for the short period of time and then is being replaced with the
// current call status.
- (void)setIntermediateStatus:(NSString *)newIntermediateStatus;

// Method to be called when intermediate call status timer fires.
- (void)intermediateStatusTimerTick:(NSTimer *)theTimer;

- (void)showActiveCallView;
- (void)showEndedCallView;
- (void)showIncomingCallView;

@end
