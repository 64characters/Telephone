//
//  CallController.m
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

#import "CallController.h"

@import UseCases;

#import "AKActiveCallView.h"
#import "AKResponsiveProgressIndicator.h"
#import "AKNSString+Creating.h"
#import "AKNSString+Scanning.h"
#import "AKNSWindow+Resizing.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKSIPUserAgent.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountController.h"
#import "ActiveCallViewController.h"
#import "AppController.h"
#import "CallController+Protected.h"
#import "CallTransferController.h"
#import "EndedCallViewController.h"
#import "IncomingCallViewController.h"
#import "UserDefaultsKeys.h"


// Window auto-close delay.
static const NSTimeInterval kCallWindowAutoCloseTime = 1.5;

// Redial button re-enable delay.
static const NSTimeInterval kRedialButtonReenableTime = 1.0;

@interface CallController ()

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;
@property(nonatomic, readonly) id<RingtonePlaybackUseCase> ringtonePlayback;
@property(nonatomic, readonly) id<MusicPlayer> musicPlayer;

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

- (void)setCall:(AKSIPCall *)call {
    if (_call != call) {
        if (_call.delegate == self) {
            _call.delegate = nil;
        }
        _call = call;
        _call.delegate = self;
        _incomingCallViewController.representedObject = _call;
        _activeCallViewController.representedObject = _call;
        _endedCallViewController.representedObject = _call;
    }
}

- (CallTransferController *)callTransferController {
    if (_callTransferController == nil) {
        _callTransferController = [[CallTransferController alloc] initWithSourceCallController:self userAgent:self.userAgent];
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

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                    accountController:(AccountController *)accountController
                            userAgent:(AKSIPUserAgent *)userAgent
                     ringtonePlayback:(id<RingtonePlaybackUseCase>)ringtonePlayback
                          musicPlayer:(id<MusicPlayer>)musicPlayer
                             delegate:(id<CallControllerDelegate>)delegate {

    if ((self = [self initWithWindowNibName:windowNibName])) {
        _identifier = [NSString ak_uuidString];
        _accountController = accountController;
        _userAgent = userAgent;
        _ringtonePlayback = ringtonePlayback;
        _musicPlayer = musicPlayer;
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    [self setCall:nil];
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

    [[self window] makeFirstResponder:newView];
}

- (void)acceptCall {
    if ([[self call] isIncoming]) {
        [self.ringtonePlayback stop];
    }
    
    [self setCallUnhandled:NO];
    [(AppController *)[NSApp delegate] updateDockTileBadgeLabel];
    
    [[self call] answer];
}

- (void)hangUpCall {
    [self setCallActive:NO];
    [self setCallUnhandled:NO];
    
    if (_activeCallViewController != nil) {
        [[self activeCallViewController] stopCallTimer];
    }
    
    if ([[self call] isIncoming]) {
        [self.ringtonePlayback stop];
    }
    
    // If remote party hasn't sent back any replies, call hang-up will not happen immediately. Unsubscribe from any
    // notifications about the call state and set disconnected look to the call window.
    
    if ([[[self call] delegate] isEqual:self]) {
        [[self call] setDelegate:nil];
    }
    
    [[self call] hangUp];
    
    [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];

    [self showEndedCallView];
    
    [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
    [[[self activeCallViewController] hangUpButton] setEnabled:NO];
    [[[self incomingCallViewController] acceptCallButton] setEnabled:NO];
    [[[self incomingCallViewController] declineCallButton] setEnabled:NO];
    
    [self.musicPlayer resume];
    [(AppController *)[NSApp delegate] updateDockTileBadgeLabel];
    
    // Optionally close call window.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCloseCallWindow] &&
        ![self isKindOfClass:[CallTransferController class]]) {
        
        [self performSelector:@selector(closeCallWindow)
                   withObject:nil
                   afterDelay:kCallWindowAutoCloseTime];
    }
}

- (void)redial {
    if (![[self userAgent] isStarted] ||
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

    [self showActiveCallView];
    
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
    } else {
        [self showEndedCallView];
        [self setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
    }
    
    if ([self isCallUnhandled]) {
        [self setCallUnhandled:NO];
        [(AppController *)[NSApp delegate] updateDockTileBadgeLabel];
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

- (void)showActiveCallView {
    [self showViewController:self.activeCallViewController];
}

- (void)showEndedCallView {
    [self showViewController:self.endedCallViewController];
}

- (void)showIncomingCallView {
    [self showViewController:self.incomingCallViewController];
}

- (void)showViewController:(NSViewController *)viewController {
    if ([self shouldShowViewController:viewController]) {
        [self setCallInfoViewResizingWindow:viewController.view];
    }
}

- (BOOL)shouldShowViewController:(NSViewController *)viewController {
    return ![self.callInfoView isEqual:viewController.view];
}


#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)notification {
    if ([self isCallActive]) {
        [self setCallActive:NO];
        [[self activeCallViewController] stopCallTimer];
        
        if ([[self call] isIncoming]) {
            [self.ringtonePlayback stop];
        }
        
        if ([[[self call] delegate] isEqual:self]) {
            [[self call] setDelegate:nil];
        }
        
        [[self call] hangUp];
        
        [self.musicPlayer resume];
    }
    
    [self setCallUnhandled:NO];
    [(AppController *)[NSApp delegate] updateDockTileBadgeLabel];
    
    [self.delegate callControllerWillClose:self];

    [_incomingCallViewController removeObservations];
    [_activeCallViewController removeObservations];
    [_endedCallViewController removeObservations];
}


#pragma mark -
#pragma mark AKSIPCallDelegate

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

    [self showActiveCallView];
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
    [[[self activeCallViewController] callProgressIndicator] startAnimation:self];
}

- (void)SIPCallEarly:(NSNotification *)notification {
    [self.musicPlayer pause];
    
    NSNumber *sipEventCode = [notification userInfo][@"AKSIPEventCode"];
    
    if (![[self call] isIncoming]) {
        if ([sipEventCode isEqualToNumber:@(PJSIP_SC_RINGING)]) {
            [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
            
            [[[self activeCallViewController] view] removeTrackingArea:
             [[self activeCallViewController] callProgressIndicatorTrackingArea]];
            
            [[[self activeCallViewController] view]
             replaceSubview:[[self activeCallViewController] callProgressIndicator]
                       with:[[self activeCallViewController] hangUpButton]];
            
            [self setStatus:NSLocalizedString(@"ringing", @"Remote party ringing.")];
        }

        [self showActiveCallView];
    }
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
}

- (void)SIPCallDidConfirm:(NSNotification *)notification {
    [self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
    [self.musicPlayer pause];
    
    if ([[notification object] isIncoming]) {
        [self.ringtonePlayback stop];
    }
    
    [[[self activeCallViewController] callProgressIndicator] stopAnimation:self];
    
    [[[self activeCallViewController] view] removeTrackingArea:
     [[self activeCallViewController] callProgressIndicatorTrackingArea]];
    
    [[[self activeCallViewController] view] replaceSubview:[[self activeCallViewController] callProgressIndicator]
                                                      with:[[self activeCallViewController] hangUpButton]];
    
    [[[self activeCallViewController] hangUpButton] setEnabled:YES];
    
    [self setStatus:@"00:00"];
    
    [[self activeCallViewController] startCallTimer];
    
    [self showActiveCallView];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [self setCallActive:NO];
    [[self activeCallViewController] stopCallTimer];
    
    if ([[notification object] isIncoming]) {
        [self.ringtonePlayback stop];
        [(AppController *)[NSApp delegate] stopUserAttentionTimerIfNeeded];
    }
    
    NSString *preferredLocalization = [[NSBundle mainBundle] preferredLocalizations][0];
    
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
            if ([preferredLocalization isEqualToString:@"ru"]) {
                NSString *statusText = [(AppController *)[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]];
                if (statusText == nil) {
                    [self setStatus:[NSString stringWithFormat:NSLocalizedString(@"Error %d", @"Error #."),
                                     [[self call] lastStatus]]];
                } else {
                    [self setStatus:[(AppController *)[NSApp delegate] localizedStringForSIPResponseCode:[[self call] lastStatus]]];
                }
            } else {
                [self setStatus:[[self call] lastStatusText]];
            }
            break;
    }

    [self showEndedCallView];
    
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
    
    [self.musicPlayer resume];
    
    // Show user notification.
    
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
        NSUserNotification *userNotification = [[NSUserNotification alloc] init];
        userNotification.title = notificationTitle;
        userNotification.informativeText = self.status;
        userNotification.userInfo = @{kUserNotificationCallControllerIdentifierKey: self.identifier};
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
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
    BOOL isFinal = [userInfo[@"AKFinalTransferNotification"] boolValue];
    
    if (isFinal && [[self call] transferStatus] == PJSIP_SC_OK) {
        [self hangUpCall];
        [self setStatus:NSLocalizedString(@"call transferred", @"Call transferred.")];
    }
}

@end
