//
//  ActiveCallViewController.h
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

#import <Cocoa/Cocoa.h>

#import "AKActiveCallView.h"
#import "XSViewController.h"


@class AKResponsiveProgressIndicator, CallController;

@interface ActiveCallViewController : XSViewController <AKActiveCallViewDelegate>

// Call controller the receiver belongs to.
@property (nonatomic, weak) CallController *callController;

// Timer to present call duration time.
@property (nonatomic, strong) NSTimer *callTimer;

// DTMF digits entered by a user.
@property (nonatomic, strong) NSMutableString *enteredDTMF;

// Tracking area to monitor a mouse hovering call progress indicator. When mouse enters that area, progress indicator
// is being replaced with hang-up button.
@property (nonatomic, strong) NSTrackingArea *callProgressIndicatorTrackingArea;


// Display Name field outlet.
@property (nonatomic, weak) IBOutlet NSTextField *displayedNameField;

// Status field outlet.
@property (nonatomic, weak) IBOutlet NSTextField *statusField;

// Call progress indicator outlet.
@property (nonatomic, strong) IBOutlet AKResponsiveProgressIndicator *callProgressIndicator;

// Hang-up button outlet.
@property (nonatomic, strong) IBOutlet NSButton *hangUpButton;


// Designated initializer.
// Initializes an ActiveCallViewController object with a given nib file and call controller.
- (id)initWithNibName:(NSString *)nibName callController:(CallController *)callController;

// Hangs up call.
- (IBAction)hangUpCall:(id)sender;

// Toggles call hold.
- (IBAction)toggleCallHold:(id)sender;

// Toggles microphone mute.
- (IBAction)toggleMicrophoneMute:(id)sender;

// Shows call transfer sheet.
- (IBAction)showCallTransferSheet:(id)sender;

// Starts call timer.
- (void)startCallTimer;

// Stops call timer.
- (void)stopCallTimer;

// Method to be called when call timer fires.
- (void)callTimerTick:(NSTimer *)theTimer;

@end
