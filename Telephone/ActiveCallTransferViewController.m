//
//  ActiveCallTransferViewController.m
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov
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

#import "ActiveCallTransferViewController.h"

#import "AKSIPCall.h"

#import "CallTransferController.h"


@implementation ActiveCallTransferViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[[self displayedNameField] cell] setBackgroundStyle:NSBackgroundStyleLight];
    [[[self statusField] cell] setBackgroundStyle:NSBackgroundStyleLight];
}

- (IBAction)transferCall:(id)sender {
    if (![[self callController] isCallOnHold]) {
        [[self callController] toggleCallHold];
    }
    [(CallTransferController *)[self callController] transferCall];
}

- (IBAction)showCallTransferSheet:(id)sender {
    // Do nothing.
}


#pragma mark -
#pragma mark NSMenuValidation protocol

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(showCallTransferSheet:)) {
        return NO;
    }
    
    return [super validateMenuItem:menuItem];
}

@end
