//
//  IncomingCallViewController.h
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

#import "XSViewController.h"


@class CallController;

@interface IncomingCallViewController : XSViewController

// Call controller the receiver belongs to.
@property(nonatomic, weak) CallController *callController;

// Display Name field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *displayedNameField;

// Status field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *statusField;

// Accept Call button outlet.
@property(nonatomic, weak) IBOutlet NSButton *acceptCallButton;

// Decline Call button outlet.
@property(nonatomic, weak) IBOutlet NSButton *declineCallButton;

// Designated initializer.
// Initializes an IncomingCallViewController object with a given call controller.
- (instancetype)initWithCallController:(CallController *)callController;

// Accepts an incoming call.
- (IBAction)acceptCall:(id)sender;

// Declines an incoming call.
- (IBAction)hangUpCall:(id)sender;

@end
