//
//  ActiveCallTransferViewController.h
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

#import <Foundation/Foundation.h>

#import "ActiveCallViewController.h"


// An active call controller of a call transfer.
@interface ActiveCallTransferViewController : ActiveCallViewController

// Call transfer button.
@property(nonatomic, weak) IBOutlet NSButton *transferButton;


// Transfers a call.
- (IBAction)transferCall:(id)sender;

@end
