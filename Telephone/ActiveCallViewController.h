//
//  ActiveCallViewController.h
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

#import <Cocoa/Cocoa.h>

#import "AKActiveCallView.h"


@class CallController;

@interface ActiveCallViewController : NSViewController <AKActiveCallViewDelegate>

// Call controller the receiver belongs to.
@property(nonatomic, weak) CallController *callController;

// Timer to present call duration time.
@property(nonatomic, strong) NSTimer *callTimer;

// DTMF digits entered by a user.
@property(nonatomic, strong) NSMutableString *enteredDTMF;


// Designated initializer.
// Initializes an ActiveCallViewController object with a given nib file and call controller.
- (instancetype)initWithNibName:(NSString *)nibName callController:(CallController *)callController;

- (void)removeObservations;

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

- (void)showProgress;
- (void)showHangUp;

- (void)allowHangUp;
- (void)disallowHangUp;

@end
