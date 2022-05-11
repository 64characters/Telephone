//
//  IncomingCallViewController.h
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


@class CallController;

@interface IncomingCallViewController : NSViewController

// Call controller the receiver belongs to.
@property(nonatomic, weak) CallController *callController;

// Accept Call button outlet.
@property(nonatomic, weak) IBOutlet NSButton *acceptCallButton;

// Decline Call button outlet.
@property(nonatomic, weak) IBOutlet NSButton *declineCallButton;

// Designated initializer.
// Initializes an IncomingCallViewController object with a given call controller.
- (instancetype)initWithCallController:(CallController *)callController;

- (void)removeObservations;

// Accepts an incoming call.
- (IBAction)acceptCall:(id)sender;

// Declines an incoming call.
- (IBAction)hangUpCall:(id)sender;

@end
