//
//  CallTransferController.m
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

#import "CallTransferController.h"

#import "AKNSWindow+Resizing.h"
#import "AKSIPCall.h"

#import "ActiveCallTransferViewController.h"
#import "CallController+Protected.h"
#import "EndedCallTransferViewController.h"


@interface CallTransferController ()

// Source call controller.
@property (nonatomic, weak) CallController *sourceCallController;

// Active account transfer view controller.
@property (nonatomic, strong) ActiveAccountTransferViewController *activeAccountTransferViewController;

// A Boolean value indicating whether the source call has been transferred.
@property (nonatomic, assign) BOOL sourceCallTransferred;

@end


@implementation CallTransferController

- (void)setSourceCallController:(CallController *)callController {
    if (_sourceCallController == callController) {
        return;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if (_sourceCallController != nil) {
        [nc removeObserver:self
                      name:AKSIPCallTransferStatusDidChangeNotification
                    object:[_sourceCallController call]];
    }
    
    if (callController != nil) {
        [nc addObserver:self
               selector:@selector(sourceCallControllerSIPCallTransferStatusDidChange:)
                   name:AKSIPCallTransferStatusDidChangeNotification
                 object:[callController call]];
    }
    
    [self setSourceCallTransferred:NO];
    
    _sourceCallController = callController;
}

- (id)initWithSourceCallController:(CallController *)callController {
    self = [super initWithWindowNibName:@"CallTransfer" accountController:[callController accountController]];
    if (self != nil) {
        [self setSourceCallController:callController];
        
        AccountController *accountController = [[self sourceCallController] accountController];
        
        _activeAccountTransferViewController
            = [[ActiveAccountTransferViewController alloc] initWithAccountController:accountController
                                                                    windowController:self];
    }
    return self;
}

- (void)windowDidLoad {
    [self showInitialState:self];
}

- (void)transferCall {
    [[[self sourceCallController] call] attendedTransferToCall:[self call]];
}

- (IBAction)closeSheet:(id)sender {
    if ([[self sourceCallController] isCallActive] && [[self sourceCallController] isCallOnHold]) {
        [[self sourceCallController] toggleCallHold];
    }
    [NSApp endSheet:[sender window]];
    [[sender window] orderOut:sender];
}

- (IBAction)showInitialState:(id)sender {
    if ([self isCallActive]) {
        [self hangUpCall];
    }
    
    if (![[self sourceCallController] isCallActive]) {
        [self closeSheet:self];
    }
    
    if ([self countOfViewControllers] > 0) {
        [[self viewControllers] removeAllObjects];
        [self patchResponderChain];
    }
    [self addViewController:[self activeAccountTransferViewController]];
    [[self window] ak_resizeAndSwapToContentView:[[self activeAccountTransferViewController] view] animate:YES];
    
    if ([[[self activeAccountTransferViewController] callDestinationField] acceptsFirstResponder]) {
        [[self window] makeFirstResponder:[[self activeAccountTransferViewController] callDestinationField]];
    }
}


#pragma mark -
#pragma mark CallController methods

- (CallTransferController *)callTransferController {
    return nil;
}

- (IncomingCallViewController *)incomingCallViewController {
    return nil;
}

// Substitutes ActiveCallTransferViewController.
- (ActiveCallViewController *)activeCallViewController {
    if (_activeCallViewController == nil) {
        _activeCallViewController
            = [[ActiveCallTransferViewController alloc] initWithNibName:@"ActiveCallTransferView" callController:self];
        [_activeCallViewController setRepresentedObject:[self call]];
    }
    return _activeCallViewController;
}

// Substitutes EndedCallTransferViewController.
- (EndedCallViewController *)endedCallViewController {
    if (_endedCallViewController == nil) {
        _endedCallViewController
            = [[EndedCallTransferViewController alloc] initWithNibName:@"EndedCallTransferView" callController:self];
        [_endedCallViewController setRepresentedObject:[self call]];
    }
    return _endedCallViewController;
}

- (void)acceptCall {
    // Do nothing.
}


#pragma mark -
#pragma mark AKSIPCall notifications

- (void)SIPCallCalling:(NSNotification *)notification {
    [super SIPCallCalling:notification];
    ActiveCallTransferViewController *activeCallTransferViewController
        = (ActiveCallTransferViewController *)[self activeCallViewController];
    [[activeCallTransferViewController transferButton] setEnabled:NO];
}

- (void)SIPCallEarly:(NSNotification *)notification {
    [super SIPCallEarly:notification];
    ActiveCallTransferViewController *activeCallTransferViewController
        = (ActiveCallTransferViewController *)[self activeCallViewController];
    [[activeCallTransferViewController transferButton] setEnabled:NO];
}

- (void)SIPCallDidConfirm:(NSNotification *)notification {
    [super SIPCallDidConfirm:notification];
    ActiveCallTransferViewController *activeCallTransferViewController
        = (ActiveCallTransferViewController *)[self activeCallViewController];
    [[activeCallTransferViewController transferButton] setEnabled:YES];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [super SIPCallDidDisconnect:notification];
    if ([self sourceCallTransferred]) {
        [self closeSheet:self];
    }
}

- (void)SIPCallMediaDidBecomeActive:(NSNotification *)notification {
    [super SIPCallMediaDidBecomeActive:notification];
    ActiveCallTransferViewController *activeCallTransferViewController
        = (ActiveCallTransferViewController *)[self activeCallViewController];
    [[activeCallTransferViewController transferButton] setEnabled:YES];
}

- (void)SIPCallDidRemoteHold:(NSNotification *)notification {
    [super SIPCallDidRemoteHold:notification];
    ActiveCallTransferViewController *activeCallTransferViewController
        = (ActiveCallTransferViewController *)[self activeCallViewController];
    [[activeCallTransferViewController transferButton] setEnabled:NO];
}


#pragma mark -
#pragma mark Source Call Controller's call notification

- (void)sourceCallControllerSIPCallTransferStatusDidChange:(NSNotification *)notification {
    AKSIPCall *sourceCall = [notification object];
    NSDictionary *userInfo = [notification userInfo];
    BOOL isFinal = [[userInfo objectForKey:@"AKFinalTransferNotification"] boolValue];
    
    if (isFinal && [sourceCall transferStatus] == PJSIP_SC_OK) {
        [self setSourceCallTransferred:YES];
        if (![self isCallActive]) {
            [self closeSheet:self];
        }
    }
}

@end
