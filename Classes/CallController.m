//
//  CallController.m
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

#import "CallController.h"

#import <Growl/Growl.h>

#import "AKActiveCallView.h"
#import "AKResponsiveProgressIndicator.h"
#import "AKNSString+Creating.h"
#import "AKNSString+Scanning.h"
#import "AKNSWindow+Resizing.h"
#import "AKSIPCall.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKSIPUserAgent.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountController.h"
#import "ActiveCallViewController.h"
#import "AppController.h"
#import "CallTransferController.h"
#import "EndedCallViewController.h"
#import "IncomingCallViewController.h"
#import "PreferencesController.h"


NSString * const AKCallWindowWillCloseNotification = @"AKCallWindowWillClose";

// Window auto-close delay.
static const NSTimeInterval kCallWindowAutoCloseTime = 1.5;

// Redial button re-enable delay.
static const NSTimeInterval kRedialButtonReenableTime = 1.0;

@interface CallController ()

// Account description field.
@property(nonatomic, weak) IBOutlet NSTextField *accountDescriptionField;

// Call info view.
@property(nonatomic, strong) NSView *callInfoView;

// Closes call window.
- (void)closeCallWindow;

@end

@implementation CallController

@synthesize callTransferController = _callTransferController;
@synthesize incomingCallViewController = _incomingCallViewController;

- (void)setCall:(AKSIPCall *)aCall {
    if (_call != aCall) {
        if ([[_call delegate] isEqual:self]) {
            [_call setDelegate:nil];
        }
        
        _call = aCall;
        
        [_call setDelegate:self];
    }
}

- (void)setAccountController:(AccountController *)anAccountController {
    if (_accountController == anAccountController) {
        return;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (_accountController != nil) {
        [notificationCenter removeObserver:_accountController name:nil object:self];
    }
    
    if (anAccountController != nil) {
        if ([anAccountController respondsToSelector:@selector(callWindowWillClose:)]) {
            [notificationCenter addObserver:anAccountController
                                   selector:@selector(callWindowWillClose:)
                                       name:AKCallWindowWillCloseNotification
                                     object:self];
        }
    }
    
    _accountController = anAccountController;
}

- (CallTransferController *)callTransferController {
    if (_callTransferController == nil) {
        _callTransferController = [[CallTransferController alloc] initWithSourceCallController:self];
    }
    return _callTransferController;
}

- (IncomingCallViewController *)incomingCallViewController {
    if (_incomingCallViewController == nil) {
        _incomingCallViewController = [[IncomingCallViewController alloc] initWithCallController:self];
        [_incomingCallViewController setRepresentedObject:[self call]];
    }
    return _incomingCallViewController;
}

- (ActiveCallViewController *)activeCallViewController {
    if (_activeCallViewController == nil) {
        _activeCallViewController = [[ActiveCallViewController alloc] initWithNibName:@"ActiveCallView"
                                                                       callController:self];
        [_activeCallViewController setRepresentedObject:[self call]];
    }
    return _activeCallViewController;
}

- (EndedCallViewController *)endedCallViewController {
    if (_endedCallViewController == nil) {
        _endedCallViewController = [[EndedCallViewController alloc] initWithNibName:@"EndedCallView"
                                                                     callController:self];
        [_endedCallViewController setRepresentedObject:[self call]];
    }
    return _endedCallViewController;
}

- (id)initWithWindowNibName:(NSString *)windowNibName accountController:(AccountController *)anAccountController {
    self = [super initWithWindowNibName:windowNibName];
    if (self == nil) {
        return nil;
    }
    
    [self setIdentifier:[NSString ak_uuidString]];
    [self setAccountController:anAccountController];
    [self setCallOnHold:NO];
    [self setCallActive:NO];
    [self setCallUnhandled:NO];
    
    return self;
}

- (id)init {
    return [self initWithWindowNibName:@"Call" accountController:nil];
}

- (void)dealloc {
    [self setCall:nil];
    [self setAccountController:nil];
}

- (NSString *)description {
    return [[self call] description];
}

- (void)awakeFromNib {
    [[[self accountDescriptionField] cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    NSRect frame = [[[self window] contentView] frame];
    frame.origin.x = 0.0;
    CGFloat minYBorderThickness = [[self window] contentBorderThicknessForEdge:NSMinYEdge];
    frame.origin.y = minYBorderThickness;
    frame.size.height -= minYBorderThickness;
    NSView *emptyCallInfoView = [[NSView alloc] initWithFrame:frame];
    [self.window.contentView addSubview:emptyCallInfoView];
    self.callInfoView = emptyCallInfoView;
}

- (void)setCallInfoViewResizingWindow:(NSView *)newView {
    // Compute view size delta.
    NSSize currentCallInfoViewSize = [[self callInfoView] frame].size;
    NSSize newViewSize = [newView frame].size;
    CGFloat deltaWidth = newViewSize.width - currentCallInfoViewSize.width;
    CGFloat deltaHeight = newViewSize.height - currentCallInfoViewSize.height;
    
    if (currentCallInfoViewSize.width > 0.0 && currentCallInfoViewSize.height > 0.0 &&
        (fabs(deltaWidth) > 0.1 || fabs(deltaHeight) > 0.1)) {
        // Compute new window size.
        NSRect windowFrame = [[self window] frame];
        windowFrame.size.height += deltaHeight;
        windowFrame.origin.y -= deltaHeight;
        windowFrame.size.width += deltaWidth;
        
        // Set new window frame.
        [[self window] setFrame:windowFrame display:YES animate:YES];
    }
    
    CGFloat minYBorderThickness = [[self window] contentBorderThicknessForEdge:NSMinYEdge];
    if (minYBorderThickness > 0.0) {
        CGRect newViewFrame = [newView frame];
        newViewFrame.origin.y = minYBorderThickness;
        newView.frame = newViewFrame;
    }
    
    // Swap to the new view.
    if (self.callInfoView == nil) {
        [self.window.contentView addSubview:newView];
    } else {
        [self.window.contentView replaceSubview:self.callInfoView with:newView];
    }
    self.callInfoView = newView;
}

- (void)acceptCall {
    if ([[self call] isIncoming]) {
        [[NSApp delegate] stopRingtoneTimerIfNeeded];
    }
    
    [self setCallUnhandled:NO];
    [[NSApp delegate] updateDockTileBadgeLabel];
    
    [[self call] answer];
}

- (void)hangUpCall {
    [self setCallActive:NO];
    [self setCallUnhandled:NO];
    
    if (_activeCallViewController != nil) {
        [[self activeCallViewController] stopCallTimer];
    }
    
    if ([[self call] isIncoming]) {
        [[NSApp delegate] stopRingtoneTimerIfNeeded];
    }
    
    // If remote party hasn't sent back any replies, call hang-up will not happen immediately. Unsubscribe from any
    // notifications about the call state and set disconnected look to the call window.
    
    if ([[[self call] delegate] isEqual:self]) {
        [[self call] setDelegate:nil];
    }
    
    [[self call] hangUp];
    
    [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];
    
    [self removeObjectFromViewControllersAtIndex:0];
    [self addViewController:[self endedCallViewController]];
    [self setCallInfoViewResizingWindow:[[self endedCallViewController] view]];
    
    [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
    [[[self activeCallViewController] hangUpButton] setEnabled:NO];
    [[[self incomingCallViewController] acceptCallButton] setEnabled:NO];
    [[[self incomingCallViewController] declineCallButton] setEnabled:NO];
    
    [[NSApp delegate] resumeITunesIfNeeded];
    [[NSApp delegate] updateDockTileBadgeLabel];
    
    // Optionally close call window.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCloseCallWindow] &&
        ![self isKindOfClass:[CallTransferController class]]) {
        
        [self performSelector:@selector(closeCallWindow)
                   withObject:nil
                   afterDelay:kCallWindowAutoCloseTime];
    }
}

- (void)redial {
    if (![[[NSApp delegate] userAgent] isStarted] ||
        ![[self accountController] isEnabled] ||
        ![[[[self accountController] window] contentView] isEqual:
          [[[self accountController] activeAccountViewController] view]] ||
        [self redialURI] == nil) {
        
        return;
    }
    
    // Cancel call window auto-close.
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(closeCallWindow)
                                               object:nil];
    
    // Replace plus character if needed.
    if ([[self accountController] substitutesPlusCharacter] &&
        [[[self redialURI] user] hasPrefix:@"+"]) {
        
        [[self redialURI] setUser:[[[self redialURI] user]
                                   stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                   withString:[[self accountController]
                                               plusCharacterSubstitution]]];
    }
    
    if (![[self objectInViewControllersAtIndex:0] isEqual:[self activeCallViewController]]) {
        [self removeObjectFromViewControllersAtIndex:0];
        [self addViewController:[self activeCallViewController]];
        [self setCallInfoViewResizingWindow:[[self activeCallViewController] view]];
    }
    
    [[[self activeCallViewController] view] replaceSubview:[[self activeCallViewController] hangUpButton]
                                                      with:[[self activeCallViewController] callProgressIndicator]];
    
    [[[self activeCallViewController] view] addTrackingArea:
     [[self activeCallViewController] callProgressIndicatorTrackingArea]];
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
    
    // Calling -display is bad style, but we have to run -makeCallTo: below synchronously. And without calling -display:
    // spinner and redial button are visible at the same time.
    [[self window] display];
    [[[self activeCallViewController] callProgressIndicator] startAnimation:self];
    
    if ([[self phoneLabelFromAddressBook] length] > 0) {
        [self setStatus:[NSString stringWithFormat:
                         NSLocalizedString(@"calling %@...",
                                           @"Outgoing call in progress. Calling specific phone "
                                            "type (mobile, home, etc)."),
          [self phoneLabelFromAddressBook]]];
        
    } else {
        [self setStatus:NSLocalizedString(@"calling...", @"Outgoing call in progress.")];
    }
    
    // Make actual call.
    AKSIPCall *aCall = [[[self accountController] account] makeCallTo:[self redialURI]];
    if (aCall != nil) {
        [self setCall:aCall];
        [self setCallActive:YES];
        if (_incomingCallViewController != nil) {
            [_incomingCallViewController setRepresentedObject:aCall];
        }
        if (_activeCallViewController != nil) {
            [_activeCallViewController setRepresentedObject:aCall];
        }
        if (_endedCallViewController != nil) {
            [_endedCallViewController setRepresentedObject:nil];
        }
    } else {
        if (![[self objectInViewControllersAtIndex:0] isEqual:[self endedCallViewController]]) {
            [self removeObjectFromViewControllersAtIndex:0];
            [self addViewController:[self endedCallViewController]];
            [self setCallInfoViewResizingWindow:[[self endedCallViewController] view]];
        }
        [self setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
    }
    
    if ([self isCallUnhandled]) {
        [self setCallUnhandled:NO];
        [[NSApp delegate] updateDockTileBadgeLabel];
    }
}

- (void)toggleCallHold {
    if ([[self call] state] == kAKSIPCallConfirmedState && ![[self call] isOnRemoteHold]) {
        [[self call] toggleHold];
    }
}

- (void)toggleMicrophoneMute {
    if ([[self call] state] != kAKSIPCallConfirmedState) {
        return;
    }
    
    [[self call] toggleMicrophoneMute];
    
    if ([[self call] isMicrophoneMuted]) {
        if (![self isCallOnHold]) {
            [[self activeCallViewController] stopCallTimer];
            [self setStatus:NSLocalizedString(@"mic muted", @"Microphone muted status text.")];
        } else {
            [self setIntermediateStatus:NSLocalizedString(@"mic muted", @"Microphone muted status text.")];
        }
    } else {
        [self setIntermediateStatus:NSLocalizedString(@"mic unmuted", @"Microphone unmuted status text.")];
    }
}

- (void)setIntermediateStatus:(NSString *)newIntermediateStatus {
    if ([self intermediateStatusTimer] != nil) {
        [[self intermediateStatusTimer] invalidate];
    }
    
    [[self activeCallViewController] stopCallTimer];
    [self setStatus:newIntermediateStatus];
    [self setIntermediateStatusTimer:
     [NSTimer scheduledTimerWithTimeInterval:3.0
                                      target:self
                                    selector:@selector(intermediateStatusTimerTick:)
                                    userInfo:nil
                                     repeats:NO]];
}

- (void)intermediateStatusTimerTick:(NSTimer *)theTimer {
    if ([[self call] isOnLocalHold]) {
        [self setStatus:NSLocalizedString(@"on hold", @"Call on local hold status text.")];
    } else if ([[self call] isOnRemoteHold]) {
        [self setStatus:
         NSLocalizedString(@"on remote hold", @"Call on remote hold status text.")];
    } else if ([[self call] isMicrophoneMuted]) {
        [self setStatus:
         NSLocalizedString(@"mic muted", @"Microphone muted status text.")];
    } else if ([[self call] isActive]) {
        [[self activeCallViewController] startCallTimer];
    }
    
    [self setIntermediateStatusTimer:nil];
}

- (void)closeCallWindow {
    if ([[self window] isVisible]) {
        [[self window] performClose:self];
    }
}


#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)notification {
    [super windowWillClose:notification];
    
    if ([self isCallActive]) {
        [self setCallActive:NO];
        [[self activeCallViewController] stopCallTimer];
        
        if ([[self call] isIncoming]) {
            [[NSApp delegate] stopRingtoneTimerIfNeeded];
        }
        
        if ([[[self call] delegate] isEqual:self]) {
            [[self call] setDelegate:nil];
        }
        
        [[self call] hangUp];
        
        [[NSApp delegate] resumeITunesIfNeeded];
    }
    
    [self setCallUnhandled:NO];
    [[NSApp delegate] updateDockTileBadgeLabel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKCallWindowWillCloseNotification object:self];
    
    // View controllers must be nullified because of bindings to callController's |displayedName| and |status|. When
    // this is done in -dealloc this is already too late, and KVO error about releaseing an object that is still being
    // observied is issued.
    _incomingCallViewController = nil;
    _activeCallViewController = nil;
    _endedCallViewController = nil;
}


#pragma mark -
#pragma mark AKSIPCall notifications

- (void)SIPCallCalling:(NSNotification *)notification {
    if ([[self phoneLabelFromAddressBook] length] > 0) {
        [self setStatus:
         [NSString stringWithFormat:
          NSLocalizedString(@"calling %@...",
                            @"Outgoing call in progress. Calling specific phone type (mobile, home, etc)."),
          [self phoneLabelFromAddressBook]]];
    } else {
        [self setStatus:NSLocalizedString(@"calling...", @"Outgoing call in progress.")];
    }
    
    if (![[self objectInViewControllersAtIndex:0] isEqual:[self activeCallViewController]]) {
        [self removeObjectFromViewControllersAtIndex:0];
        [self addViewController:[self activeCallViewController]];
        [self setCallInfoViewResizingWindow:[[self activeCallViewController] view]];
    }
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
    [[[self activeCallViewController] callProgressIndicator] startAnimation:self];
}

- (void)SIPCallEarly:(NSNotification *)notification {
    [[NSApp delegate] pauseITunes];
    
    NSNumber *sipEventCode = [[notification userInfo] objectForKey:@"AKSIPEventCode"];
    
    if (![[self call] isIncoming]) {
        if ([sipEventCode isEqualToNumber:[NSNumber numberWithInt:PJSIP_SC_RINGING]]) {
            [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
            
            [[[self activeCallViewController] view] removeTrackingArea:
             [[self activeCallViewController] callProgressIndicatorTrackingArea]];
            
            [[[self activeCallViewController] view]
             replaceSubview:[[self activeCallViewController] callProgressIndicator]
                       with:[[self activeCallViewController] hangUpButton]];
            
            [self setStatus:NSLocalizedString(@"ringing", @"Remote party ringing.")];
        }
        
        if (![[self objectInViewControllersAtIndex:0] isEqual:[self activeCallViewController]]) {
            [self removeObjectFromViewControllersAtIndex:0];
            [self addViewController:[self activeCallViewController]];
            [self setCallInfoViewResizingWindow:[[self activeCallViewController] view]];
        }
    }
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
}

- (void)SIPCallDidConfirm:(NSNotification *)notification {
    [self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
    [[NSApp delegate] pauseITunes];
    
    if ([[notification object] isIncoming]) {
        [[NSApp delegate] stopRingtoneTimerIfNeeded];
    }
    
    [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
    
    [[[self activeCallViewController] view] removeTrackingArea:
     [[self activeCallViewController] callProgressIndicatorTrackingArea]];
    
    [[[self activeCallViewController] view] replaceSubview:[[self activeCallViewController] callProgressIndicator]
                                                      with:[[self activeCallViewController] hangUpButton]];
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
    
    [self setStatus:@"00:00"];
    
    [[self activeCallViewController] startCallTimer];
    
    if (![[self objectInViewControllersAtIndex:0] isEqual:[self activeCallViewController]]) {
        [self removeObjectFromViewControllersAtIndex:0];
        [self addViewController:[self activeCallViewController]];
        [self setCallInfoViewResizingWindow:[[self activeCallViewController] view]];
    }
    
    if ([[[self activeCallViewController] view] acceptsFirstResponder]) {
        [[self window] makeFirstResponder:[[self activeCallViewController] view]];
    }
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [self setCallActive:NO];
    [[self activeCallViewController] stopCallTimer];
    
    if ([[notification object] isIncoming]) {
        [[NSApp delegate] stopRingtoneTimerIfNeeded];
        [[NSApp delegate] stopUserAttentionTimerIfNeeded];
    }
    
    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    switch ([[self call] lastStatus]) {
        case PJSIP_SC_OK:
            [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];
            break;
            
        case PJSIP_SC_NOT_FOUND:
            [self setStatus:NSLocalizedString(@"Address Not Found", @"Address not found.")];
            break;
            
        case PJSIP_SC_REQUEST_TERMINATED:
            [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];
            break;
            
        case PJSIP_SC_BUSY_HERE:
        case PJSIP_SC_BUSY_EVERYWHERE:
            [self setStatus:NSLocalizedString(@"busy", @"Busy.")];
            break;
            
        case PJSIP_SC_DECLINE:
            [self setStatus:NSLocalizedString(@"call declined", @"Call declined.")];
            break;
            
        default:
            if ([preferredLocalization isEqualToString:@"Russian"]) {
                NSString *statusText = [[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]];
                if (statusText == nil) {
                    [self setStatus:[NSString stringWithFormat:NSLocalizedString(@"Error %d", @"Error #."),
                                     [[self call] lastStatus]]];
                } else {
                    [self setStatus:[[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]]];
                }
            } else {
                [self setStatus:[[self call] lastStatusText]];
            }
            break;
    }
    
    if (![[self objectInViewControllersAtIndex:0] isEqual:[self endedCallViewController]]) {
        [self removeObjectFromViewControllersAtIndex:0];
        [self addViewController:[self endedCallViewController]];
        [self setCallInfoViewResizingWindow:[[self endedCallViewController] view]];
    }
    
    // Disable the redial button to re-enable it after some delay to prevent accidental clicking on in instead of
    // clicking on the hang-up button. Don't forget to re-enable it below!
    [[[self endedCallViewController] redialButton] setEnabled:NO];
    
    [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
    [[[self activeCallViewController] hangUpButton] setEnabled:NO];
    [[[self incomingCallViewController] acceptCallButton] setEnabled:NO];
    [[[self incomingCallViewController] declineCallButton] setEnabled:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:kRedialButtonReenableTime
                                     target:[self endedCallViewController]
                                   selector:@selector(enableRedialButtonTick:)
                                   userInfo:nil
                                    repeats:NO];
    
    [[NSApp delegate] resumeITunesIfNeeded];
    
    // Show Growl notification.
    
    NSString *notificationTitle;
    
    if ([[self nameFromAddressBook] length] > 0) {
        notificationTitle = [self nameFromAddressBook];
        
    } else if ([[self enteredCallDestination] length] > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
        
        if ([[self enteredCallDestination] ak_isTelephoneNumber] && [defaults boolForKey:kFormatTelephoneNumbers]) {
            notificationTitle = [telephoneNumberFormatter stringForObjectValue:[self enteredCallDestination]];
        } else {
            notificationTitle = [self enteredCallDestination];
        }
    } else {
        AKSIPURIFormatter *SIPURIFormatter = [[AKSIPURIFormatter alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [SIPURIFormatter setFormatsTelephoneNumbers:[defaults boolForKey:kFormatTelephoneNumbers]];
        [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
         [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
        notificationTitle = [SIPURIFormatter stringForObjectValue:[[self call] remoteURI]];
    }
    
    if (![NSApp isActive]) {
        [GrowlApplicationBridge notifyWithTitle:notificationTitle
                                    description:[self status]
                               notificationName:kGrowlNotificationCallEnded
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:[self identifier]];
    }
    
    // Optionally close disconnected call window.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shouldCloseWindow = [defaults boolForKey:kAutoCloseCallWindow];
    BOOL shouldCloseMissedWindow = [defaults boolForKey:kAutoCloseMissedCallWindow];
    BOOL missed = [self isCallUnhandled];
    
    if (![self isKindOfClass:[CallTransferController class]]) {
        if ((!missed && shouldCloseWindow) ||
            (missed && shouldCloseWindow && shouldCloseMissedWindow)) {
            
            [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:kCallWindowAutoCloseTime];
        }
    }
}

- (void)SIPCallMediaDidBecomeActive:(NSNotification *)notification {
    if ([self isCallOnHold]) {  // Call is being taken off hold.
        [self setCallOnHold:NO];
        
        [self setIntermediateStatus:NSLocalizedString(@"off hold", @"Call has been taken off hold status text.")];
    }
}

- (void)SIPCallDidLocalHold:(NSNotification *)notification {
    [self setCallOnHold:YES];
    [[self activeCallViewController] stopCallTimer];
    [self setStatus:NSLocalizedString(@"on hold", @"Call on local hold status text.")];
}

- (void)SIPCallDidRemoteHold:(NSNotification *)notification {
    [self setCallOnHold:YES];
    [[self activeCallViewController] stopCallTimer];
    [self setStatus:NSLocalizedString(@"on remote hold", @"Call on remote hold status text.")];
}

- (void)SIPCallTransferStatusDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    BOOL isFinal = [[userInfo objectForKey:@"AKFinalTransferNotification"] boolValue];
    
    if (isFinal && [[self call] transferStatus] == PJSIP_SC_OK) {
        [self hangUpCall];
        [self setStatus:NSLocalizedString(@"call transferred", @"Call transferred.")];
    }
}

@end
