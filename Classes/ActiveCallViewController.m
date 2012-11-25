//
//  ActiveCallViewController.m
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

#import "ActiveCallViewController.h"

#import "AKNSWindow+Resizing.h"
#import "AKResponsiveProgressIndicator.h"
#import "AKSIPCall.h"

#import "CallController.h"
#import "CallTransferController.h"
#import "EndedCallViewController.h"


@implementation ActiveCallViewController

@synthesize callController = callController_;
@synthesize callTimer = callTimer_;
@synthesize enteredDTMF = enteredDTMF_;
@synthesize callProgressIndicatorTrackingArea = callProgressIndicatorTrackingArea_;

@synthesize displayedNameField = displayedNameField_;
@synthesize statusField = statusField_;
@synthesize callProgressIndicator = callProgressIndicator_;
@synthesize hangUpButton = hangUpButton_;

- (id)initWithNibName:(NSString *)nibName callController:(CallController *)callController {
    self = [super initWithNibName:nibName bundle:nil windowController:callController];
    
    if (self != nil) {
        enteredDTMF_ = [[NSMutableString alloc] init];
        [self setCallController:callController];
    }
    return self;
}

- (id)init {
    [self dealloc];
    NSString *reason = @"Initialize ActiveCallViewController with initWithCallController:";
    @throw [NSException exceptionWithName:@"AKBadInitCall" reason:reason userInfo:nil];
    return nil;
}

- (void)dealloc {
    [enteredDTMF_ release];
    [callProgressIndicatorTrackingArea_ release];
    
    [displayedNameField_ release];
    [statusField_ release];
    [callProgressIndicator_ release];
    [hangUpButton_ release];
    
    [super dealloc];
}

- (void)removeObservations {
    [[self displayedNameField] unbind:NSValueBinding];
    [[self statusField] unbind:NSValueBinding];
    [super removeObservations];
}

- (void)awakeFromNib {
    [[[self displayedNameField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[[self statusField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[self callProgressIndicator] startAnimation:self];
    
    // Set hang-up button origin manually.
    NSRect hangUpButtonFrame = [[self hangUpButton] frame];
    NSRect progressIndicatorFrame = [[self callProgressIndicator] frame];
    hangUpButtonFrame.origin.x = progressIndicatorFrame.origin.x + 1;
    hangUpButtonFrame.origin.y = progressIndicatorFrame.origin.y + 1;
    [[self hangUpButton] setFrame:hangUpButtonFrame];
    
    // Add mouse tracking area to switch between call progress indicator and a hang-up button in the active call view.
    NSRect trackingRect = [[self callProgressIndicator] frame];
    
    NSUInteger trackingOptions = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
    
    NSTrackingArea *trackingArea = [[[NSTrackingArea alloc] initWithRect:trackingRect
                                                                 options:trackingOptions
                                                                   owner:self
                                                                userInfo:nil]
                                    autorelease];
    
    [[self view] addTrackingArea:trackingArea];
    [self setCallProgressIndicatorTrackingArea:trackingArea];
    
    // Add support for clicking call progress indicator to hang-up.
    [[self callProgressIndicator] setTarget:self];
    [[self callProgressIndicator] setAction:@selector(hangUpCall:)];
}

- (IBAction)hangUpCall:(id)sender {
    [[self callController] hangUpCall];
}

- (IBAction)toggleCallHold:(id)sender {
    [[self callController] toggleCallHold];
}

- (IBAction)toggleMicrophoneMute:(id)sender {
    [[self callController] toggleMicrophoneMute];
}

- (IBAction)showCallTransferSheet:(id)sender {
    if (![[self callController] isCallOnHold]) {
        [[self callController] toggleCallHold];
    }
    
    CallTransferController *callTransferController = [[self callController] callTransferController];
    
    [NSApp beginSheet:[callTransferController window]
       modalForWindow:[[self callController] window]
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:NULL];
}

- (void)startCallTimer {
    if ([self callTimer] != nil && [[self callTimer] isValid]) {
        return;
    }
    
    [self setCallTimer:
     [NSTimer scheduledTimerWithTimeInterval:0.2
                                      target:self
                                    selector:@selector(callTimerTick:)
                                    userInfo:nil
                                     repeats:YES]];
}

- (void)stopCallTimer {
    if ([self callTimer] != nil) {
        [[self callTimer] invalidate];
        [self setCallTimer:nil];
    }
}

- (void)callTimerTick:(NSTimer *)theTimer {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSInteger seconds = (NSInteger)(now - ([[self callController] callStartTime]));
    
    if (seconds < 3600) {
        [[self callController] setStatus:[NSString stringWithFormat:@"%02ld:%02ld",
                                          (unsigned long)((seconds / 60) % 60),
                                          (unsigned long)(seconds % 60)]];
    } else {
        [[self callController]
         setStatus:[NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                    (unsigned long)((seconds / 3600) % 24),
                    (unsigned long)((seconds / 60) % 60),
                    (unsigned long)(seconds % 60)]];
    }
}


#pragma mark -
#pragma mark NSResponder overrides

- (void)mouseEntered:(NSEvent *)theEvent {
    [[self view] replaceSubview:[self callProgressIndicator]
                           with:[self hangUpButton]];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[self view] replaceSubview:[self hangUpButton]
                           with:[self callProgressIndicator]];
}


#pragma mark -
#pragma mark AKActiveCallViewDelegate protocol

- (void)activeCallView:(AKActiveCallView *)sender didReceiveText:(NSString *)aString {
    NSCharacterSet *DTMFCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"];
    
    BOOL isDTMFValid = YES;
    for (NSUInteger i = 0; i < [aString length]; ++i) {
        unichar digit = [aString characterAtIndex:i];
        if (![DTMFCharacterSet characterIsMember:digit]) {
            isDTMFValid = NO;
            break;
        }
    }
    
    if (isDTMFValid) {
        if ([[self enteredDTMF] length] == 0) {
            [[self enteredDTMF] appendString:aString];
            [[[self view] window] setTitle:[[self callController] displayedName]];
            
            if ([[[self displayedNameField] cell] lineBreakMode]!= NSLineBreakByTruncatingHead) {
                [[[self displayedNameField] cell] setLineBreakMode:NSLineBreakByTruncatingHead];
                [[[[self callController] endedCallViewController] displayedNameField] setSelectable:YES];
            }
            
            [[self callController] setDisplayedName:aString];
            
        } else {
            [[self enteredDTMF] appendString:aString];
            [[self callController] setDisplayedName:[self enteredDTMF]];
        }
        
        [[[self callController] call] sendDTMFDigits:aString];
    }
}


#pragma mark -
#pragma mark NSMenuValidation protocol

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([menuItem action] == @selector(toggleMicrophoneMute:)) {
        if ([[[self callController] call] isMicrophoneMuted]) {
            [menuItem setTitle:NSLocalizedString(@"Unmute", @"Unmute. Call menu item.")];
        } else {
            [menuItem setTitle:NSLocalizedString(@"Mute", @"Mute. Call menu item.")];
        }
        
        if ([[[self callController] call] state] == kAKSIPCallConfirmedState) {
            return YES;
        } else {
            return NO;
        }
        
    } else if ([menuItem action] == @selector(toggleCallHold:)) {
        if ([[[self callController] call] state] == kAKSIPCallConfirmedState &&
            [[[self callController] call] isOnLocalHold]) {
            [menuItem setTitle:NSLocalizedString(@"Resume", @"Resume. Call menu item.")];
        } else {
            [menuItem setTitle:NSLocalizedString(@"Hold", @"Hold. Call menu item.")];
        }
        
        if ([[[self callController] call] state] == kAKSIPCallConfirmedState &&
            ![[[self callController] call] isOnRemoteHold]) {
            
            return YES;
            
        } else {
            return NO;
        }
        
    } else if ([menuItem action] == @selector(showCallTransferSheet:)) {
        if ([[[self callController] call] state] == kAKSIPCallConfirmedState &&
            ![[[self callController] call] isOnRemoteHold]) {
            
            return YES;
            
        } else {
            return NO;
        }
        
    } else if ([menuItem action] == @selector(hangUpCall:)) {
        [menuItem setTitle:NSLocalizedString(@"End Call", @"End Call. Call menu item.")];
    }
    
    return YES;
}

@end
