//
//  CallController.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "CallController.h"

#import <Growl/Growl.h>

#import "AKActiveCallView.h"
#import "AKNSString+Creating.h"
#import "AKNSString+Scanning.h"
#import "AKNSWindow+Resizing.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKTelephone.h"
#import "AKTelephoneCall.h"
#import "AKTelephoneNumberFormatter.h"

#import "AccountController.h"
#import "AppController.h"
#import "PreferenceController.h"


NSString * const AKTelephoneCallWindowWillCloseNotification
  = @"AKTelephoneCallWindowWillClose";

static const NSTimeInterval kCallWindowAutoCloseTime = 1.5;

@interface CallController ()

- (void)closeCallWindowTick:(NSTimer *)theTimer;

@end

@implementation CallController

@synthesize identifier = identifier_;
@dynamic call;
@dynamic accountController;
@synthesize displayedName = displayedName_;
@synthesize status = status_;
@synthesize nameFromAddressBook = nameFromAddressBook_;
@synthesize phoneLabelFromAddressBook = phoneLabelFromAddressBook_;
@synthesize enteredCallDestination = enteredCallDestination_;
@synthesize redialURI = redialURI_;
@synthesize intermediateStatusTimer = intermediateStatusTimer_;
@synthesize callStartTime = callStartTime_;
@synthesize callTimer = callTimer_;
@synthesize callOnHold = callOnHold_;
@synthesize enteredDTMF = enteredDTMF_;
@synthesize callActive = callActive_;
@synthesize callUnhandled = callUnhandled_;
@synthesize callProgressIndicatorTrackingArea = callProgressIndicatorTrackingArea_;

@synthesize incomingCallView = incomingCallView_;
@synthesize activeCallView = activeCallView_;
@synthesize endedCallView = endedCallView_;
@synthesize hangUpButton = hangUpButton_;
@synthesize acceptCallButton = acceptCallButton_;
@synthesize declineCallButton = declineCallButton_;
@synthesize redialButton = redialButton_;
@synthesize incomingCallDisplayedNameField = incomingCallDisplayedNameField_;
@synthesize activeCallDisplayedNameField = activeCallDisplayedNameField_;
@synthesize endedCallDisplayedNameField = endedCallDisplayedNameField_;
@synthesize incomingCallStatusField = incomingCallStatusField_;
@synthesize activeCallStatusField = activeCallStatusField_;
@synthesize endedCallStatusField = endedCallStatusField_;
@synthesize callProgressIndicator = callProgressIndicator_;

- (AKTelephoneCall *)call {
  return [[call_ retain] autorelease];
}

- (void)setCall:(AKTelephoneCall *)aCall {
  if (call_ != aCall) {
    if ([[call_ delegate] isEqual:self])
      [call_ setDelegate:nil];
    
    [call_ release];
    call_ = [aCall retain];
    
    [call_ setDelegate:self];
  }
}

- (AccountController *)accountController {
  return accountController_;
}

- (void)setAccountController:(AccountController *)anAccountController {
  if (accountController_ == anAccountController)
    return;
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  if (accountController_ != nil)
    [notificationCenter removeObserver:accountController_ name:nil object:self];
  
  if (anAccountController != nil) {
    if ([anAccountController respondsToSelector:@selector(telephoneCallWindowWillClose:)])
      [notificationCenter addObserver:anAccountController
                             selector:@selector(telephoneCallWindowWillClose:)
                                 name:AKTelephoneCallWindowWillCloseNotification
                               object:self];
  }
  
  accountController_ = anAccountController;
}

- (id)initWithAccountController:(AccountController *)anAccountController {
  self = [super initWithWindowNibName:@"Call"];
  if (self == nil)
    return nil;
  
  [self setIdentifier:[NSString ak_uuidString]];
  [self setAccountController:anAccountController];
  [self setCallOnHold:NO];
  enteredDTMF_ = [[NSMutableString alloc] init];
  [self setCallActive:NO];
  [self setCallUnhandled:NO];
  
  return self;
}

- (id)init {
  return [self initWithAccountController:nil];
}

- (void)dealloc {
  [identifier_ release];
  
  [self setCall:nil];
  [self setAccountController:nil];
  [displayedName_ release];
  [status_ release];
  [nameFromAddressBook_ release];
  [phoneLabelFromAddressBook_ release];
  [enteredCallDestination_ release];
  [redialURI_ release];
  [enteredDTMF_ release];
  [callProgressIndicatorTrackingArea_ release];
  
  [incomingCallView_ release];
  [activeCallView_ release];
  [endedCallView_ release];
  [hangUpButton_ release];
  [acceptCallButton_ release];
  [declineCallButton_ release];
  [redialButton_ release];
  [incomingCallDisplayedNameField_ release];
  [activeCallDisplayedNameField_ release];
  [endedCallDisplayedNameField_ release];
  [incomingCallStatusField_ release];
  [activeCallStatusField_ release];
  [endedCallStatusField_ release];
  [callProgressIndicator_ release];
  
  [super dealloc];
}

- (NSString *)description {
  return [[self call] description];
}

- (void)awakeFromNib {
  // Set raised background style for display name and status.
  
  [[[self incomingCallDisplayedNameField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  [[[self activeCallDisplayedNameField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  [[[self endedCallDisplayedNameField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  [[[self incomingCallStatusField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  [[[self activeCallStatusField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  [[[self endedCallStatusField] cell]
   setBackgroundStyle:NSBackgroundStyleRaised];
  
  // Set hang-up button origin manually.
  NSRect hangUpButtonFrame = [[self hangUpButton] frame];
  NSRect progressIndicatorFrame = [[self callProgressIndicator] frame];
  hangUpButtonFrame.origin.x = progressIndicatorFrame.origin.x + 1;
  hangUpButtonFrame.origin.y = progressIndicatorFrame.origin.y + 1;
  [[self hangUpButton] setFrame:hangUpButtonFrame];
  
  [[self hangUpButton] setToolTip:
   NSLocalizedString(@"End Call", @"Hang-up button tooltip.")];
  
  [[self redialButton] setToolTip:
   NSLocalizedString(@"Call Back", @"Redial button tooltip.")];
  
  // Add mouse tracking area to switch between call progress indicator and a
  // hang-up button in the active call view.
  NSRect trackingRect = [[self callProgressIndicator] frame];
  
  NSUInteger trackingOptions
    = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
  
  NSTrackingArea *trackingArea = [[[NSTrackingArea alloc]
                                   initWithRect:trackingRect
                                        options:trackingOptions
                                          owner:self
                                       userInfo:nil]
                                  autorelease];
  
  [[self activeCallView] addTrackingArea:trackingArea];
  [self setCallProgressIndicatorTrackingArea:trackingArea];
}

- (IBAction)acceptCall:(id)sender {
  if ([[self call] isIncoming])
    [[NSApp delegate] stopRingtoneTimerIfNeeded];
  
  [self setCallUnhandled:NO];
  [[NSApp delegate] updateDockTileBadgeLabel];
  
  [[self call] answer];
}

- (IBAction)hangUpCall:(id)sender {
  [self setCallActive:NO];
  [self setCallUnhandled:NO];
  [self stopCallTimer];
  
  if ([[self call] isIncoming])
    [[NSApp delegate] stopRingtoneTimerIfNeeded];
  
  // If remote party hasn't sent back any replies, call hang-up will not happen
  // immediately. Unsubscribe from any notifications about the call state and
  // set disconnected look to the call window.
  
  if ([[[self call] delegate] isEqual:self])
    [[self call] setDelegate:nil];
  
  [[self call] hangUp];
  
  [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];
  [[self window] ak_resizeAndSwapToContentView:[self endedCallView] animate:YES];
  [[self callProgressIndicator] stopAnimation:self];
  [[self hangUpButton] setEnabled:NO];
  [[self acceptCallButton] setEnabled:NO];
  [[self declineCallButton] setEnabled:NO];
  
  [[NSApp delegate] resumeITunesIfNeeded];
  [[NSApp delegate] updateDockTileBadgeLabel];
  
  // Optionally close call window.
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCloseCallWindow] &&
      ![self isCallUnhandled]) {
    [NSTimer scheduledTimerWithTimeInterval:kCallWindowAutoCloseTime
                                     target:self
                                   selector:@selector(closeCallWindowTick:)
                                   userInfo:nil
                                    repeats:NO];
  }
}

- (IBAction)redial:(id)sender {
  if (![[[NSApp delegate] telephone] userAgentStarted] ||
      ![[self accountController] isEnabled] ||
      [[[[self accountController] window] contentView] isEqual:
       [[self accountController] offlineAccountView]] ||
      [self redialURI] == nil) {
    return;
  }
  
  [[self activeCallView] replaceSubview:[self hangUpButton]
                                   with:[self callProgressIndicator]];
  
  [[self activeCallView] addTrackingArea:
   [self callProgressIndicatorTrackingArea]];
  
  [[self callProgressIndicator] startAnimation:self];
  [[self hangUpButton] setEnabled:YES];
  [[self window] setContentView:[self activeCallView]];
  
  if ([[self phoneLabelFromAddressBook] length] > 0) {
    [self setStatus:
     [NSString stringWithFormat:
      NSLocalizedString(@"calling %@...",
                        @"Outgoing call in progress. Calling specific phone "
                        "type (mobile, home, etc)."),
      [self phoneLabelFromAddressBook]]];
    
  } else {
    [self setStatus:NSLocalizedString(@"calling...",
                                      @"Outgoing call in progress.")];
  }
  
  // Make actual call.
  AKTelephoneCall *aCall
    = [[[self accountController] account] makeCallTo:[self redialURI]];
  if (aCall != nil) {
    [self setCall:aCall];
    [self setCallActive:YES];
  } else {
    [[self window] setContentView:[self endedCallView]];
    [self setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
  }
  
  if ([self isCallUnhandled]) {
    [self setCallUnhandled:NO];
    [[NSApp delegate] updateDockTileBadgeLabel];
  }
}

- (IBAction)toggleCallHold:(id)sender {
  [[self call] toggleHold];
}

- (IBAction)toggleMicrophoneMute:(id)sender {
  [[self call] toggleMicrophoneMute];
  
  if ([[self call] isMicrophoneMuted]) {
    [self setIntermediateStatus:
     NSLocalizedString(@"mic muted", @"Microphone muted status text.")];
  } else {
    [self setIntermediateStatus:
     NSLocalizedString(@"mic unmuted", @"Microphone unmuted status text.")];
  }
}

- (void)startCallTimer {
  if ([self callTimer] != nil && [[self callTimer] isValid])
    return;
  
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
  NSInteger seconds = (NSInteger)(now - [self callStartTime]);
  
  if (seconds < 3600)
    [self setStatus:[NSString stringWithFormat:@"%02d:%02d",
                     (seconds / 60) % 60,
                     seconds % 60]];
  else
    [self setStatus:[NSString stringWithFormat:@"%02d:%02d:%02d",
                     (seconds / 3600) % 24,
                     (seconds / 60) % 60,
                     seconds % 60]];
}

- (void)setIntermediateStatus:(NSString *)newIntermediateStatus {
  if ([self intermediateStatusTimer] != nil)
    [[self intermediateStatusTimer] invalidate];
  
  [self stopCallTimer];
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
    [self setStatus:
     NSLocalizedString(@"on hold", @"Call on local hold status text.")];
  } else if ([[self call] isOnRemoteHold]) {
    [self setStatus:
     NSLocalizedString(@"on remote hold", @"Call on remote hold status text.")];
  } else if ([[self call] isActive]) {
    [self startCallTimer];
  }
  
  [self setIntermediateStatusTimer:nil];
}

- (void)closeCallWindowTick:(NSTimer *)theTimer {
  if ([[self window] isVisible])
    [[self window] performClose:self];
}


#pragma mark -
#pragma mark NSWindow delegate methods

// If call window is to be closed, hang up the call and send notification
- (void)windowWillClose:(NSNotification *)notification {
  if ([self isCallActive]) {
    [self setCallActive:NO];
    [self stopCallTimer];
    
    if ([[self call] isIncoming])
      [[NSApp delegate] stopRingtoneTimerIfNeeded];
    
    if ([[[self call] delegate] isEqual:self])
      [[self call] setDelegate:nil];
    
    [[self call] hangUp];
    
    [[NSApp delegate] resumeITunesIfNeeded];
  }
  
  [self setCallUnhandled:NO];
  [[NSApp delegate] updateDockTileBadgeLabel];
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:AKTelephoneCallWindowWillCloseNotification
                 object:self];
}


#pragma mark -
#pragma mark NSResponder overrides

- (void)mouseEntered:(NSEvent *)theEvent {
  // Replace progress indicator with hang-up button.
  [[self activeCallView] replaceSubview:[self callProgressIndicator]
                                   with:[self hangUpButton]];
}

- (void)mouseExited:(NSEvent *)theEvent {
  // Replace hang-up button with progress indicator.
  [[self activeCallView] replaceSubview:[self hangUpButton]
                                   with:[self callProgressIndicator]];
}


#pragma mark -
#pragma mark AKTelephoneCall notifications

- (void)telephoneCallCalling:(NSNotification *)notification {
  if ([[self phoneLabelFromAddressBook] length] > 0) {
    [self setStatus:
     [NSString stringWithFormat:
      NSLocalizedString(@"calling %@...",
                        @"Outgoing call in progress. Calling specific phone "
                        "type (mobile, home, etc)."),
      [self phoneLabelFromAddressBook]]];
  } else {
    [self setStatus:NSLocalizedString(@"calling...",
                                      @"Outgoing call in progress.")];
  }
  
  [[self window] ak_resizeAndSwapToContentView:[self activeCallView] animate:YES];
}

- (void)telephoneCallEarly:(NSNotification *)notification {
  [[NSApp delegate] pauseITunes];
  
  NSNumber *sipEventCode = [[notification userInfo] objectForKey:@"AKSIPEventCode"];
  
  if (![[self call] isIncoming]) {
    if ([sipEventCode isEqualToNumber:[NSNumber numberWithInt:PJSIP_SC_RINGING]]) {
      [[self callProgressIndicator] stopAnimation:self];
      [[self activeCallView] removeTrackingArea:
       [self callProgressIndicatorTrackingArea]];
      [[self activeCallView] replaceSubview:[self callProgressIndicator]
                                       with:[self hangUpButton]];
      [self setStatus:NSLocalizedString(@"ringing", @"Remote party ringing.")];
    }
    
    [[self window] ak_resizeAndSwapToContentView:[self activeCallView] animate:YES];
  }
}

- (void)telephoneCallDidConfirm:(NSNotification *)notification {
  [self setCallStartTime:[NSDate timeIntervalSinceReferenceDate]];
  [[NSApp delegate] pauseITunes];
  
  if ([[notification object] isIncoming])
    [[NSApp delegate] stopRingtoneTimerIfNeeded];
  
  [[self callProgressIndicator] stopAnimation:self];
  [[self activeCallView] removeTrackingArea:
   [self callProgressIndicatorTrackingArea]];
  [[self activeCallView] replaceSubview:[self callProgressIndicator]
                                   with:[self hangUpButton]];
  [self setStatus:@"00:00"];
  
  [self startCallTimer];
  
  [[self window] ak_resizeAndSwapToContentView:[self activeCallView] animate:YES];
  if ([[self activeCallView] acceptsFirstResponder])
    [[self window] makeFirstResponder:[self activeCallView]];
}

- (void)telephoneCallDidDisconnect:(NSNotification *)notification {
  [self setCallActive:NO];
  [self stopCallTimer];
  
  if ([[notification object] isIncoming]) {
    // Stop ringing sound.
    [[NSApp delegate] stopRingtoneTimerIfNeeded];
    
    // Stop bouncing icon in the Dock.
    [[NSApp delegate] stopUserAttentionTimerIfNeeded];
  }
  
  NSString *preferredLocalization
    = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
  
  switch ([[self call] lastStatus]) {
      case PJSIP_SC_OK:
        [self setStatus:NSLocalizedString(@"call ended", @"Call ended.")];
        break;
      
      case PJSIP_SC_NOT_FOUND:
        [self setStatus:NSLocalizedString(@"Address Not Found",
                                          @"Address not found.")];
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
          NSString *statusText
            = [[NSApp delegate] localizedStringForSIPResponseCode:
               [[self call] lastStatus]];
          if (statusText == nil) {
            [self setStatus:[NSString stringWithFormat:
                             NSLocalizedString(@"Error %d", @"Error #."),
                             [[self call] lastStatus]]];
          } else {
            [self setStatus:[[NSApp delegate] localizedStringForSIPResponseCode:
                             [[self call] lastStatus]]];
          }
        } else {
          [self setStatus:[[self call] lastStatusText]];
        }
        break;
  }
  
  [[self window] ak_resizeAndSwapToContentView:[self endedCallView] animate:YES];
  
  [[self callProgressIndicator] stopAnimation:self];
  [[self hangUpButton] setEnabled:NO];
  [[self acceptCallButton] setEnabled:NO];
  [[self declineCallButton] setEnabled:NO];
  
  [[NSApp delegate] resumeITunesIfNeeded];
  
  // Show Growl notification.
  
  NSString *notificationTitle;
  
  if ([[self nameFromAddressBook] length] > 0) {
    notificationTitle = [self nameFromAddressBook];
    
  } else if ([[self enteredCallDestination] length] > 0) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AKTelephoneNumberFormatter *telephoneNumberFormatter
      = [[[AKTelephoneNumberFormatter alloc] init] autorelease];
    
    if ([[self enteredCallDestination] ak_isTelephoneNumber] &&
        [defaults boolForKey:kFormatTelephoneNumbers]) {
      notificationTitle = [telephoneNumberFormatter stringForObjectValue:
                           [self enteredCallDestination]];
    } else {
      notificationTitle = [self enteredCallDestination];
    }
  } else {
    AKSIPURIFormatter *SIPURIFormatter
      = [[[AKSIPURIFormatter alloc] init] autorelease];
    notificationTitle
      = [SIPURIFormatter stringForObjectValue:[[self call] remoteURI]];
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
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kAutoCloseCallWindow] &&
      ![self isCallUnhandled]) {
    [NSTimer scheduledTimerWithTimeInterval:kCallWindowAutoCloseTime
                                     target:self
                                   selector:@selector(closeCallWindowTick:)
                                   userInfo:nil
                                    repeats:NO];
  }
}

- (void)telephoneCallMediaDidBecomeActive:(NSNotification *)notification {
  if ([self isCallOnHold]) {
    [self startCallTimer];
    [self setCallOnHold:NO];
  }
}

- (void)telephoneCallDidLocalHold:(NSNotification *)notification {
  [self setCallOnHold:YES];
  [self stopCallTimer];
  [self setStatus:NSLocalizedString(@"on hold",
                                    @"Call on local hold status text.")];
}

- (void)telephoneCallDidRemoteHold:(NSNotification *)notification {
  [self setCallOnHold:YES];
  [self stopCallTimer];
  [self setStatus:NSLocalizedString(@"on remote hold",
                                    @"Call on remote hold status text.")];
}


#pragma mark -
#pragma mark AKActiveCallViewDelegate protocol

- (void)activeCallView:(AKActiveCallView *)sender
        didReceiveText:(NSString *)aString {
  NSCharacterSet *commandsCharacterSet
    = [NSCharacterSet characterSetWithCharactersInString:@"mMhH"];
  NSCharacterSet *microphoneMuteCharacterSet
    = [NSCharacterSet characterSetWithCharactersInString:@"mM"];
  NSCharacterSet *holdCharacterSet
    = [NSCharacterSet characterSetWithCharactersInString:@"hH"];
  NSCharacterSet *DTMFCharacterSet
    = [NSCharacterSet characterSetWithCharactersInString:@"0123456789*#"];
  
  unichar firstCharacter = [aString characterAtIndex:0];
  if ([commandsCharacterSet characterIsMember:firstCharacter]) {
    if ([microphoneMuteCharacterSet characterIsMember:firstCharacter]) {
      [self toggleMicrophoneMute:nil];
    } else if ([holdCharacterSet characterIsMember:firstCharacter]) {
      [self toggleCallHold:nil];
    }
    
  } else {
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
        [[self window] setTitle:[self displayedName]];
        
        if ([[[self activeCallDisplayedNameField] cell] lineBreakMode]
            != NSLineBreakByTruncatingHead) {
          [[[self activeCallDisplayedNameField] cell]
           setLineBreakMode:NSLineBreakByTruncatingHead];
          [[self endedCallDisplayedNameField] setSelectable:YES];
        }
        
        [self setDisplayedName:aString];
        
      } else {
        [[self enteredDTMF] appendString:aString];
        [self setDisplayedName:[self enteredDTMF]];
      }
      
      [[self call] sendDTMFDigits:aString];
    }
  }
}


#pragma mark -
#pragma mark NSMenuValidation protocol

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if ([menuItem action] == @selector(toggleMicrophoneMute:)) {
    if ([[self call] isMicrophoneMuted])
      [menuItem setTitle:NSLocalizedString(@"Unmute",
                                           @"Unmute. Call menu item.")];
    else
      [menuItem setTitle:NSLocalizedString(@"Mute", @"Mute. Call menu item.")];
    
    if ([[self call] state] == kAKTelephoneCallConfirmedState)
      return YES;
    
    return NO;
    
  } else if ([menuItem action] == @selector(toggleCallHold:)) {
    if ([[self call] state] == kAKTelephoneCallConfirmedState &&
        [[self call] isOnLocalHold])
      [menuItem setTitle:NSLocalizedString(@"Resume",
                                           @"Resume. Call menu item.")];
    else
      [menuItem setTitle:NSLocalizedString(@"Hold", @"Hold. Call menu item.")];
    
    if ([[self call] state] == kAKTelephoneCallConfirmedState &&
        ![[self call] isOnRemoteHold])
      return YES;
    
    return NO;
    
  } else if ([menuItem action] == @selector(hangUpCall:)) {
    if ([self isCallActive])
      return YES;
    
    return NO;
  }
  
  return YES;
}

@end
