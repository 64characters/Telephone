//
//  ActiveCallTransferViewController.m
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

#import "ActiveCallTransferViewController.h"

#import "AKSIPCall.h"

#import "CallTransferController.h"


@interface ActiveCallTransferViewController ()

@property(nonatomic, getter=isWaitingForHold) BOOL waitingForHold;

@property(nonatomic, weak) IBOutlet NSButton *cancelButton;
@property(nonatomic, weak) IBOutlet NSButton *transferButton;

@end

@implementation ActiveCallTransferViewController

- (void)setRepresentedObject:(id)representedObject {
    super.representedObject = representedObject;
    self.waitingForHold = NO;
}

- (IBAction)transferCall:(id)sender {
    if (self.callController.isCallOnHold) {
        [(CallTransferController *)self.callController transferCall];
    } else {
        [self.callController toggleCallHold];
        [self disallowTransfer];
        self.waitingForHold = YES;
    }
}

- (void)callDidHold {
    if (self.isWaitingForHold) {
        [(CallTransferController *)self.callController transferCall];
        self.waitingForHold = NO;
    }
}

- (void)allowTransfer {
    self.transferButton.enabled = YES;
}

- (void)disallowTransfer {
    self.transferButton.enabled = NO;
}

- (IBAction)showCallTransferSheet:(id)sender {
    // Do nothing.
}

- (void)allowHangUp {
    [super allowHangUp];
    self.cancelButton.enabled = YES;
}

- (void)disallowHangUp {
    [super disallowHangUp];
    self.cancelButton.enabled = NO;
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
