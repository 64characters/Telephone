//
//  AccountController.m
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

#import "AccountController.h"

#import <AddressBook/AddressBook.h>
#import <Growl/Growl.h>

#import "AKABAddressBook+Localizing.h"
#import "AKABRecord+Querying.h"
#import "AKKeychain.h"
#import "AKNetworkReachability.h"
#import "AKNSString+Scanning.h"
#import "AKNSWindow+Resizing.h"
#import "AKSIPAccount.h"
#import "AKSIPCall.h"
#import "AKSIPURI.h"
#import "AKSIPURIFormatter.h"
#import "AKSIPUserAgent.h"
#import "AKTelephoneNumberFormatter.h"

#import "ActiveAccountViewController.h"
#import "ActiveCallViewController.h"
#import "AppController.h"
#import "AuthenticationFailureController.h"
#import "CallController.h"
#import "CallTransferController.h"
#import "EndedCallViewController.h"
#import "IncomingCallViewController.h"
#import "PreferencesController.h"


// Account state pop-up button widths.
//
// English.
static const CGFloat kAccountStatePopUpOfflineEnglishWidth = 58.0;
static const CGFloat kAccountStatePopUpAvailableEnglishWidth = 69.0;
static const CGFloat kAccountStatePopUpUnavailableEnglishWidth = 81.0;
static const CGFloat kAccountStatePopUpConnectingEnglishWidth = 90.0;
//
// Russian.
static const CGFloat kAccountStatePopUpOfflineRussianWidth = 65.0;
static const CGFloat kAccountStatePopUpAvailableRussianWidth = 73.0;
static const CGFloat kAccountStatePopUpUnavailableRussianWidth = 85.0;
static const CGFloat kAccountStatePopUpConnectingRussianWidth = 96.0;
//
// German.
static const CGFloat kAccountStatePopUpOfflineGermanWidth = 58.0;
static const CGFloat kAccountStatePopUpAvailableGermanWidth = 74.0;
static const CGFloat kAccountStatePopUpUnavailableGermanWidth = 101.0;
static const CGFloat kAccountStatePopUpConnectingGermanWidth = 88.0;

NSString * const kEmailSIPLabel = @"sip";


@interface AccountController ()

// Timer for account re-registration in case of registration error.
@property (nonatomic, strong) NSTimer *reRegistrationTimer;

// Method to be called when account re-registration timer fires.
- (void)reRegistrationTimerTick:(NSTimer *)theTimer;

@end

@implementation AccountController

@synthesize activeAccountViewController = _activeAccountViewController;
@synthesize authenticationFailureController = _authenticationFailureController;

- (void)setEnabled:(BOOL)flag {
    _enabled = flag;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (flag) {
        AKNetworkReachability *reachability
            = [AKNetworkReachability networkReachabilityWithHost:[[self account] registrar]];
        [self setRegistrarReachability:reachability];
        
        if (reachability != nil) {
            [notificationCenter addObserver:self
                                   selector:@selector(networkReachabilityDidBecomeReachable:)
                                       name:AKNetworkReachabilityDidBecomeReachableNotification
                                     object:reachability];
        }
    } else {
        if ([self registrarReachability] != nil) {
            [notificationCenter removeObserver:self
                                          name:AKNetworkReachabilityDidBecomeReachableNotification
                                        object:[self registrarReachability]];
            
            [self setRegistrarReachability:nil];
        }
    }
}

- (BOOL)isAccountRegistered {
    return [[self account] isRegistered];
}

- (void)setAccountRegistered:(BOOL)flag {
    if ([self reRegistrationTimer] != nil) {
        [[self reRegistrationTimer] invalidate];
        [self setReRegistrationTimer:nil];
    }
    
    if ([[self account] identifier] != kAKSIPUserAgentInvalidIdentifier) {
        // Account has been added.
        [self showConnectingState];
        
        [[self account] setRegistered:flag];
        
    } else {
        NSString *serviceName = [NSString stringWithFormat:@"SIP: %@",
                                 [[self account] registrar]];
        NSString *password = [AKKeychain passwordForServiceName:serviceName accountName:[[self account] username]];
        
        [self showConnectingState];
        
        BOOL accountAdded = [[[NSApp delegate] userAgent] addAccount:[self account] withPassword:password];
        
        // Error connecting to registrar.
        if (accountAdded &&
            ![self isAccountRegistered] &&
            [[self account] registrationExpireTime] < 0 &&
            [[[NSApp delegate] userAgent] isStarted]) {
            
            [self showUnavailableState];
            
            // Schedule account automatic re-registration timer.
            if ([self reRegistrationTimer] == nil) {
                NSTimeInterval reregistrationTimeInterval = (NSTimeInterval)[[self account] reregistrationTime];
                
                [self setReRegistrationTimer:
                 [NSTimer scheduledTimerWithTimeInterval:reregistrationTimeInterval
                                                  target:self
                                                selector:@selector(reRegistrationTimerTick:)
                                                userInfo:nil
                                                 repeats:YES]];
            }
            
            if ([self shouldPresentRegistrationError]) {
                NSString *statusText;
                NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
                if ([preferredLocalization isEqualToString:@"Russian"]) {
                    statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                                  [[self account] registrationStatus]];
                } else {
                    statusText = [[self account] registrationStatusText];
                }
                
                NSString *error;
                if (statusText == nil) {
                    error = [NSString stringWithFormat:
                             NSLocalizedString(@"Error %d", @"Error #."),
                             [[self account] registrationStatus]];
                    error = [error stringByAppendingString:@"."];
                } else {
                    error = [NSString stringWithFormat:
                             NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.", @"Error description."),
                             [[self account] registrationStatus], statusText];
                }
                
                [self showRegistrarConnectionErrorSheetWithError:error];
            }
            
            [self setShouldPresentRegistrationError:NO];
        }
    }
}

- (ActiveAccountViewController *)activeAccountViewController {
    if (_activeAccountViewController == nil) {
        _activeAccountViewController = [[ActiveAccountViewController alloc] initWithAccountController:self
                                                                                     windowController:self];
    }
    
    return _activeAccountViewController;
}

- (AuthenticationFailureController *)authenticationFailureController {
    if (_authenticationFailureController == nil) {
        _authenticationFailureController = [[AuthenticationFailureController alloc] initWithAccountController:self];
    }
    
    return _authenticationFailureController;
}

- (id)initWithSIPAccount:(AKSIPAccount *)anAccount {
    self = [super initWithWindowNibName:@"Account"];
    if (self == nil) {
        return nil;
    }
    
    [self setAccount:anAccount];
    _callControllers = [[NSMutableArray alloc] init];
    [self setSubstitutesPlusCharacter:NO];
    
    [self setAttemptingToRegisterAccount:NO];
    [self setAttemptingToUnregisterAccount:NO];
    [self setShouldPresentRegistrationError:NO];
    [self setAccountUnavailable:NO];
    [self setShouldMakeCall:NO];
    
    [[self account] setDelegate:self];
    
    [[self window] setTitle:[[self account] SIPAddress]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SIPUserAgentDidFinishStarting:)
                                                 name:AKSIPUserAgentDidFinishStartingNotification
                                               object:nil];
    
    return self;
}

- (id)initWithFullName:(NSString *)aFullName
            SIPAddress:(NSString *)aSIPAddress
             registrar:(NSString *)aRegistrar
                 realm:(NSString *)aRealm
              username:(NSString *)aUsername {
    
    AKSIPAccount *anAccount = [AKSIPAccount SIPAccountWithFullName:aFullName
                                                        SIPAddress:aSIPAddress
                                                         registrar:aRegistrar
                                                             realm:aRealm
                                                          username:aUsername];
    
    return [self initWithSIPAccount:anAccount];
}

- (void)dealloc {
    for (CallController *aCallController in [self callControllers]) {
        [aCallController close];
    }
    
    if ([[[self account] delegate] isEqual:self]) {
        [[self account] setDelegate:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Close authentication failure sheet if it's raised.
    [[_authenticationFailureController cancelButton] performClick:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ controller", [self account]];
}

- (void)awakeFromNib {
    [self setShouldCascadeWindows:NO];
    [[self window] setFrameAutosaveName:[[self account] SIPAddress]];
}

- (void)removeAccountFromUserAgent {
    NSAssert([self isEnabled], @"Account conroller must be enabled to remove account from the user agent.");
    
    if ([self reRegistrationTimer] != nil) {
        [[self reRegistrationTimer] invalidate];
        [self setReRegistrationTimer:nil];
    }
    
    [self showOfflineState];
    [[[NSApp delegate] userAgent] removeAccount:[self account]];
}

- (void)makeCallToURI:(AKSIPURI *)destinationURI
        phoneLabel:(NSString *)phoneLabel
        callTransferController:(CallTransferController *)callTransferController {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
    [telephoneNumberFormatter setSplitsLastFourDigits:
     [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
    
    NSString *enteredCallDestinationString = [[destinationURI user] copy];
    
    // Make user part a string of contiguous digits if needed.
    if (![[destinationURI user] ak_hasLetters]) {
        [destinationURI setUser:[telephoneNumberFormatter telephoneNumberFromString:[destinationURI user]]];
    }
    
    // Replace plus character if needed.
    if ([self substitutesPlusCharacter] &&
        [[destinationURI user] hasPrefix:@"+"]) {
        [destinationURI setUser:[[destinationURI user]
                                 stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                         withString:[self plusCharacterSubstitution]]];
        enteredCallDestinationString = [enteredCallDestinationString
                                        stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                withString:[self plusCharacterSubstitution]];
    }
    
    // If it's a regular call, not a transfer, create the new CallController.
    CallController *aCallController;
    if (callTransferController == nil) {
        aCallController = [[CallController alloc] initWithWindowNibName:@"Call" accountController:self];
    } else {
        aCallController = callTransferController;
    }
    
    [aCallController setNameFromAddressBook:[destinationURI displayName]];
    [aCallController setPhoneLabelFromAddressBook:phoneLabel];
    [aCallController setEnteredCallDestination:enteredCallDestinationString];
    [[self callControllers] addObject:aCallController];
    
    // Set title.
    if ([[destinationURI host] length] > 0) {
        [[aCallController window] setTitle:[destinationURI SIPAddress]];
        
    } else if (![enteredCallDestinationString ak_hasLetters]) {
        if ([enteredCallDestinationString ak_isTelephoneNumber] && [defaults boolForKey:kFormatTelephoneNumbers]) {
            [[aCallController window] setTitle:
             [telephoneNumberFormatter stringForObjectValue:enteredCallDestinationString]];
        } else {
            [[aCallController window] setTitle:enteredCallDestinationString];
        }
    } else {
        NSString *SIPAddress = [NSString stringWithFormat:@"%@@%@",
                                [destinationURI user], [[[self account] registrationURI] host]];
        [[aCallController window] setTitle:SIPAddress];
    }
    
    // Set displayed name.
    if ([[destinationURI displayName] length] > 0) {
        [aCallController setDisplayedName:[destinationURI displayName]];
        
    } else {
        if ([[destinationURI host] length] > 0) {
            [aCallController setDisplayedName:[destinationURI SIPAddress]];
            
        } else if ([enteredCallDestinationString ak_isTelephoneNumber] &&
                   [defaults boolForKey:kFormatTelephoneNumbers]) {
            
            [aCallController setDisplayedName:
             [telephoneNumberFormatter stringForObjectValue:enteredCallDestinationString]];
            
        } else {
            [aCallController setDisplayedName:enteredCallDestinationString];
        }
    }
    
    // Clean display-name part of the destination URI to prevent another call
    // party from seeing local Address Book records.
    [destinationURI setDisplayName:nil];
    
    if ([[destinationURI host] length] == 0) {
        [destinationURI setHost:[[[self account] registrationURI] host]];
    }
    
    // Set URI for redial.
    [aCallController setRedialURI:destinationURI];
    
    if (callTransferController == nil) {
        [aCallController addViewController:[aCallController activeCallViewController]];
        [[aCallController window] setContentView:[[aCallController activeCallViewController] view]];
    }
    
    if ([phoneLabel length] > 0) {
        [aCallController setStatus:
         [NSString stringWithFormat:NSLocalizedString(@"calling %@...",
                                                      @"Outgoing call in progress. Calling specific phone "
                                                       "type (mobile, home, etc)."), phoneLabel]];
    } else {
        [aCallController setStatus:NSLocalizedString(@"calling...", @"Outgoing call in progress.")];
    }
    
    if (callTransferController == nil) {
        [aCallController showWindow:self];
    }
    
    // Finally, make a call.
    AKSIPCall *aCall = [[self account] makeCallTo:destinationURI];
    if (aCall != nil) {
        [aCallController setCall:aCall];
        [aCallController setCallActive:YES];
    } else {
        [aCallController removeObjectFromViewControllersAtIndex:0];
        [aCallController addViewController:[aCallController endedCallViewController]];
        [[aCallController window] setContentView:[[aCallController endedCallViewController] view]];
        [aCallController setStatus:NSLocalizedString(@"Call Failed", @"Call failed.")];
    }
}

- (void)makeCallToURI:(AKSIPURI *)destinationURI phoneLabel:(NSString *)phoneLabel {
    [self makeCallToURI:destinationURI phoneLabel:phoneLabel callTransferController:nil];
}

- (IBAction)changeAccountState:(id)sender {
    if ([self reRegistrationTimer] != nil) {
        [[self reRegistrationTimer] invalidate];
        [self setReRegistrationTimer:nil];
    }
    
    NSInteger selectedItemTag = [[sender selectedItem] tag];
    
    if (selectedItemTag == kSIPAccountOffline) {
        [self setAccountUnavailable:NO];
        [self removeAccountFromUserAgent];
        
    } else if (selectedItemTag == kSIPAccountUnavailable) {
        // Unregister account only if it is registered or it wasn't added to the user agent.
        if ([self isAccountRegistered] || [[self account] identifier] == kAKSIPUserAgentInvalidIdentifier) {
            [self setAccountUnavailable:YES];
            [self setAttemptingToUnregisterAccount:YES];
            [self setShouldPresentRegistrationError:YES];
            [self setAccountRegistered:NO];
        }
        
    } else if (selectedItemTag == kSIPAccountAvailable) {
        [self setAccountUnavailable:NO];
        [self setAttemptingToRegisterAccount:YES];
        [self setShouldPresentRegistrationError:YES];
        [self setAccountRegistered:YES];
    }
}

- (void)showRegistrarConnectionErrorSheetWithError:(NSString *)error {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:
                           NSLocalizedString(@"Could not register with %@.", @"Registrar connection error."),
                           [[self account] registrar]]];
    
    if (error == nil) {
        [alert setInformativeText:
         [NSString stringWithFormat:
          NSLocalizedString(@"Please check network connection and Registry Server settings.",
                            @"Registrar connection error informative text."),
          [[self account] registrar]]];
    } else {
        [alert setInformativeText:error];
    }
    
    [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}


- (void)showAvailableState {
    NSSize buttonSize = [[self accountStatePopUp] frame].size;
    
    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([preferredLocalization isEqualToString:@"English"]) {
        buttonSize.width = kAccountStatePopUpAvailableEnglishWidth;
    } else if ([preferredLocalization isEqualToString:@"Russian"]) {
        buttonSize.width = kAccountStatePopUpAvailableRussianWidth;
    } else if ([preferredLocalization isEqualToString:@"German"]) {
        buttonSize.width = kAccountStatePopUpAvailableGermanWidth;
    }
    
    [[self accountStatePopUp] setFrameSize:buttonSize];
    [[self accountStatePopUp] setTitle:NSLocalizedString(@"Available", @"Account registration Available menu item.")];
    
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountAvailable] setState:NSOnState];
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountUnavailable] setState:NSOffState];
    
    if ([self countOfViewControllers] == 0) {
        [self addViewController:[self activeAccountViewController]];
        [[self window] setContentView:[[self activeAccountViewController] view]];
        
        if ([[[self activeAccountViewController] callDestinationField] acceptsFirstResponder]) {
            [[self window] makeFirstResponder:[[self activeAccountViewController] callDestinationField]];
        }
    }
}

- (void)showUnavailableState {
    NSSize buttonSize = [[self accountStatePopUp] frame].size;
    
    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([preferredLocalization isEqualToString:@"English"]) {
        buttonSize.width = kAccountStatePopUpUnavailableEnglishWidth;
    } else if ([preferredLocalization isEqualToString:@"Russian"]) {
        buttonSize.width = kAccountStatePopUpUnavailableRussianWidth;
    } else if ([preferredLocalization isEqualToString:@"German"]) {
        buttonSize.width = kAccountStatePopUpUnavailableGermanWidth;
    }
    
    [[self accountStatePopUp] setFrameSize:buttonSize];
    [[self accountStatePopUp] setTitle:
     NSLocalizedString(@"Unavailable", @"Account registration Unavailable menu item.")];
    
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountAvailable] setState:NSOffState];
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountUnavailable] setState:NSOnState];
    
    if ([self countOfViewControllers] == 0) {
        [self addViewController:[self activeAccountViewController]];
        [[self window] setContentView:[[self activeAccountViewController] view]];
        
        if ([[[self activeAccountViewController] callDestinationField] acceptsFirstResponder]) {
            [[self window] makeFirstResponder:[[self activeAccountViewController] callDestinationField]];
        }
    }
}

- (void)showOfflineState {
    NSSize buttonSize = [[self accountStatePopUp] frame].size;
    
    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([preferredLocalization isEqualToString:@"English"]) {
        buttonSize.width = kAccountStatePopUpOfflineEnglishWidth;
    } else if ([preferredLocalization isEqualToString:@"Russian"]) {
        buttonSize.width = kAccountStatePopUpOfflineRussianWidth;
    } else if ([preferredLocalization isEqualToString:@"German"]) {
        buttonSize.width = kAccountStatePopUpOfflineGermanWidth;
    }
    
    [[self accountStatePopUp] setFrameSize:buttonSize];
    [[self accountStatePopUp] setTitle:NSLocalizedString(@"Offline", @"Account registration Offline menu item.")];
    
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountAvailable] setState:NSOffState];
    [[[[self accountStatePopUp] menu] itemWithTag:kSIPAccountUnavailable] setState:NSOffState];
    
    [self removeViewController:[self activeAccountViewController]];
    NSRect frame = [[[self window] contentView] frame];
    NSView *emptyView = [[NSView alloc] initWithFrame:frame];
    NSUInteger autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [emptyView setAutoresizingMask:autoresizingMask];
    [[self window] setContentView:emptyView];
}

- (void)showConnectingState {
    NSSize buttonSize = [[self accountStatePopUp] frame].size;
    
    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    if ([preferredLocalization isEqualToString:@"English"]) {
        buttonSize.width = kAccountStatePopUpConnectingEnglishWidth;
    } else if ([preferredLocalization isEqualToString:@"Russian"]) {
        buttonSize.width = kAccountStatePopUpConnectingRussianWidth;
    } else if ([preferredLocalization isEqualToString:@"German"]) {
        buttonSize.width = kAccountStatePopUpConnectingGermanWidth;
    }
    
    [[self accountStatePopUp] setFrameSize:buttonSize];
    [[self accountStatePopUp] setTitle:
     NSLocalizedString(@"Connecting...", @"Account registration Connecting... menu item.")];
}

- (void)reRegistrationTimerTick:(NSTimer *)theTimer {
    [[self account] setRegistered:YES];
}

- (void)handleCatchedURL {
    AKSIPURI *uri = [AKSIPURI SIPURIWithString:[self catchedURLString]];
    
    [self setCatchedURLString:nil];
    
    if ([[uri user] length] == 0) {
        return;
    }
    
    [[[self activeAccountViewController] callDestinationField] setTokenStyle:NSPlainTextTokenStyle];
    
    NSString *theString;
    if ([[uri host] length] > 0) {
        theString = [uri SIPAddress];
    } else {
        theString = [uri user];
    }
    
    [[[self activeAccountViewController] callDestinationField] setStringValue:theString];
    
    [[self activeAccountViewController] makeCall:nil];
}


#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowDidLoad {
    [self showOfflineState];
}

- (BOOL)windowShouldClose:(id)sender {
    BOOL result = YES;
    
    if (sender == [self window]) {
        [[self window] orderOut:self];
        result = NO;
    }
    
    return result;
}


#pragma mark -
#pragma mark AKSIPAccount notifications

// When account registration changes, make appropriate modifications to the UI. A call can also be made from here if
// the user called from the Address Book or from the application URL handler.
- (void)SIPAccountRegistrationDidChange:(NSNotification *)notification {
    // Account identifier can be kAKSIPUserAgentInvalidIdentifier if notification on the main thread was delivered after
    // user agent had removed the account. Don't bother in that case.
    if ([[self account] identifier] == kAKSIPUserAgentInvalidIdentifier) {
        return;
    }
    
    if ([[self account] isRegistered]) {
        if ([self reRegistrationTimer] != nil) {
            [[self reRegistrationTimer] invalidate];
            [self setReRegistrationTimer:nil];
        }
        
        // If the account was offline and the user chose Unavailable state, setAccountRegistered:NO will add the account
        // to the user agent. User agent will register the account. Set the account to Unavailable (unregister it) here.
        if ([self attemptingToUnregisterAccount]) {
            [self setAccountRegistered:NO];
            
        } else {
            [self setAccountUnavailable:NO];
            [self showAvailableState];
            
            // The user could initiate a call from the Address Book plug-in.
            if ([self shouldMakeCall]) {
                // Explicitly display registered mode before calling.
                [[self window] display];
                
                [self setShouldMakeCall:NO];
                [[self activeAccountViewController] makeCall:nil];
            }
            
            // The user could click a URL.
            if ([self catchedURLString] != nil) {
                // Explicitly display registered mode before calling.
                [[self window] display];
                
                [self handleCatchedURL];
            }
        }
        
    } else {
        [self showUnavailableState];
        
        // Handle authentication failure
        if ([[self account] registrationStatus] == PJSIP_EFAILEDCREDENTIAL) {
            [[[self authenticationFailureController] informativeText] setStringValue:
             [NSString stringWithFormat:
              NSLocalizedString(@"Telephone was unable to login to %@. "
                                 "Change user name or password and try again.",
                                @"Registrar authentication failed."),
              [[self account] registrar]]];
            
            NSString *serviceName = [NSString stringWithFormat:@"SIP: %@",
                                     [[self account] registrar]];
            NSString *password = [AKKeychain passwordForServiceName:serviceName accountName:[[self account] username]];
            
            [[[self authenticationFailureController] usernameField] setStringValue:[[self account] username]];
            [[[self authenticationFailureController] passwordField] setStringValue:password];
            
            [NSApp beginSheet:[[self authenticationFailureController] window]
               modalForWindow:[self window]
                modalDelegate:nil
               didEndSelector:NULL
                  contextInfo:NULL];
            
        } else if (([[self account] registrationStatus] / 100 != 2) &&
                   ([[self account] registrationExpireTime] < 0)) {
            // Raise a sheet if connection to the registrar failed. If last registration status is 2xx and expiration
            // interval is less than zero, it is unregistration, not failure. Condition of failure is: last registration
            // status != 2xx AND expiration interval < 0.
            
            if ([[[NSApp delegate] userAgent] isStarted]) {
                if ([self shouldPresentRegistrationError]) {
                    NSString *statusText;
                    NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
                    if ([preferredLocalization isEqualToString:@"Russian"]) {
                        statusText = [[NSApp delegate] localizedStringForSIPResponseCode:
                                      [[self account] registrationStatus]];
                    } else {
                        statusText = [[self account] registrationStatusText];
                    }
                    
                    NSString *error;
                    if (statusText == nil) {
                        error = [NSString stringWithFormat:NSLocalizedString(@"Error %d", @"Error #."),
                                 [[self account] registrationStatus]];
                        error = [error stringByAppendingString:@"."];
                    } else {
                        error = [NSString stringWithFormat:
                                 NSLocalizedString(@"The error was: \\U201C%d %@\\U201D.", @"Error description."),
                                 [[self account] registrationStatus], statusText];
                    }
                    
                    [self showRegistrarConnectionErrorSheetWithError:error];
                    
                } else {
                    // Schedule account automatic re-registration timer.
                    if ([self reRegistrationTimer] == nil) {
                        NSTimeInterval reregistrationTimeInterval = (NSTimeInterval)[[self account] reregistrationTime];
                        
                        [self setReRegistrationTimer:
                         [NSTimer scheduledTimerWithTimeInterval:reregistrationTimeInterval
                                                          target:self
                                                        selector:@selector(reRegistrationTimerTick:)
                                                        userInfo:nil
                                                         repeats:YES]];
                    }
                }
            }
        }
    }
    
    [self setAttemptingToRegisterAccount:NO];
    [self setAttemptingToUnregisterAccount:NO];
    [self setShouldPresentRegistrationError:NO];
}

- (void)SIPAccountWillRemove:(NSNotification *)notification {
    if ([self reRegistrationTimer] != nil) {
        [[self reRegistrationTimer] invalidate];
        [self setReRegistrationTimer:nil];
    }
}


#pragma mark -
#pragma mark CallController notifications

- (void)callWindowWillClose:(NSNotification *)notification {
    CallController *aCallController = [notification object];
    [[self callControllers] removeObject:aCallController];
}


#pragma mark -
#pragma mark AKSIPAccountDelegate protocol

- (void)SIPAccountDidReceiveCall:(AKSIPCall *)aCall {
    if ([self isAccountUnavailable]) {
        // Reply with 480 Temporarily Unavailable if the user selected Unavailable account state.
        [aCall replyWithTemporarilyUnavailable];
        
        return;
        
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:kCallWaiting]) {
        // Reply with 486 Busy Here if needed.
        for (CallController *callController in [self callControllers]) {
            if ([callController isCallActive]) {
                [aCall replyWithBusyHere];
                
                return;
            }
        }
    }
    
    [[NSApp delegate] pauseITunes];
    
    CallController *aCallController = [[CallController alloc] initWithWindowNibName:@"Call" accountController:self];
    
    [aCallController setCall:aCall];
    [aCallController setCallActive:YES];
    [aCallController setCallUnhandled:YES];
    [[self callControllers] addObject:aCallController];
    
    AKSIPURIFormatter *SIPURIFormatter = [[AKSIPURIFormatter alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [SIPURIFormatter setFormatsTelephoneNumbers:[defaults boolForKey:kFormatTelephoneNumbers]];
    [SIPURIFormatter setTelephoneNumberFormatterSplitsLastFourDigits:
     [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
    
    // These variables will be changed during the Address Book search if the record is found.
    NSString *finalTitle = [[aCall remoteURI] SIPAddress];
    NSString *finalDisplayedName = [SIPURIFormatter stringForObjectValue:[aCall remoteURI]];
    NSString *finalStatus = NSLocalizedString(@"calling",
                                              @"John Smith calling. Somebody is calling us right "
                                               "now. Call status string. Deliberately in lower case, "
                                               "translators should do the same, if possible.");
    AKSIPURI *finalRedialURI = [aCall remoteURI];
    
    // Search Address Book for caller's name.
    
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    NSArray *records = nil;
    
    ABSearchElement *SIPAddressMatch
        = [ABPerson searchElementForProperty:kABEmailProperty
                                       label:nil
                                         key:nil
                                       value:[[aCall  remoteURI] SIPAddress]
                                  comparison:kABEqualCaseInsensitive];
    
    records = [AB recordsMatchingSearchElement:SIPAddressMatch];
    
    if ([records count] > 0) {
        id theRecord = [records objectAtIndex:0];
        
        finalDisplayedName = [theRecord ak_fullName];
        [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
        
        NSString *localizedLabel = [AB ak_localizedLabel:kEmailSIPLabel];
        finalStatus = localizedLabel;
        [aCallController setPhoneLabelFromAddressBook:localizedLabel];
        
        finalRedialURI = [aCall remoteURI];
        
    } else if ([[[aCall remoteURI] displayName] ak_isTelephoneNumber] ||
               ([[[aCall remoteURI] displayName] length] == 0 &&
                [[[aCall remoteURI] user] ak_isTelephoneNumber]))
    {  // No SIP Address found, search for the phone number.
        NSString *phoneNumberToSearch;
        if ([[[aCall remoteURI] displayName] length] > 0) {
            phoneNumberToSearch = [[aCall remoteURI] displayName];
        } else {
            phoneNumberToSearch = [[aCall remoteURI] user];
        }
        
        BOOL recordFound = NO;
        
        // Look for the whole phone number match first.
        ABSearchElement *phoneNumberMatch
            = [ABPerson searchElementForProperty:kABPhoneProperty
                                           label:nil
                                             key:nil
                                           value:phoneNumberToSearch
                                      comparison:kABEqual];
        
        records = [AB recordsMatchingSearchElement:phoneNumberMatch];
        if ([records count] > 0) {
            recordFound = YES;
            id theRecord = [records objectAtIndex:0];
            finalDisplayedName = [theRecord ak_fullName];
            [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
            
            // Find the exact phone number match.
            ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
            for (NSUInteger i = 0; i < [phones count]; ++i) {
                if ([[phones valueAtIndex:i] isEqualToString:phoneNumberToSearch]) {
                    NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                    finalStatus = localizedLabel;
                    [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                    
                    finalRedialURI = [AKSIPURI SIPURIWithUser:[phones valueAtIndex:i]
                                                         host:[[[self account] registrationURI] host]
                                                  displayName:nil];
                    break;
                }
            }
        }
        
        NSUInteger significantPhoneNumberLength = [defaults integerForKey:kSignificantPhoneNumberLength];
        
        // Get the significant phone suffix if the phone number length is greater
        // than we defined.
        NSString *significantPhoneSuffix;
        if ([phoneNumberToSearch length] > significantPhoneNumberLength) {
            significantPhoneSuffix = [phoneNumberToSearch substringFromIndex:
                                      ([phoneNumberToSearch length] - significantPhoneNumberLength)];
            
            // If the the record hasn't been found with the whole number, look for
            // significant suffix match.
            if (!recordFound) {
                ABSearchElement *phoneNumberSuffixMatch
                    = [ABPerson searchElementForProperty:kABPhoneProperty
                                                   label:nil
                                                     key:nil
                                                   value:significantPhoneSuffix
                                              comparison:kABSuffixMatch];
                
                records = [AB recordsMatchingSearchElement:phoneNumberSuffixMatch];
                if ([records count] > 0) {
                    recordFound = YES;
                    id theRecord = [records objectAtIndex:0];
                    finalDisplayedName = [theRecord ak_fullName];
                    [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
                    
                    // Find the exact phone number match.
                    ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
                    for (NSUInteger i = 0; i < [phones count]; ++i) {
                        if ([[phones valueAtIndex:i] hasSuffix:significantPhoneSuffix]) {
                            NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                            finalStatus = localizedLabel;
                            [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                            
                            finalRedialURI = [AKSIPURI SIPURIWithUser:[phones valueAtIndex:i]
                                                                 host:[[[self account] registrationURI] host]
                                                          displayName:nil];
                            break;
                        }
                    }
                }
            }
        }
        
        // If still not found, search phone numbers that contain spaces, dashes, etc.
        if (!recordFound) {
            NSArray *allPeople = [AB people];
            
            AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
            for (id theRecord in allPeople) {
                ABMultiValue *phones = [theRecord valueForProperty:kABPhoneProperty];
                
                for (NSUInteger i = 0; i < [phones count]; ++i) {
                    NSString *phoneNumber = [phones valueAtIndex:i];
                    
                    // Don't bother if the phone number contains only contiguous
                    // digits, we should have covered such numbers in previous search.
                    if ([phoneNumber ak_isTelephoneNumber]) {
                        continue;
                    }
                    
                    // Don't bother if the phone number has letters.
                    if ([phoneNumber ak_hasLetters]) {
                        continue;
                    }
                    
                    // Here phone number probably includes spaces or other dividers.
                    // Scan valid phone characters to compare with a given string.
                    NSString *scannedPhoneNumber = [telephoneNumberFormatter telephoneNumberFromString:phoneNumber];
                    if ([scannedPhoneNumber isEqualToString:phoneNumberToSearch]) {
                        recordFound = YES;
                    } else if (([phoneNumberToSearch length] > significantPhoneNumberLength) &&
                               [scannedPhoneNumber hasSuffix:significantPhoneSuffix]) {
                        
                        recordFound = YES;
                    }
                    
                    if (recordFound) {
                        NSString *localizedLabel = [AB ak_localizedLabel:[phones labelAtIndex:i]];
                        finalStatus = localizedLabel;
                        [aCallController setPhoneLabelFromAddressBook:localizedLabel];
                        
                        finalRedialURI = [AKSIPURI SIPURIWithUser:scannedPhoneNumber
                                                             host:[[[self account] registrationURI] host]
                                                      displayName:nil];
                        break;
                    }
                }
                
                if (recordFound) {
                    finalDisplayedName = [theRecord ak_fullName];
                    [aCallController setNameFromAddressBook:[theRecord ak_fullName]];
                    break;
                }
            }
        }
    }
    
    // Address Book search ends here.
    
    [[aCallController window] setTitle:finalTitle];
    [aCallController setDisplayedName:finalDisplayedName];
    [aCallController setStatus:finalStatus];
    [aCallController setRedialURI:finalRedialURI];
    
    [aCallController addViewController:[aCallController incomingCallViewController]];
    [[aCallController window] ak_resizeAndSwapToContentView:[[aCallController incomingCallViewController] view]];
    
    [aCallController showWindow:nil];
    
    // Show Growl notification.
    NSString *callSource;
    AKTelephoneNumberFormatter *telephoneNumberFormatter = [[AKTelephoneNumberFormatter alloc] init];
    [telephoneNumberFormatter setSplitsLastFourDigits:
     [defaults boolForKey:kTelephoneNumberFormatterSplitsLastFourDigits]];
    if ([[aCallController phoneLabelFromAddressBook] length] > 0) {
        callSource = [aCallController phoneLabelFromAddressBook];
    } else if ([[[aCall remoteURI] user] length] > 0) {
        if ([[[aCall remoteURI] user] ak_isTelephoneNumber]) {
            if ([defaults boolForKey:kFormatTelephoneNumbers]) {
                callSource = [telephoneNumberFormatter stringForObjectValue:[[aCall remoteURI] user]];
            } else {
                callSource = [[aCall remoteURI] user];
            }
        } else {
            callSource = [[aCall remoteURI] SIPAddress];
        }
    } else {
        callSource = [[aCall remoteURI] host];
    }
    
    NSString *notificationTitle, *notificationDescription;
    if ([[aCallController nameFromAddressBook] length] > 0) {
        notificationTitle = [aCallController nameFromAddressBook];
        notificationDescription = callSource;
        
    } else if ([[[aCall remoteURI] displayName] length] > 0) {
        notificationTitle = [[aCall remoteURI] displayName];
        notificationDescription
            = [NSString stringWithFormat:
               NSLocalizedString(@"calling from %@",
                                 @"John Smith calling from 1234567. "
                                  "Somebody is calling us right now from some source. "
                                  "Growl notification description. Deliberately in "
                                  "lower case, translators should do the same, if "
                                  "possible."),
               callSource];
    } else {
        notificationTitle = callSource;
        notificationDescription
            = NSLocalizedString(@"calling",
                                @"John Smith calling. Somebody is calling us right "
                                 "now. Growl notification description. "
                                 "Deliberately in lower case, translators should do "
                                 "the same, if possible.");
    }
    
    [GrowlApplicationBridge notifyWithTitle:notificationTitle
                                description:notificationDescription
                           notificationName:kGrowlNotificationIncomingCall
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[aCallController identifier]];
    
    [[[NSApp delegate] ringtone] play];
    [[NSApp delegate] startRingtoneTimer];
    
    if (![NSApp isActive]) {
        [NSApp requestUserAttention:NSInformationalRequest];
        [[NSApp delegate] startUserAttentionTimer];
    }
    
    [aCall sendRingingNotification];
}


#pragma mark -
#pragma mark AKSIPUserAgent notifications

- (void)SIPUserAgentDidFinishStarting:(NSNotification *)notification {
    if (![[notification object] isStarted]) {
        [self showOfflineState];
        
        return;
    }
    
    if ([self attemptingToRegisterAccount]) {
        [self setAccountRegistered:YES];
    } else if ([self attemptingToUnregisterAccount]) {
        [self setAccountRegistered:NO];
    }
}


#pragma mark -
#pragma mark AKNetworkReachability notifications

// This is the moment when the application starts doing its main job.
- (void)networkReachabilityDidBecomeReachable:(NSNotification *)notification {
    if (![self isAccountUnavailable] && ![self isAccountRegistered]) {
        [self setAttemptingToRegisterAccount:YES];
        [self setAccountRegistered:YES];
    }
}

@end
