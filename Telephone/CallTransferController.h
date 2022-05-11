//
//  CallTransferController.h
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

#import "ActiveAccountTransferViewController.h"
#import "CallController.h"


// Call transfer controller.
@interface CallTransferController : CallController

// Designated initializer.
- (instancetype)initWithSourceCallController:(CallController *)callController userAgent:(AKSIPUserAgent *)userAgent;

// Transfers source call controller's call to the receiver's call.
- (void)transferCall;

// Closes a sheet.
- (IBAction)closeSheet:(id)sender;

// Hangs up call and shows initial state.
- (IBAction)showInitialState:(id)sender;

@end
