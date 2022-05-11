//
//  EndedCallViewController.h
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

@interface EndedCallViewController : NSViewController

// Call controller the receiver belongs to.
@property(nonatomic, weak) CallController *callController;


// Display Name field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *displayedNameField;

// Status field outlet.
@property(nonatomic, weak) IBOutlet NSTextField *statusField;

// Redial button outlet.
@property(nonatomic, weak) IBOutlet NSButton *redialButton;


// Designated initializer.
// Initializes an EndedCallViewController object with a given nib file and call controller.
- (instancetype)initWithNibName:(NSString *)nibName callController:(CallController *)callController;

- (void)removeObservations;

// Redials a call.
- (IBAction)redial:(id)sender;

// Method to be called when |enable redial button| timer fires.
- (void)enableRedialButtonTick:(NSTimer *)theTimer;

@end
