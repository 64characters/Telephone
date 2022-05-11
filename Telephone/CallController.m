//
//  CallController.m
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

#import "CallController.h"

@import UseCases;

#import "AKActiveCallView.h"
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
#import "SIPResponseLocalization.h"

#import "Telephone-Swift.h"


// Window auto-close delay.
static const NSTimeInterval kCallWindowAutoCloseTime = 1.5;

// Redial button re-enable delay.
static const NSTimeInterval kRedialButtonReenableTime = 1.0;

@interface CallController ()

@property(nonatomic, readonly) AKSIPUserAgent *userAgent;

@property(nonatomic, readonly) NSUserDefaults *defaults;

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
        if (_call != nil) {
            self.window.styleMask |= NSWindowStyleMaskClosable;
            [_activeCallViewController allowHangUp];
        }
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

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = [title copy];
        if (self.isWindowLoaded) {
            [self updateWindowTitle];
        }
    }
}

- (BOOL)isCallUnhandled {
    return self.call.isMissed;
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                    accountController:(AccountController *)accountController
                            userAgent:(AKSIPUserAgent *)userAgent
                             delegate:(id<CallControllerDelegate>)delegate {

    if ((self = [self initWithWindowNibName:windowNibName])) {
        _identifier = [NSUUID UUID].UUIDString;
        _accountController = accountController;
        _userAgent = userAgent;
        _delegate = delegate;
        _defaults = NSUserDefaults.standardUserDefaults;
    }
    return self;
}

- (void)dealloc {
    [self setCall:nil];
    [self unsubscribeFromWindowFloatingChanges];
}

- (NSString *)description {
    return [[self call] description];
}

- (void)awakeFromNib {
    [self updateWindowFloating];
    [self subscribeToWindowFloatingChanges];
    [self updateWindowTitle];
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
    [[self call] answer];
    [self removeUserNotification];
}

- (void)hangUpCall {
    [self setCallActive:NO];

    if (_activeCallViewController != nil) {
        [[self activeCallViewController] stopCallTimer];
    }
    
    // If remote party hasn't sent back any replies, call hang-up will not happen immediately. Unsubscribe from any
    // notifications about the call state and set disconnected look to the call window.
    
    if ([[[self call] delegate] isEqual:self]) {
        [[self call] setDelegate:nil];
    }
    
    [[self call] hangUp];
    
    [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];

    [self showEndedCallView];
    
    [self.activeCallViewController showHangUp];
    [self.activeCallViewController disallowHangUp];
    [[[self incomingCallViewController] acceptCallButton] setEnabled:NO];
    [[[self incomingCallViewController] declineCallButton] setEnabled:NO];
    
    [self removeUserNotification];

    // Optionally close call window.
    if ([self.defaults boolForKey:UserDefaultsKeys.autoCloseCallWindow] && ![self isKindOfClass:[CallTransferController class]]) {
        [self performSelector:@selector(closeCallWindow) withObject:nil afterDelay:kCallWindowAutoCloseTime];
    }
}

- (void)redial {
    if (![[self userAgent] isStarted] ||
        ![[self accountController] isEnabled] ||
        ![[self accountController] canMakeCalls] ||
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

    [self prepareForCall];
    
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
    [self.accountController.account makeCallTo:self.redialURI completion:^(AKSIPCall *call) {
        if (call != nil) {
            [self setCall:call];
            [self setCallActive:YES];
        } else {
            [self showEndedCallView];
            [self setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
        }
    }];
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

- (void)prepareForCall {
    self.window.styleMask &= ~NSWindowStyleMaskClosable;
    [self showActiveCallView];
    [self.activeCallViewController showProgress];
    [self.activeCallViewController disallowHangUp];
}

- (void)showActiveCallView {
    [self showViewController:self.activeCallViewController];
}

- (void)showEndedCallView {
    self.window.styleMask |= NSWindowStyleMaskClosable;
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

- (void)removeOrShowUserNotificationOnDisconnectIfNeeded {
    if (![NSApp isActive]) {
        if (self.isCallUnhandled) {
            // Missed calls are shown in call history.
            [self removeUserNotification];
        } else {
            // Notify about an ended call when the app is not visible.
            [self showUserNotification];
        }
    }
}

- (void)removeUserNotification {
    NSUserNotificationCenter *center = NSUserNotificationCenter.defaultUserNotificationCenter;
    for (NSUserNotification *notification in center.deliveredNotifications) {
        if ([notification.identifier isEqualToString:self.identifier]) {
            [center removeDeliveredNotification:notification];
            break;
        }
    }
}

- (void)showUserNotification {
    NSString *notificationTitle;
    if ([[self nameFromAddressBook] length] > 0) {
        notificationTitle = [self nameFromAddressBook];
    } else if ([[self enteredCallDestination] length] > 0) {
        AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
        if ([[self enteredCallDestination] ak_isTelephoneNumber] && [self.defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]) {
            notificationTitle = [telephoneNumberFormatter stringForObjectValue:[self enteredCallDestination]];
        } else {
            notificationTitle = [self enteredCallDestination];
        }
    } else {
        AKSIPURIFormatter *SIPURIFormatter = [[AKSIPURIFormatter alloc] init];
        [SIPURIFormatter setFormatsTelephoneNumbers:[self.defaults boolForKey:UserDefaultsKeys.formatTelephoneNumbers]];
        [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
         [self.defaults boolForKey:UserDefaultsKeys.telephoneNumberFormatterSplitsLastFourDigits]];
        notificationTitle = [SIPURIFormatter stringForObjectValue:[[self call] remoteURI]];
    }
    NSUserNotification *userNotification = [[NSUserNotification alloc] init];
    userNotification.identifier = self.identifier;
    userNotification.title = notificationTitle;
    userNotification.informativeText = self.status;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
}

- (void)updateWindowTitle {
    self.window.title = self.title.length > 0 ? self.title : NSLocalizedString(@"Call", @"Window title.");
}


#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)notification {
    if ([self isCallActive]) {
        [self setCallActive:NO];
        [[self activeCallViewController] stopCallTimer];
        
        if ([[[self call] delegate] isEqual:self]) {
            [[self call] setDelegate:nil];
        }
        
        [[self call] hangUp];
    }
    
    [self.delegate callControllerWillClose:self];

    [_incomingCallViewController removeObservations];
    [_activeCallViewController removeObservations];
    [_endedCallViewController removeObservations];
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect {
    rect.origin.y = [self.window contentRectForFrameRect:self.window.frame].size.height;
    return rect;
}


#pragma mark -
#pragma mark AKSIPCallDelegate

- (void)SIPCallEarly:(NSNotification *)notification {
    if (![[self call] isIncoming]) {
        NSNumber *sipEventCode = [notification userInfo][@"AKSIPEventCode"];
        if ([sipEventCode isEqualToNumber:@(PJSIP_SC_RINGING)]) {
            [self.activeCallViewController showHangUp];
            [self setStatus:NSLocalizedString(@"ringing", @"Remote party ringing.")];
        }
    }
}

- (void)SIPCallDidConfirm:(NSNotification *)notification {
    [self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
    [self showActiveCallView];
    [self.activeCallViewController showHangUp];
    [self setStatus:@"00:00"];
    [[self activeCallViewController] startCallTimer];
}

- (void)SIPCallDidDisconnect:(NSNotification *)notification {
    [self setCallActive:NO];
    [[self activeCallViewController] stopCallTimer];
    
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
                NSString *statusText = LocalizedStringForSIPResponseCode([[self call] lastStatus]);
                if (statusText == nil) {
                    [self setStatus:[NSString stringWithFormat:NSLocalizedString(@"Error %ld", @"Error #."),
                                     [[self call] lastStatus]]];
                } else {
                    [self setStatus:statusText];
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
    
    [self.activeCallViewController showHangUp];
    [self.activeCallViewController disallowHangUp];
    [[[self incomingCallViewController] acceptCallButton] setEnabled:NO];
    [[[self incomingCallViewController] declineCallButton] setEnabled:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:kRedialButtonReenableTime
                                     target:[self endedCallViewController]
                                   selector:@selector(enableRedialButtonTick:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self removeOrShowUserNotificationOnDisconnectIfNeeded];
    
    // Optionally close disconnected call window.
    BOOL shouldCloseWindow = [self.defaults boolForKey:UserDefaultsKeys.autoCloseCallWindow];
    BOOL shouldCloseMissedWindow = [self.defaults boolForKey:UserDefaultsKeys.autoCloseMissedCallWindow];
    BOOL missed = [self isCallUnhandled];
    
    if (![self isKindOfClass:[CallTransferController class]]) {
        if ((!missed && shouldCloseWindow) || (missed && shouldCloseMissedWindow)) {
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

#pragma mark - Window floating

- (void)updateWindowFloating {
    self.window.level = [self.defaults boolForKey:UserDefaultsKeys.keepCallWindowOnTop] ? NSFloatingWindowLevel : NSNormalWindowLevel;
}

- (void)subscribeToWindowFloatingChanges {
    [self.defaults addObserver:self forKeyPath:UserDefaultsKeys.keepCallWindowOnTop options:0 context:NULL];
}

- (void)unsubscribeFromWindowFloatingChanges {
    [self.defaults removeObserver:self forKeyPath:UserDefaultsKeys.keepCallWindowOnTop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.defaults && [keyPath isEqualToString:UserDefaultsKeys.keepCallWindowOnTop]) {
        [self updateWindowFloating];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
